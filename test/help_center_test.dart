import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:labaik/core/l10n/app_language.dart';
import 'package:labaik/core/network/api_client.dart';
import 'package:labaik/core/network/api_exception.dart';
import 'package:labaik/core/utils/geo_utils.dart';
import 'package:labaik/features/assistant/presentation/pages/assistant_screen.dart';
import 'package:labaik/features/auth/data/account_registry.dart';
import 'package:labaik/features/help_center/data/sources/help_api.dart';
import 'package:labaik/features/help_center/domain/entities/lost_child_report.dart';
import 'package:labaik/features/help_center/domain/entities/supervisor_contact.dart';
import 'package:labaik/features/help_center/domain/repositories/lost_child_repository.dart';
import 'package:labaik/features/help_center/domain/repositories/supervisor_repository.dart';
import 'package:labaik/features/help_center/presentation/controllers/help_center_controller.dart';
import 'package:labaik/features/help_center/presentation/cubits/lost_child_report_cubit.dart';
import 'package:labaik/features/help_center/presentation/l10n/lost_child_text.dart';
import 'package:labaik/features/help_center/presentation/pages/help_center_screen.dart';
import 'package:labaik/features/help_center/presentation/pages/lost_child_report_screen.dart';
import 'package:labaik/features/help_center/presentation/pages/quick_contact_screen.dart';
import 'package:labaik/features/help_center/presentation/pages/share_report_screen.dart';
import 'package:labaik/features/help_center/presentation/pages/supervisor_chat_screen.dart';
import 'package:labaik/features/chats/presentation/controllers/chats_controller.dart';
import 'package:labaik/features/chats/presentation/widgets/chat_bubble.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_chat_repository.dart';

// -------------------------------------------------------------
// مركز المساعدة: طلبات السيرفر (المشرف والبلاغ، والتجديد بعد 401)، والتنقل الكامل لحد إرسال البلاغ
// (المحادثة نفسها والاتصال اللحظي: chats_test.dart)
// -------------------------------------------------------------

const supervisor = SupervisorContact(id: '7', name: 'أحمد محمد', phone: '+966500000000', conversationId: 'c1');

class FakeSupervisors implements SupervisorRepository {
  @override
  Future<SupervisorContact?> cached() async => null;
  @override
  Future<SupervisorContact?> fetch() async => supervisor;
}

class FakeReports implements LostChildRepository {
  final submitted = <(LostChildReport, bool)>[];
  @override
  Future<void> submit(LostChildReport report, {required bool shareWithNearby}) async => submitted.add((report, shareWithNearby));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({'access_token': fakeJwt('u1')});
    AppLanguage.notifier.value = 'ar';
  });

  group('server API', () {
    test('supervisor and lost child report', () async {
      final requests = <http.Request>[];
      final client = MockClient((request) async {
        requests.add(request);
        final path = request.url.path;
        if (path.endsWith('/pilgrim/supervisor')) {
          return http.Response(
            jsonEncode({
              'data': {'id': '7', 'FullName': 'أحمد محمد', 'phoneNumber': '+966500000000', 'conversationId': 'c1'},
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (path.endsWith('/lost-child-reports')) return http.Response('', 201);
        return http.Response('', 404);
      });
      final api = HelpApi(ApiClient(baseUrl: 'https://api.test/api/v1', accessToken: () async => 'tok', refreshToken: () async => null, client: client));

      final sup = await api.mySupervisor();
      expect(sup, supervisor);
      expect(requests.single.headers['Authorization'], 'Bearer tok');

      await api.submitLostChild(const LostChildReport(age: 7, description: 'قميص أحمر', location: GeoPoint(21.4, 39.8)), shareWithNearby: true);
      final form = utf8.decode(requests.last.bodyBytes);
      expect(requests.last.headers['content-type'], startsWith('multipart/form-data'));
      for (final field in ['approxAge', 'قميص أحمر', 'latitude', 'shareWithNearby']) {
        expect(form, contains(field));
      }
    });

    test('expired token is renewed once, missing endpoint → isMissingOnServer, no connection → isOffline', () async {
      final seen = <String?>[];
      final client = MockClient((request) async {
        seen.add(request.headers['Authorization']);
        if (request.url.path.endsWith('/missing')) return http.Response('', 404);
        return request.headers['Authorization'] == 'Bearer new' ? http.Response('{"ok":true}', 200) : http.Response('', 401);
      });
      final api = ApiClient(baseUrl: 'https://api.test', accessToken: () async => 'old', refreshToken: () async => 'new', client: client);
      expect(await api.getJson('/x'), {'ok': true});
      expect(seen, ['Bearer old', 'Bearer new']);

      await expectLater(api.getJson('/missing'), throwsA(isA<ApiException>().having((e) => e.isMissingOnServer, 'missing', isTrue)));

      final offline = ApiClient(baseUrl: 'https://api.test', accessToken: () async => null, refreshToken: () async => null, client: MockClient((_) => throw const SocketException('down')));
      await expectLater(offline.getJson('/x'), throwsA(isA<ApiException>().having((e) => e.isOffline, 'offline', isTrue)));
    });
  });

  testWidgets('tab bar → help center → supervisor chat, lost child report (no / yes), assistant, home', (tester) async {
    await AccountRegistry.signedIn('p@example.com');
    final chat = FakeChat();
    final reports = FakeReports();
    HelpCenterController.supervisorRepository = FakeSupervisors.new;
    ChatsController.chatRepository = () => chat;
    HelpCenterController.lostChildRepository = () => reports;
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    tester.view.viewPadding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(onPressed: () => HelpCenterController.open(context), child: const Text('home')),
          ),
        ),
      ),
    );
    Future<void> tap(String text) async {
      await tester.tap(find.text(text).last, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    await tap('home');
    expect(find.byType(HelpCenterScreen), findsOneWidget);

    // تائه ؟ → التواصل السريع → محادثة المشرف → إرسال
    await tap('تائه ؟ تواصل مع مشرفك');
    expect(find.byType(QuickContactScreen), findsOneWidget);
    expect(find.text('أحمد محمد'), findsOneWidget);
    await tap('محادثة المشرف');
    expect(find.byType(SupervisorChatScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'أنا عند باب الملك فهد');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    expect(chat.sent.single.text, 'أنا عند باب الملك فهد');
    expect(find.byWidgetPredicate((w) => w is ChatBubble && w.fromMe && w.text == 'أنا عند باب الملك فهد'), findsOneWidget);
    Navigator.of(tester.element(find.byType(SupervisorChatScreen))).pop();
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(QuickContactScreen))).pop();
    await tester.pumpAndSettle();

    // الإبلاغ عن طفل مفقود: لازم العمر والوصف والموقع
    Future<void> fillReport() async {
      await tap('الإبلاغ عن طفل مفقود');
      expect(find.byType(LostChildReportScreen), findsOneWidget);
      await tap('إرسال البلاغ للمشرف');
      expect(find.text(LostChildText.chooseAge()), findsOneWidget);
      await tap(LostChildText.ageHint());
      await tap(LostChildText.age(7));
      expect(find.text('7 سنوات'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'قميص أحمر وبنطلون أزرق');
      await tap('إرسال البلاغ للمشرف');
      expect(find.text(LostChildText.attachLocation()), findsOneWidget);
      // الموقع الحالي (GPS) — بالاختبار بنحطه مباشرة
      tester.element(find.byType(LostChildReportScreen)).read<LostChildReportCubit>().setLocation(const GeoPoint(21.4225, 39.8262));
      await tester.pumpAndSettle();
      expect(find.text(LostChildText.locationAttached()), findsOneWidget);
      await tap('إرسال البلاغ للمشرف');
      expect(find.byType(ShareReportScreen), findsOneWidget);
    }

    // لا , شكرا → البلاغ بيلغى ← مركز المساعدة
    await fillReport();
    await tap('لا , شكرا');
    expect(find.byType(HelpCenterScreen), findsOneWidget);
    expect(find.byType(ShareReportScreen), findsNothing);
    expect(reports.submitted, isEmpty);

    // نعم , مشاركة البلاغ → بيوصل للسيرفر → تم إرسال البلاغ بنجاح! → تأكيد → الرئيسية
    await fillReport();
    await tap('نعم , مشاركة البلاغ');
    expect(find.text('تم إرسال البلاغ بنجاح!'), findsOneWidget);
    final (report, shared) = reports.submitted.single;
    expect(shared, isTrue);
    expect(report.age, 7);
    expect(report.description, 'قميص أحمر وبنطلون أزرق');
    expect(report.location?.latitude, 21.4225);
    await tap('تأكيد');
    expect(find.text('home'), findsOneWidget);
    expect(find.byType(HelpCenterScreen), findsNothing);

    // اسأل عن التطبيق والمناسك → المساعد الذكي — وتبويب الرئيسية بيرجع للرئيسية
    await tap('home');
    await tap('اسأل عن التطبيق والمناسك');
    expect(find.byType(AssistantScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(AssistantScreen))).pop();
    await tester.pumpAndSettle();
    await tap('الرئيسية');
    expect(find.byType(HelpCenterScreen), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });
}
