import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:labaik/core/l10n/app_language.dart';
import 'package:labaik/core/network/api_client.dart';
import 'package:labaik/core/network/backend_mode.dart';
import 'package:labaik/core/utils/geo_utils.dart';
import 'package:labaik/features/auth/data/account_registry.dart';
import 'package:labaik/features/chats/presentation/controllers/chats_controller.dart';
import 'package:labaik/features/chats/presentation/pages/conversation_screen.dart';
import 'package:labaik/features/family/data/sources/family_api.dart';
import 'package:labaik/features/family/domain/entities/family_circle.dart';
import 'package:labaik/features/family/domain/entities/family_member.dart';
import 'package:labaik/features/family/presentation/controllers/family_controller.dart';
import 'package:labaik/features/family/presentation/cubits/family_members_cubit.dart';
import 'package:labaik/features/family/presentation/cubits/family_setup_cubit.dart';
import 'package:labaik/features/family/presentation/l10n/family_members_text.dart';
import 'package:labaik/features/family/presentation/pages/family_found_screen.dart';
import 'package:labaik/features/family/presentation/pages/family_members_screen.dart';
import 'package:labaik/features/family/presentation/pages/family_setup_screen.dart';
import 'package:labaik/features/family/presentation/pages/family_share_location_screen.dart';
import 'package:labaik/features/family/presentation/widgets/family_member_card.dart';
import 'package:labaik/features/family/presentation/widgets/family_scanner.dart';
import 'package:labaik/features/pilgrim_tabs/presentation/controllers/pilgrim_tabs_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_chat_repository.dart';
import 'fakes/fake_family_repository.dart';

// -------------------------------------------------------------
// دائرة العائلة: طلبات السيرفر، الـ Cubits، والتنقل من تبويب "الأفراد" لحد المحادثة مع فرد
// -------------------------------------------------------------

final now = DateTime.now();

List<FamilyMember> sampleMembers() => [
      FamilyMember(userId: '2', name: 'خالد', lastSeenAt: now.subtract(const Duration(minutes: 18)), sharesLocation: true, location: const GeoPoint(21.42, 39.82), locationUpdatedAt: now.subtract(const Duration(hours: 1))),
      FamilyMember(userId: 'me', name: 'محمد', isMe: true, isOnline: true, sharesLocation: true, location: const GeoPoint(21.42, 39.82), locationUpdatedAt: now),
      const FamilyMember(userId: '3', name: 'سارة', isOnline: true),
    ];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({'access_token': fakeJwt('me')});
    AppLanguage.notifier.value = 'ar';
  });

  test('server API: circle, lookup (200 + null), join, members, sharing, remove', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      final path = request.url.path;
      Object? body;
      if (path.endsWith('/family-circle') && request.method == 'GET') {
        body = {
          'data': {
            'Id': 'c1',
            'Name': 'عائلة أحمد',
            'Code': 'A7K9P2',
            'IsOwner': true,
            'MembersCount': 4,
            'MySharesLocation': null,
            'MeetingPoint': {'Name': 'باب الملك فهد', 'Latitude': 21.4232, 'Longitude': 39.8265},
          },
        };
      } else if (path.endsWith('/lookup')) {
        body = {'data': request.url.queryParameters['code'] == 'A7K9P2' ? {'id': 'c1', 'name': 'عائلة أحمد', 'membersCount': 3} : null};
      } else if (path.endsWith('/join')) {
        body = {'id': 'c1', 'name': 'عائلة أحمد', 'code': 'A7K9P2', 'membersCount': 4};
      } else if (path.endsWith('/members') && request.method == 'GET') {
        body = [
          {'userId': '2', 'fullName': 'خالد', 'isOnline': false, 'lastSeenAt': now.toUtc().toIso8601String(), 'sharesLocation': true, 'latitude': 21.42, 'longitude': 39.82, 'locationUpdatedAt': now.toUtc().toIso8601String()},
        ];
      } else {
        return http.Response('', 204);
      }
      return http.Response(jsonEncode(body), 200, headers: {'content-type': 'application/json; charset=utf-8'});
    });
    final api = FamilyApi(ApiClient(baseUrl: 'https://api.test/api/v1', accessToken: () async => 'tok', refreshToken: () async => null, client: client));

    final circle = (await api.myCircle())!;
    expect(circle.name, 'عائلة أحمد');
    expect(circle.isOwner, isTrue);
    expect(circle.hasOthers, isTrue);
    expect(circle.mySharesLocation, isNull);
    expect(circle.meetingPoint?.location.latitude, 21.4232);

    expect(await api.findCircle('NOPE00'), isNull);
    expect((await api.findCircle('A7K9P2'))?.name, 'عائلة أحمد');
    expect((await api.joinCircle('c1')).membersCount, 4);
    expect(requests.last.url.path, '/api/v1/family-circles/c1/join');

    final members = await api.members();
    expect(members.single.name, 'خالد');
    expect(members.single.locationState(), MemberLocationState.available);

    await api.setLocationSharing(true);
    expect(requests.last.method, 'PUT');
    expect(jsonDecode(requests.last.body), {'enabled': true});
    await api.removeMember('2');
    expect(requests.last.method, 'DELETE');
    expect(requests.last.url.path, '/api/v1/family-circle/members/2');
    expect(requests.every((r) => r.headers['Authorization'] == 'Bearer tok'), isTrue);
  });

  test('QR content → circle code', () {
    expect(FamilyScanner.codeFrom('labaik://family/join?code=a7k9p2'), 'A7K9P2');
    expect(FamilyScanner.codeFrom(' UMRAH25 '), 'UMRAH25');
    expect(FamilyScanner.codeFrom('https://example.com'), isNull);
  });

  test('members: me first, search by name, location states, last seen', () async {
    final repo = FakeFamily(circle: const FamilyCircle(id: 'c1', name: 'x', code: 'A7K9P2', membersCount: 3))..list = sampleMembers();
    final cubit = FamilyMembersCubit(repo, pollInterval: const Duration(hours: 1));
    await cubit.start();
    expect(cubit.state.visible.map((m) => m.name), ['محمد', 'خالد', 'سارة']);
    expect(cubit.state.visible[1].locationState(), MemberLocationState.unavailable);
    expect(cubit.state.visible[2].locationState(), MemberLocationState.notShared);
    expect(FamilyMembersText.lastSeen(now.subtract(const Duration(minutes: 18)), now: now), 'اخر ظهور 18 د');
    cubit.search('سار');
    expect(cubit.state.visible.single.name, 'سارة');
    await cubit.remove('3');
    expect(repo.removed, ['3']);
    await cubit.close();
  });

  test('setup: the circle is created on open, and moves on when someone joins', () async {
    final repo = FakeFamily();
    final cubit = FamilySetupCubit(repo, watchInterval: const Duration(milliseconds: 20))..start();
    await Future<void>.delayed(const Duration(milliseconds: 5));
    expect(repo.created, 1);
    expect(cubit.state.circle?.code, 'MINE01');
    expect(cubit.state.circle?.hasOthers, isFalse);
    repo.circle = repo.circle!.copyWith(membersCount: 2);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(cubit.state.circle?.hasOthers, isTrue);
    await cubit.close();
  });

  testWidgets('الأفراد tab → choice → join with code → found → not now → members → chat with a member', (tester) async {
    await AccountRegistry.signedIn('p@example.com');
    final family = FakeFamily()
      ..codes['A7K9P2'] = const FamilyCircleSummary(id: 'c1', name: 'عائلة أحمد', membersCount: 3)
      ..list = sampleMembers();
    final chat = FakeChat();
    FamilyController.repository = () => family;
    ChatsController.chatRepository = () => chat;
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
            body: TextButton(onPressed: () => PilgrimTabsController.open(context, PilgrimTab.people), child: const Text('people')),
          ),
        ),
      ),
    );
    Future<void> tap(String text) async {
      await tester.tap(find.text(text).last, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    // العائلة → مش بدائرة → أنشئ دائرة عائلتك (الدائرة انعملت بالسيرفر ورمزها ظاهر)
    await tap('people');
    await tap('العائلة');
    expect(find.byType(FamilySetupScreen), findsOneWidget);
    expect(find.text('أنشئ دائرة عائلتك'), findsOneWidget);
    expect(family.created, 1);
    expect(find.text('MINE01'), findsOneWidget);

    // انضم → رمز غلط → رسالة — الرمز الصح → تم العثور على دائرة عائلتك
    await tap('إنضم إلى دائرة العائلة');
    expect(find.text('انضم إلى دائرة عائلتك'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'nope00');
    await tap('متابعة');
    expect(find.text('لم نجد دائرة بهذا الرمز، تأكد منه وحاول مرة أخرى'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'a7k9p2');
    await tap('متابعة');
    expect(find.byType(FamilyFoundScreen), findsOneWidget);
    expect(find.text('عائلة أحمد'), findsOneWidget);

    // انضمام → مشاركة موقعك مع عائلتك → ليس الآن → أفراد عائلتي (تبويب الأفراد)
    await tap('انضمام إلى الدائرة');
    expect(family.joined, ['c1']);
    expect(find.byType(FamilyShareLocationScreen), findsOneWidget);
    await tap('ليس الآن');
    expect(family.sharing, [false]);
    expect(find.byType(FamilyMembersScreen), findsOneWidget);
    expect(find.byType(FamilyMemberCard), findsNWidgets(3));
    expect(find.text('انت'), findsOneWidget);
    expect(find.text('اخر ظهور 18 د'), findsOneWidget);

    // تبويب الأفراد وهو مفتوح → النافذة (بتقدر تبدّل) — العائلة → نفس التبويب — وعرض نقطة التجمع بدون نقطة → رسالة
    // الرسالة السابقة (SnackBar) بتغطي شريط التنقل لحد ما تختفي
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الأفراد').last);
    await tester.pumpAndSettle();
    expect(find.text('مع من تريد التتبع؟'), findsOneWidget);
    await tap('العائلة');
    expect(find.text('مع من تريد التتبع؟'), findsNothing);
    expect(find.byType(FamilyMembersScreen), findsOneWidget);
    await tap('عرض نقطة التجمع');
    expect(find.text('لم تُحدَّد نقطة تجمع بعد'), findsOneWidget);

    // ⋮ على خالد → بدء محادثة → المحادثة الفردية معه (مؤقتاً على الجهاز — BackendMode — فما بتوصل للسيرفر)
    final khaled = find.ancestor(of: find.text('خالد'), matching: find.byType(FamilyMemberCard));
    await tester.tap(find.descendant(of: khaled, matching: find.byType(GestureDetector)).last);
    await tester.pumpAndSettle();
    expect(find.text('حذف من الدائرة'), findsNothing); // مش صاحب الدائرة
    await tap('بدء محادثة');
    expect(chat.direct, BackendMode.family ? ['2'] : isEmpty);
    expect(find.byType(ConversationScreen), findsOneWidget);
  });
}
