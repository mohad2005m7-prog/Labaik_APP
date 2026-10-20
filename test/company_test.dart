import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:labaik/core/l10n/app_language.dart';
import 'package:labaik/core/network/api_client.dart';
import 'package:labaik/features/auth/data/auth_session.dart';
import 'package:labaik/features/company/data/repositories/company_repository_impl.dart';
import 'package:labaik/features/company/data/sources/company_api.dart';
import 'package:labaik/features/company/domain/entities/company_group.dart';
import 'package:labaik/features/company/domain/entities/company_member.dart';
import 'package:labaik/features/company/domain/entities/company_notification.dart';
import 'package:labaik/features/company/domain/entities/company_overview.dart';
import 'package:labaik/features/company/domain/entities/company_trip.dart';
import 'package:labaik/features/company/domain/repositories/company_repository.dart';
import 'package:labaik/features/company/presentation/cubits/company_trips_cubit.dart';
import 'package:labaik/features/company/presentation/pages/company_create_trip_screen.dart';
import 'package:labaik/features/company/presentation/pages/company_group_detail_screen.dart';
import 'package:labaik/features/company/presentation/pages/company_members_screen.dart';
import 'package:labaik/features/company/presentation/widgets/company_form_sheet.dart';
import 'package:labaik/features/company/presentation/pages/company_notifications_screen.dart';
import 'package:labaik/features/company/presentation/pages/company_shell.dart';
import 'package:labaik/features/company/presentation/pages/company_trips_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// -------------------------------------------------------------
// واجهة الشركة: الرئيسية (الترحيب والأرقام) → الجرس → الإشعارات، تبويب الرحلات (الفلترة والبحث)،
// والتبويبات والأزرار اللي لسا ما انبنت ("قريباً") — والبيانات الحقيقية من السيرفر لسا فاضية
// -------------------------------------------------------------
class FakeCompany implements CompanyRepository {
  final groupsList = <CompanyGroup>[];
  final createdTrips = <TripDraft>[];
  final rosterList = <CompanySupervisor>[];
  final membersList = <CompanyMember>[const CompanyMember(userId: 's1', name: 'عمر حداد', isSupervisor: true)];

  @override
  Future<CompanyOverview> overview() async =>
      CompanyOverview(firstName: 'محمد', companyName: 'شركة النور', activeTrips: 3, pilgrims: 75, supervisors: rosterList.length, groups: groupsList.length);

  @override
  Future<List<CompanyTrip>> trips() async => const [
        CompanyTrip(id: '1', title: 'رحلة العمرة الأولى', destinations: 'مكة المكرمة والمدينة المنورة', dates: '20 – 30 نوفمبر 2026', status: CompanyTripStatus.upcoming),
        CompanyTrip(id: '2', title: 'رحلة العمرة الخامسة', destinations: 'مكة المكرمة والمدينة المنورة', dates: '20 – 30 نوفمبر 2026', status: CompanyTripStatus.departed),
        CompanyTrip(id: '3', title: 'رحلة الحج الثالثة', destinations: 'مكة المكرمة', dates: '15 ديسمبر 2026', status: CompanyTripStatus.upcoming),
      ];

  @override
  Future<CompanyTrip> createTrip(TripDraft draft) async {
    createdTrips.add(draft);
    return CompanyTrip(id: '9', title: draft.name, destinations: draft.destinations.join('، '), dates: '', status: CompanyTripStatus.upcoming);
  }

  @override
  Future<List<CompanyNotification>> notifications() async => [
        CompanyNotification(id: '1', title: 'تم إنشاء مجموعة جديدة', body: 'تم إنشاء مجموعة بنجاح.', important: true, createdAt: DateTime.now()),
      ];

  @override
  Future<List<CompanyGroup>> groups() async => List.of(groupsList);

  @override
  Future<CompanyGroup> createGroup({required String tripId, required String name}) async {
    final g = CompanyGroup(id: 'g${groupsList.length + 1}', tripId: tripId, name: name, tripName: 'رحلة العمرة الأولى', joinCode: 'K7P2QX', memberCount: 0, status: CompanyGroupStatus.active);
    groupsList.add(g);
    return g;
  }

  @override
  Future<List<CompanyMember>> members(String groupId) async => List.of(membersList);

  @override
  Future<CompanyMember> member(String groupId, String userId) async => membersList.firstWhere((m) => m.userId == userId);

  @override
  Future<CompanyGroup> addMember(String groupId, {required String email, String? fullName, String? phone}) async {
    membersList.add(CompanyMember(userId: 'p${membersList.length}', name: fullName ?? email, email: email, number: membersList.length));
    return groupsList.first.copyWith(memberCount: membersList.length - 1);
  }

  @override
  Future<List<CompanySupervisor>> supervisors() async => List.of(rosterList);

  @override
  Future<CompanySupervisor> addSupervisor({required String fullName, required String email, String? phone}) async {
    final s = CompanySupervisor(userId: 's${rosterList.length + 2}', name: fullName, email: email);
    rosterList.add(s);
    return s;
  }

  @override
  Future<CompanyGroup> assignSupervisor(String groupId, String email) async {
    final s = rosterList.firstWhere((x) => x.email == email);
    final i = groupsList.indexWhere((g) => g.id == groupId);
    return groupsList[i] = groupsList[i].copyWith(supervisorName: s.name);
  }
}

/// سيرفر وهمي لـ /company — [requests] = "METHOD path body"
({ApiClient client, List<String> requests}) fakeServer(Map<String, Object?> routes) {
  final requests = <String>[];
  final client = MockClient((r) async {
    final key = '${r.method} ${r.url.path.replaceFirst('/api/v1', '')}';
    requests.add('$key ${r.body}');
    if (!routes.containsKey(key)) return http.Response('', 404);
    return http.Response.bytes(utf8.encode(jsonEncode(routes[key])), 200, headers: {'content-type': 'application/json'});
  });
  return (
    client: ApiClient(baseUrl: 'https://x/api/v1', accessToken: () async => 't', refreshToken: () async => null, client: client),
    requests: requests,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppLanguage.notifier.value = 'ar';
  });

  test('trips: filter by status and search by name or destination', () async {
    final cubit = CompanyTripsCubit(FakeCompany());
    await cubit.load();
    expect(cubit.state.visible, hasLength(3));
    cubit.select(CompanyTripsFilter.upcoming);
    expect(cubit.state.visible.map((t) => t.id), ['1', '3']);
    cubit.select(CompanyTripsFilter.departed);
    expect(cubit.state.visible.map((t) => t.id), ['2']);
    cubit.select(CompanyTripsFilter.all);
    cubit.search('الحج');
    expect(cubit.state.visible.single.id, '3');
    cubit.search('المدينة');
    expect(cubit.state.visible.map((t) => t.id), ['1', '2']);
    await cubit.close();
  });

  test('server: greeting uses the company name, numbers from /company/home', () async {
    await AuthSession.saveFromResponse(jsonEncode({'user': {'id': 'u1', 'email': 'co@example.com', 'fullName': 'محمد أحمد', 'roles': ['Company']}}));
    final server = fakeServer({
      'GET /company/me': {'id': 'c1', 'name': 'AL_BAWASEL', 'commercialRegistrationNumber': '1', 'contactFullName': 'محمد'},
      'GET /company/home': {'activeTrips': 2, 'pilgrimsCount': 182, 'supervisorsCount': 4, 'groupsCount': 5},
    });
    final overview = await CompanyRepositoryImpl(api: CompanyApi(server.client)).overview();
    expect(overview.greetingName, 'AL_BAWASEL');
    expect(overview.firstName, 'محمد');
    expect([overview.activeTrips, overview.pilgrims, overview.supervisors, overview.groups], [2, 182, 4, 5]);
  });

  test('server: trips get destinations from details, groups get trip name and ended status', () async {
    final server = fakeServer({
      'GET /company/trips': [
        {'id': 't1', 'name': 'رحلة العمرة الأولى', 'pilgrimageType': 1, 'departureDate': '2026-11-20', 'returnDate': '2026-11-30', 'expectedPilgrims': 40, 'status': 1},
        {'id': 't2', 'name': 'رحلة قديمة', 'pilgrimageType': 2, 'departureDate': '2025-01-01', 'returnDate': '2025-01-10', 'expectedPilgrims': 10, 'status': 2},
      ],
      'GET /company/trips/t1': {'id': 't1', 'name': 'رحلة العمرة الأولى', 'destinations': ['مكة المكرمة', 'المدينة المنورة'], 'departureDate': '2026-11-20', 'returnDate': '2026-11-30', 'status': 1},
      'GET /company/trips/t2': {'id': 't2', 'name': 'رحلة قديمة', 'destinations': ['مكة المكرمة'], 'departureDate': '2025-01-01', 'returnDate': '2025-01-10', 'status': 2},
      'GET /company/trips/t1/groups': [
        {'id': 'g1', 'tripId': 't1', 'name': 'مجموعة أ', 'joinCode': 'K7P2QX', 'supervisorId': null, 'supervisorName': null, 'pilgrimCount': 0},
      ],
      'GET /company/trips/t2/groups': [
        {'id': 'g2', 'tripId': 't2', 'name': 'مجموعة ب', 'joinCode': 'ABC123', 'supervisorId': 's', 'supervisorName': 'عمر', 'pilgrimCount': 38},
      ],
    });
    final repo = CompanyRepositoryImpl(api: CompanyApi(server.client));
    final trips = await repo.trips();
    expect(trips.first.destinations, 'مكة المكرمة، المدينة المنورة');
    expect(trips.first.dates, '20 – 30 نوفمبر 2026');
    expect(trips.first.status, CompanyTripStatus.upcoming);
    expect(trips.last.status, CompanyTripStatus.departed);

    final groups = await repo.groups();
    expect(groups.map((g) => (g.name, g.tripName, g.joinCode, g.status, g.memberCount, g.supervisorName)), [
      ('مجموعة أ', 'رحلة العمرة الأولى', 'K7P2QX', CompanyGroupStatus.active, 0, null),
      ('مجموعة ب', 'رحلة قديمة', 'ABC123', CompanyGroupStatus.ended, 38, 'عمر'),
    ]);
  });

  test('server: create trip sends the backend contract (numbers + yyyy-MM-dd)', () async {
    final server = fakeServer({
      'POST /company/trips': {'id': 't9', 'name': 'عمرة ديسمبر', 'destinations': ['مكة المكرمة'], 'departureDate': '2026-12-10', 'returnDate': null, 'status': 1},
    });
    final trip = await CompanyRepositoryImpl(api: CompanyApi(server.client)).createTrip(TripDraft(
      kind: PilgrimageKind.hajj,
      name: ' عمرة ديسمبر ',
      destinations: const ['مكة المكرمة'],
      departureDate: DateTime(2026, 12, 10),
      departurePlace: 'عمّان',
      expectedPilgrims: 40,
      notes: '  ',
    ));
    expect(trip.dates, '10 ديسمبر 2026');
    final body = jsonDecode(server.requests.single.substring('POST /company/trips '.length));
    expect(body, {
      'name': 'عمرة ديسمبر',
      'pilgrimageType': 2,
      'destinations': ['مكة المكرمة'],
      'departureDate': '2026-12-10',
      'returnDate': null,
      'departurePlace': 'عمّان',
      'expectedPilgrims': 40,
      'notes': null,
    });
    expect(CompanyCreateTripScreen.splitDestinations('مكة المكرمة، المدينة المنورة,الطائف'), ['مكة المكرمة', 'المدينة المنورة', 'الطائف']);
  });

  test('server: members (supervisor first) and company notifications by type', () async {
    final server = fakeServer({
      'GET /company/groups/g1/members': [
        {'userId': 's1', 'fullName': 'عمر حداد', 'email': 'omar@x.com', 'role': 1, 'memberNumberInGroup': null, 'attendanceStatus': 2},
        {'userId': 'p1', 'fullName': 'أحمد علي', 'email': 'a@x.com', 'role': 2, 'memberNumberInGroup': 15, 'attendanceStatus': 1},
      ],
      'GET /notifications': [
        {'id': 'n1', 'type': 5, 'preview': 'مجموعة أ', 'createdAtUtc': '2026-10-20T08:00:00Z', 'isRead': false},
        {'id': 'n2', 'type': 4, 'preview': 'عمر', 'createdAtUtc': '2026-10-19T08:00:00Z', 'isRead': true},
      ],
    });
    final repo = CompanyRepositoryImpl(api: CompanyApi(server.client));
    final members = await repo.members('g1');
    expect(members.map((m) => (m.name, m.isSupervisor, m.number, m.present)), [('عمر حداد', true, null, false), ('أحمد علي', false, 15, true)]);
    final notes = await repo.notifications();
    expect(notes.map((n) => (n.title, n.important)), [('مجموعة بدون مشرف', true), ('تم تفعيل حساب مشرف', false)]);
  });

  testWidgets('home → bell → notifications → back → trips tab (chips) → groups/profile = قريباً', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    tester.view.viewPadding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: CompanyShell(repository: FakeCompany()),
    ));
    await tester.pumpAndSettle();
    Finder text(String value) => find.text(value, findRichText: true);

    expect(text('السلام عليكم، شركة النور'), findsOneWidget);
    expect(text('75'), findsOneWidget);
    expect(text('حجاج / معتمرين'), findsOneWidget);

    // إنشاء رحلة → شاشة إنشاء رحلة جديدة
    await tester.tap(text('إنشاء رحلة').first, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanyCreateTripScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(CompanyCreateTripScreen))).pop();
    await tester.pumpAndSettle();

    // الجرس (24 من 16,59)
    await tester.tapAt(const Offset(28, 71));
    await tester.pumpAndSettle();
    expect(find.byType(CompanyNotificationsScreen), findsOneWidget);
    expect(text('تم إنشاء مجموعة جديدة'), findsOneWidget);
    expect(text('اليوم'), findsOneWidget);
    Navigator.of(tester.element(find.byType(CompanyNotificationsScreen))).pop();
    await tester.pumpAndSettle();

    await tester.tap(text('الرحلات').last, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanyTripsScreen), findsOneWidget);
    expect(text('جميع الرحلات'), findsOneWidget);
    expect(text('رحلة العمرة الخامسة'), findsOneWidget);
    expect(text('+ إنشاء رحلة جديدة'), findsOneWidget);
    await tester.tap(text('القادمة').last, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(text('رحلة العمرة الخامسة'), findsNothing);
    expect(text('جميع الرحلات'), findsNothing);
    expect(text('+ إنشاء رحلة جديدة'), findsNothing);

    // المجموعات → تبويب المجموعات يفتح (حالة فارغة)
    await tester.tap(text('المجموعات').last, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanyTripsScreen), findsNothing);
  });

  testWidgets('create group → join code → assign a new supervisor → add a pilgrim', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    tester.view.viewPadding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    addTearDown(tester.view.reset);
    final repo = FakeCompany();
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: CompanyShell(repository: repo),
    ));
    await tester.pumpAndSettle();
    Finder text(String value) => find.text(value, findRichText: true);

    // "إنشاء المجموعات" بالرئيسية → النموذج (الرحلة + الاسم)
    await tester.tap(text('إنشاء  المجموعات'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanyFormSheet), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'إنشاء'));
    await tester.pumpAndSettle();
    expect(text('عبّي الحقول المطلوبة'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'مجموعة أ');
    await tester.tap(find.widgetWithText(FilledButton, 'إنشاء'));
    await tester.pumpAndSettle();
    expect(find.byType(CompanyFormSheet), findsNothing);
    expect(text('تم إنشاء المجموعة — رمزها K7P2QX'), findsOneWidget);
    expect(repo.groupsList.single.name, 'مجموعة أ');
    expect(text('1'), findsOneWidget); // عدد المجموعات بالرئيسية تحدّث
    await tester.pump(const Duration(seconds: 3)); // الرسالة بتختفي عن شريط التنقل
    await tester.pumpAndSettle();

    // تبويب المجموعات → الكرت → التفاصيل فيها الرمز و"بلا مشرف بعد"
    await tester.tap(text('المجموعات').last, warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(text('مجموعة أ'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanyGroupDetailScreen), findsOneWidget);
    expect(text('K7P2QX'), findsOneWidget);
    expect(text('بلا مشرف بعد'), findsOneWidget);

    // المشرف: الشركة ما عندها مشرفين → نموذج "إضافة مشرف جديد" مباشرة → بيتعيّن
    await tester.tap(text('المشرف'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(text('إضافة مشرف جديد'), findsOneWidget);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'عمر حداد');
    await tester.enterText(fields.at(1), 'omar@x.com');
    await tester.tap(find.widgetWithText(FilledButton, 'إضافة'));
    await tester.pumpAndSettle();
    expect(text('المشرف: عمر حداد'), findsOneWidget);
    expect(repo.rosterList.single.email, 'omar@x.com');

    // الأعضاء → إضافة معتمر بالإيميل
    await tester.tap(text('الأعضاء'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanyMembersScreen), findsOneWidget);
    expect(text('مشرف المجموعة'), findsOneWidget);
    await tester.tap(text('إضافة عضو'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), 'not-an-email');
    await tester.tap(find.widgetWithText(FilledButton, 'إضافة'));
    await tester.pumpAndSettle();
    expect(text('البريد الإلكتروني غير صحيح'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(1), 'ahmad@x.com');
    await tester.enterText(find.byType(TextField).at(2), 'أحمد علي');
    await tester.tap(find.widgetWithText(FilledButton, 'إضافة'));
    await tester.pumpAndSettle();
    expect(text('أحمد علي'), findsOneWidget);
    expect(text('معتمر رقم 1'), findsOneWidget);
  });
}
