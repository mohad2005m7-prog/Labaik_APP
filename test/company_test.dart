import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labaik/core/l10n/app_language.dart';
import 'package:labaik/features/auth/data/auth_session.dart';
import 'package:labaik/features/company/data/repositories/company_repository_impl.dart';
import 'package:labaik/features/company/domain/entities/company_group.dart';
import 'package:labaik/features/company/domain/entities/company_notification.dart';
import 'package:labaik/features/company/domain/entities/company_overview.dart';
import 'package:labaik/features/company/domain/entities/company_trip.dart';
import 'package:labaik/features/company/domain/repositories/company_repository.dart';
import 'package:labaik/features/company/presentation/cubits/company_trips_cubit.dart';
import 'package:labaik/features/company/presentation/pages/company_create_trip_screen.dart';
import 'package:labaik/features/company/presentation/pages/company_notifications_screen.dart';
import 'package:labaik/features/company/presentation/pages/company_shell.dart';
import 'package:labaik/features/company/presentation/pages/company_trips_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// -------------------------------------------------------------
// واجهة الشركة: الرئيسية (الترحيب والأرقام) → الجرس → الإشعارات، تبويب الرحلات (الفلترة والبحث)،
// والتبويبات والأزرار اللي لسا ما انبنت ("قريباً") — والبيانات الحقيقية من السيرفر لسا فاضية
// -------------------------------------------------------------
class FakeCompany implements CompanyRepository {
  @override
  Future<CompanyOverview> overview() async => const CompanyOverview(firstName: 'محمد', activeTrips: 3, pilgrims: 75, supervisors: 2, groups: 4);

  @override
  Future<List<CompanyTrip>> trips() async => const [
        CompanyTrip(id: '1', title: 'رحلة العمرة الأولى', destinations: 'مكة المكرمة والمدينة المنورة', dates: '20 – 30 نوفمبر 2026', status: CompanyTripStatus.upcoming),
        CompanyTrip(id: '2', title: 'رحلة العمرة الخامسة', destinations: 'مكة المكرمة والمدينة المنورة', dates: '20 – 30 نوفمبر 2026', status: CompanyTripStatus.departed),
        CompanyTrip(id: '3', title: 'رحلة الحج الثالثة', destinations: 'مكة المكرمة', dates: '15 ديسمبر 2026', status: CompanyTripStatus.upcoming),
      ];

  @override
  Future<List<CompanyNotification>> notifications() async => [
        CompanyNotification(id: '1', title: 'تم إنشاء مجموعة جديدة', body: 'تم إنشاء مجموعة بنجاح.', important: true, createdAt: DateTime.now()),
      ];

  @override
  Future<List<CompanyGroup>> groups() async => const [];
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

  test('real data: only the account name for now (no company data on the server yet)', () async {
    await AuthSession.saveFromResponse(jsonEncode({'user': {'id': 'u1', 'email': 'co@example.com', 'fullName': 'محمد أحمد', 'roles': []}}));
    final repo = CompanyRepositoryImpl();
    final overview = await repo.overview();
    expect(overview.firstName, 'محمد');
    expect(overview.companyName, isNull);
    expect(overview.activeTrips + overview.pilgrims + overview.supervisors + overview.groups, 0);
    expect(await repo.trips(), isEmpty);
    expect(await repo.notifications(), isEmpty);
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

    expect(text('السلام عليكم، محمد'), findsOneWidget);
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
}
