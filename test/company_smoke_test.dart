import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labaik/core/l10n/app_language.dart';
import 'package:labaik/features/company/presentation/pages/company_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'company_test.dart' show FakeCompany;

// -------------------------------------------------------------
// كل شاشات الشركة بالعربي (يمين لشمال) وبالإنجليزي (شمال ليمين): ما في أخطاء رسم ولا نص طالع برّا مكانه
// -------------------------------------------------------------
void main() {
  for (final lang in ['ar', 'en']) {
    testWidgets('every company screen opens without layout errors ($lang)', (tester) async {
      SharedPreferences.setMockInitialValues({});
      AppLanguage.notifier.value = lang;
      tester.view.physicalSize = const Size(393 * 3, 852 * 3);
      tester.view.devicePixelRatio = 3;
      tester.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
      tester.view.viewPadding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
      addTearDown(tester.view.reset);
      final repo = FakeCompany();
      await repo.createGroup(tripId: '1', name: 'المجموعة الأولى');
      await repo.addSupervisor(fullName: 'محمد مطر', email: 'm@x.com');
      await repo.assignSupervisor('g1', 'm@x.com');
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) => Directionality(textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr, child: child!),
        home: CompanyShell(repository: repo),
      ));
      await tester.pumpAndSettle();
      final ar = lang == 'ar';
      Finder text(String a, String e) => find.text(ar ? a : e, findRichText: true);
      Future<void> tap(Finder f) async {
        expect(f, findsWidgets);
        await tester.tap(f.last, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      Future<void> back() async {
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }

      await tap(text('إنشاء رحلة', 'Create trip'));
      await back();
      await tap(text('إنشاء  المجموعات', 'Create groups'));
      await back();
      await tap(text('الرحلات', 'Trips'));
      await tap(text('عرض تفاصيل الرحلة', 'View trip details'));
      await back();
      await tap(text('المجموعات', 'Groups'));
      await tap(text('عرض تفاصيل المجموعة', 'View group details'));
      await tap(text('إضافة اعضاء مجموعة', 'Add group members'));
      await back();
      await back();
      await tap(text('الملف الشخصي', 'Profile'));
      await tap(text('بيانات الشركة', 'Company data'));
      await back();
      await tap(text('معلومات التواصل', 'Contact information'));
      await back();
      await tap(text('إدارة المشرفين', 'Manage supervisors'));
      await tap(text('إضافة مشرف', 'Add supervisor'));
      await back();
      await back();
      await tap(text('المساعدة والدعم', 'Help & support'));
      await back();
      expect(tester.takeException(), isNull);
    });
  }
}
