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
import 'package:labaik/features/company/domain/entities/company_profile.dart';
import 'package:labaik/features/company/domain/entities/company_notification.dart';
import 'package:labaik/features/company/domain/entities/company_overview.dart';
import 'package:labaik/features/company/domain/entities/company_trip.dart';
import 'package:labaik/features/company/domain/repositories/company_repository.dart';
import 'package:labaik/features/company/presentation/cubits/company_trips_cubit.dart';
import 'package:labaik/features/company/presentation/pages/company_create_trip_screen.dart';
import 'package:labaik/features/company/presentation/pages/company_group_detail_screen.dart';
import 'package:labaik/features/company/presentation/pages/company_members_screen.dart';
import 'package:labaik/features/company/presentation/pages/company_supervisor_screen.dart';
import 'package:labaik/features/company/presentation/pages/company_supervisors_screen.dart';
import 'package:labaik/features/company/presentation/pages/company_create_group_screen.dart';
import 'package:labaik/features/company/presentation/pages/company_data_screen.dart';
import 'package:labaik/features/company/presentation/pages/company_notifications_screen.dart';
import 'package:labaik/features/company/presentation/pages/company_pilgrims_screen.dart';
import 'package:labaik/features/company/presentation/pages/company_shell.dart';
import 'package:labaik/features/company/presentation/pages/company_trip_details_screen.dart';
import 'package:labaik/features/company/presentation/pages/company_trips_screen.dart';
import 'package:labaik/features/supervisor/presentation/pages/member_details_screen.dart';
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

  var profileData = const CompanyProfile(name: 'شركة النور', licenseNumber: 'LAB-2026-014', contactName: 'محمد', country: 'فلسطين', city: 'غزة', email: 'info@example.com');

  @override
  Future<CompanyProfile> profile() async => profileData;

  @override
  Future<CompanyProfile> updateProfile(CompanyProfile profile) async => profileData = profile;

  final removedSupervisors = <String>[];

  @override
  Future<void> removeSupervisor(String userId) async {
    removedSupervisors.add(userId);
    rosterList.removeWhere((s) => s.userId == userId);
  }

  @override
  Future<void> setSupervisorSuspended(String userId, {required bool suspended}) async {
    final i = rosterList.indexWhere((s) => s.userId == userId);
    rosterList[i] = rosterList[i].copyWith(suspended: suspended);
  }

  @override
  Future<String> supervisorTempPassword(String userId) async => 'Tmp#2026ab';

  @override
  Future<String> uploadLogo(String filePath) async => 'https://cdn.example.com/logo.png';

  @override
  Future<void> removeMember(String groupId, String userId) async => membersList.removeWhere((m) => m.userId == userId);

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

  testWidgets('create group page → join code popup → details → add supervisor → members → profile edit', (tester) async {
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

    // "إنشاء المجموعات" بالرئيسية → صفحة "إنشاء مجموعة جديدة"
    await tester.tap(text('إنشاء  المجموعات'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanyCreateGroupScreen), findsOneWidget);
    await tester.tap(text('إنشاء المجموعة'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(text('اختر الرحلة واكتب اسم المجموعة'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'مجموعة أ');
    await tester.tap(text('اختر الرحلة'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('رحلة العمرة الأولى').last);
    await tester.pumpAndSettle();
    await tester.tap(text('إنشاء المجموعة'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(text('تم إنشاء المجموعة'), findsOneWidget);
    expect(text('رمز الانضمام: K7P2QX'), findsOneWidget);
    await tester.tap(text('العودة للمجموعات'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanyCreateGroupScreen), findsNothing);
    expect(repo.groupsList.single.name, 'مجموعة أ');
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // تبويب المجموعات: الكرت "غير مكتملة" → التفاصيل
    await tester.tap(text('المجموعات').last, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(text('غير مكتملة'), findsWidgets);
    expect(text('مشرف المجموعة : لا يوجد بعد'), findsOneWidget);
    await tester.tap(text('عرض تفاصيل المجموعة'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanyGroupDetailScreen), findsOneWidget);
    expect(text('K7P2QX'), findsOneWidget);
    expect(text('إضافة اعضاء مجموعة'), findsOneWidget);

    // "إضافة المشرف": الشركة بلا مشرفين → صفحة "إضافة مشرف جديد" → بيتعيّن
    await tester.tap(text('إضافة المشرف'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(text('إضافة مشرف جديد'), findsOneWidget);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'عمر حداد');
    await tester.enterText(fields.at(1), 'omar@x.com');
    await tester.enterText(fields.at(2), '0591234567');
    await tester.tap(text('إضافة المشرف').last, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(text('مشرف المجموعة : عمر حداد'), findsOneWidget);
    expect(text('تغيير المشرف'), findsOneWidget);
    expect(repo.rosterList.single.email, 'omar@x.com');

    // الأعضاء → إضافة معتمر بالإيميل
    await tester.tap(text('إضافة اعضاء مجموعة'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanyMembersScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 3)); // رسالة "تمت إضافة المشرف" بتختفي عن الزر
    await tester.pumpAndSettle();
    await tester.tap(text('إضافة عضو'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), 'ahmad@x.com');
    await tester.enterText(find.byType(TextField).at(2), 'أحمد علي');
    await tester.tap(find.widgetWithText(FilledButton, 'إضافة'));
    await tester.pumpAndSettle();
    expect(text('أحمد علي'), findsOneWidget);
    // ضغط مطوّل → حذف من المجموعة
    await tester.longPress(text('أحمد علي'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(text('حذف من المجموعة'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(text('أحمد علي'), findsNothing);
    expect(repo.membersList.where((m) => !m.isSupervisor), isEmpty);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // الملف الشخصي: بيانات الشركة من /company/me → تعديل → حفظ
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    await tester.tap(text('الملف الشخصي').last, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(text('شركة النور'), findsOneWidget);
    expect(text('LAB-2026-014'), findsOneWidget);
    expect(text('غزة'), findsOneWidget);
    await tester.tap(text('بيانات الشركة'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanyDataScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'شركة الهدى');
    await tester.tap(text('حفظ التعديلات'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanyDataScreen), findsNothing);
    expect(repo.profileData.name, 'شركة الهدى');
    expect(text('شركة الهدى'), findsOneWidget);
  });

  testWidgets('manage supervisors: open a supervisor → temp password, suspend, remove (only without groups)', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    tester.view.viewPadding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    addTearDown(tester.view.reset);
    final repo = FakeCompany();
    await repo.addSupervisor(fullName: 'سندس جوادة', email: 's@x.com');
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: CompanySupervisorsScreen(repository: repo),
    ));
    await tester.pumpAndSettle();
    Finder text(String v) => find.text(v, findRichText: true);
    await tester.tap(text('سندس جوادة'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanySupervisorScreen), findsOneWidget);
    expect(text('الحساب مفعّل'), findsOneWidget);
    expect(text('لا يشرف على أي مجموعة بعد'), findsOneWidget);

    await tester.tap(text('إصدار كلمة مرور مؤقتة'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(text('كلمة المرور المؤقتة: Tmp#2026ab'), findsOneWidget);

    await tester.tap(text('إيقاف الحساب'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'إيقاف الحساب'));
    await tester.pumpAndSettle();
    expect(text('الحساب موقوف'), findsOneWidget);
    expect(text('تفعيل الحساب'), findsOneWidget);
    expect(repo.rosterList.single.suspended, isTrue);

    await tester.tap(text('حذف من الشركة'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'حذف من الشركة'));
    await tester.pumpAndSettle();
    expect(find.byType(CompanySupervisorScreen), findsNothing);
    expect(repo.removedSupervisors, hasLength(1));
    expect(text('سندس جوادة'), findsNothing);
  });

  testWidgets('home is interactive: stat cards, active trips, pilgrims → profile, supervisor name → supervisor page', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    tester.view.viewPadding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    addTearDown(tester.view.reset);
    final repo = FakeCompany();
    await repo.addSupervisor(fullName: 'عمر حداد', email: 'omar@x.com');
    repo.groupsList.add(const CompanyGroup(id: 'g1', tripId: '1', name: 'مجموعة النور', tripName: 'رحلة العمرة الأولى', joinCode: 'K7P2QX', memberCount: 1, status: CompanyGroupStatus.active, supervisorName: 'عمر حداد'));
    repo.membersList.add(const CompanyMember(userId: 'p1', name: 'أحمد علي', number: 15, present: true));
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: CompanyShell(repository: repo),
    ));
    await tester.pumpAndSettle();
    Finder text(String v) => find.text(v, findRichText: true);

    // الرحلات النشطة الحقيقية تحت كروت الإجراءات
    expect(text('رحلة العمرة الأولى'), findsOneWidget);
    expect(text('رحلة الحج الثالثة'), findsOneWidget);

    // "حجاج / معتمرين" → كل المعتمرين (بلا المشرف) → صفحة المعتمر
    await tester.tap(text('حجاج / معتمرين'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanyPilgrimsScreen), findsOneWidget);
    expect(text('العدد: 1'), findsOneWidget);
    expect(text('مجموعة النور'), findsOneWidget);
    expect(text('عمر حداد'), findsNothing);
    await tester.tap(text('أحمد علي'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(MemberDetailsScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(MemberDetailsScreen))).pop();
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(CompanyPilgrimsScreen))).pop();
    await tester.pumpAndSettle();

    // "المشرفون" → إدارة المشرفين
    await tester.tap(text('المشرفون'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanySupervisorsScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(CompanySupervisorsScreen))).pop();
    await tester.pumpAndSettle();

    // كرت رحلة نشطة → تفاصيلها → اسم المشرف بالمجموعة → صفحة المشرف (ومجموعاته بتفتح التفاصيل)
    await tester.ensureVisible(text('عرض تفاصيل الرحلة').first);
    await tester.pumpAndSettle();
    await tester.tap(text('عرض تفاصيل الرحلة').first);
    await tester.pumpAndSettle();
    expect(find.byType(CompanyTripDetailsScreen), findsOneWidget);
    await tester.tap(text('عرض تفاصيل المجموعة'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanyGroupDetailScreen), findsOneWidget);
    await tester.tap(text('مشرف المجموعة : عمر حداد'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanySupervisorScreen), findsOneWidget);
    expect(text('مجموعة النور'), findsOneWidget);
    await tester.tap(text('مجموعة النور'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanyGroupDetailScreen, skipOffstage: false), findsNWidgets(2));
    Navigator.of(tester.element(find.byType(CompanyGroupDetailScreen))).pop();
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(CompanySupervisorScreen))).pop();
    await tester.pumpAndSettle();

    // أعضاء المجموعة: الضغط على المشرف → صفحة المشرف مش صفحة المعتمر
    await tester.tap(text('عرض جميع الاعضاء'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(text('عمر حداد'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanySupervisorScreen), findsOneWidget);
    expect(find.byType(MemberDetailsScreen), findsNothing);
    Navigator.of(tester.element(find.byType(CompanySupervisorScreen))).pop();
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(CompanyMembersScreen))).pop();
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(CompanyGroupDetailScreen))).pop();
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(CompanyTripDetailsScreen))).pop();
    await tester.pumpAndSettle();

    // "الرحلات النشطة" (الكرت) → تبويب الرحلات
    await tester.ensureVisible(text('الرحلات النشطة').first);
    await tester.pumpAndSettle();
    await tester.tap(text('الرحلات النشطة').first, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CompanyTripsScreen), findsOneWidget);
    expect(text('جميع الرحلات'), findsOneWidget);
  });
}
