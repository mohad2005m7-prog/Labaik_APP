import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labaik/core/l10n/app_language.dart';
import 'package:labaik/core/utils/geo_utils.dart';
import 'package:labaik/features/auth/data/account_registry.dart';
import 'package:labaik/features/chats/presentation/pages/conversation_screen.dart';
import 'package:labaik/features/family/domain/entities/family_member.dart';
import 'package:labaik/features/family/presentation/widgets/family_member_card.dart';
import 'package:labaik/features/group/domain/entities/group_location_event.dart';
import 'package:labaik/features/group/domain/entities/group_member.dart';
import 'package:labaik/features/group/presentation/controllers/group_controller.dart';
import 'package:labaik/features/group/presentation/cubits/group_members_cubit.dart';
import 'package:labaik/features/group/presentation/pages/group_arrival_screen.dart';
import 'package:labaik/features/group/presentation/pages/group_destination_screen.dart';
import 'package:labaik/features/group/presentation/pages/group_map_screen.dart';
import 'package:labaik/features/group/presentation/pages/group_members_screen.dart';
import 'package:labaik/features/group/presentation/pages/group_route_screen.dart';
import 'package:labaik/features/pilgrim_tabs/presentation/controllers/pilgrim_tabs_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_chat_repository.dart';
import 'fakes/fake_group_repository.dart';

// -------------------------------------------------------------
// المجموعة: الأفراد والترتيب والمواقع اللحظية، والتنقل من تبويب "الأفراد" لحد "تم التأكيد" والرجوع للمجموعة
// -------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({'access_token': fakeJwt('me')});
    AppLanguage.notifier.value = 'ar';
    // طبقات الخريطة (flutter_map) بتحفظ كاش بمجلد التطبيق
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (call) async => '.');
  });

  test('members: supervisor first, me hidden from the list, search by name, 8 sharing on the map', () async {
    final cubit = GroupMembersCubit(FakeGroupRepository(), pollInterval: const Duration(hours: 1));
    await cubit.start();
    final visible = cubit.state.visible;
    expect(visible.first.isSupervisor, isTrue);
    expect(visible.any((m) => m.isMe), isFalse);
    expect(visible.map((m) => m.name).take(4), ['مشرف المجموعة', 'خالد', 'سارة', 'عبدالله']);
    expect(cubit.state.members.where((m) => !m.isMe && m.sharesLocation && m.location != null).length, 8);
    cubit.search('سا');
    expect(cubit.state.visible.single.name, 'سارة');
    await cubit.close();
  });

  test('live locations: LocationUpdated moves the member, StoppedSharing removes the pin', () async {
    final repo = FakeGroupRepository();
    final cubit = GroupMembersCubit(repo, pollInterval: const Duration(hours: 1));
    await cubit.start();
    GroupMember sara() => cubit.state.members.firstWhere((m) => m.userId == 'sara');
    expect(sara().location, isNull);

    final at = DateTime.now();
    repo.live.add(MemberMoved('sara', const GeoPoint(21.4225, 39.8262), at));
    await Future<void>.delayed(Duration.zero);
    expect(sara().location?.latitude, 21.4225);
    expect(sara().sharesLocation, isTrue);
    expect(sara().locationState(), MemberLocationState.available);

    repo.live.add(const MemberStoppedSharing('sara'));
    await Future<void>.delayed(Duration.zero);
    expect(sara().location, isNull);
    expect(sara().locationState(), MemberLocationState.notShared);
    await cubit.close();
  });

  testWidgets('الأفراد → المجموعة → chat → map → meeting point → route → arrived → confirmed → back to my group', (tester) async {
    await AccountRegistry.signedIn('p@example.com');
    final group = FakeGroupRepository();
    GroupController.repository = () => group;
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

    // النافذة بتنزل من فوق → المجموعة → أفراد مجموعتي (المشرف أول)
    await tap('people');
    expect(find.text('مع من تريد التتبع؟'), findsOneWidget);
    await tap('المجموعة');
    expect(find.byType(GroupMembersScreen), findsOneWidget);
    expect(find.text('مشرف المجموعة'), findsOneWidget);
    expect(find.byType(FamilyMemberCard), findsWidgets);

    // ⋮ على خالد → بدء محادثة → المحادثة الفردية
    final khaled = find.ancestor(of: find.text('خالد'), matching: find.byType(FamilyMemberCard));
    await tester.tap(find.descendant(of: khaled, matching: find.byType(GestureDetector)).last);
    await tester.pumpAndSettle();
    expect(find.text('حذف من الدائرة'), findsNothing);
    await tap('بدء محادثة');
    expect(find.byType(ConversationScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(ConversationScreen))).pop();
    await tester.pumpAndSettle();

    // رؤية المجموعة على الخريطة → عرض نقطة التجمع → وجهتك القادمة (اسم نقطة التجمع من المشرف)
    await tap('رؤية المجموعة على الخريطة');
    expect(find.byType(GroupMapScreen), findsOneWidget);
    expect(find.text('8  أفراد يشاركون مواقعهم'), findsOneWidget);
    await tap('عرض نقطة التجمع');
    expect(find.byType(GroupDestinationScreen), findsOneWidget);
    expect(find.textContaining('بوابة الملك فهد — المسجد الحرام', findRichText: true), findsOneWidget);

    // ابدأ الطريق → وصلت إلى نقطة التجمع → أكّد وصولك → العودة إلى الملاحة → وصلت → نعم، وصلت
    await tap('ابدأ الطريق');
    expect(find.byType(GroupRouteScreen), findsOneWidget);
    expect(find.text('تابع المسار الحالي باتجاه باب الملك فهد.'), findsOneWidget);
    await tap('وصلت إلى نقطة التجمع');
    expect(find.byType(GroupArrivalScreen), findsOneWidget);
    await tap('العودة إلى الملاحة');
    expect(find.byType(GroupArrivalScreen), findsNothing);
    expect(find.byType(GroupRouteScreen), findsOneWidget);
    await tap('وصلت إلى نقطة التجمع');
    await tap('نعم، وصلت');
    expect(group.arrivals, 1);
    expect(find.text('تم التأكيد'), findsOneWidget);

    // العودة إلى مجموعتي → أفراد مجموعتي
    await tap('العودة إلى مجموعتي');
    expect(find.text('تم التأكيد'), findsNothing);
    expect(find.byType(GroupMembersScreen), findsOneWidget);
    expect(find.byType(GroupRouteScreen), findsNothing);
  });
}
