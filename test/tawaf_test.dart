import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labaik/core/l10n/app_language.dart';
import 'package:labaik/features/field_mode/data/sources/haram_gates.dart';
import 'package:labaik/features/saee/presentation/pages/saee_step_screen.dart';
import 'package:labaik/features/tawaf/presentation/controllers/tawaf_controller.dart';
import 'package:labaik/features/tawaf/presentation/pages/tawaf_done_screen.dart';
import 'package:labaik/features/tawaf/presentation/pages/tawaf_round_screen.dart';
import 'package:labaik/features/tawaf/presentation/widgets/shoes_warning_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';

// -------------------------------------------------------------
// من "وصلت إلى المسجد الحرام" لنهاية الطواف: الباب (باسمه) → داخل الحرم → التنبيه (ثانيتين) → الكعبة
// → صحن المطاف → الاضطباع → نقطة البداية → ابدأ → 7 أشواط → أتممت الطواف
// -------------------------------------------------------------
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppLanguage.notifier.value = 'ar';
  });

  testWidgets('gate → inside → warning → Kaaba … 7 rounds → done', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    tester.view.viewPadding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    addTearDown(tester.view.reset);

    final gate = HaramGates.defaults.firstWhere((g) => g.targetId == 'gate-1');
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
        home: Builder(builder: (context) => Scaffold(body: Center(child: TextButton(onPressed: () => TawafController.start(context, gate), child: const Text('وصلت'))))),
      ),
    );

    Finder text(String value) => find.text(value, findRichText: true);
    Future<void> tap(String value) async {
      await tester.ensureVisible(text(value).last);
      await tester.pumpAndSettle();
      await tester.tap(text(value).last, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    await tap('وصلت');
    // العنوان باسم الباب اللي اتجه إله
    expect(text('وصلت إلى باب الملك عبد العزيز'), findsOneWidget);

    await tap('دخلت الحرم');
    expect(text('أنت الآن داخل المسجد الحرام'), findsOneWidget);

    // التنبيه بينزل، وبعد ثانيتين بيسكّر وبتفتح "الكعبة أمامك"
    await tester.tap(text('وجدت لوحة «المطاف»').last, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ShoesWarningPopup), findsOneWidget);
    await tester.pump(TawafController.warningDelay);
    await tester.pumpAndSettle();
    expect(find.byType(ShoesWarningPopup), findsNothing);
    expect(text('الكعبة أمامك'), findsOneWidget);

    await tap('وصلت إلى صحن المطاف');
    expect(text('اقتربت من صحن المطاف'), findsOneWidget);
    await tap('وصلت إلى صحن المطاف');
    expect(text('اضبط إحرامك قبل الطواف'), findsOneWidget);
    await tap('تم ضبط الإحرام');
    expect(text('قف عند بداية الطواف'), findsOneWidget);
    await tap('أنا عند نقطة البداية');
    expect(text('ابدأ الشوط الأول'), findsWidgets);
    // نفس النص بالعنوان والزر: الزر أول واحد (العنوان بينرسم بعده)
    await tester.tap(text('ابدأ الشوط الأول').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    for (var round = 1; round <= 7; round++) {
      expect(tester.widget<TawafRoundScreen>(find.byType(TawafRoundScreen).last).round, round);
      await tap('تم الشوط');
    }
    expect(find.byType(TawafDoneScreen), findsOneWidget);
    expect(text('لقد أكملت 7 أشواط'), findsOneWidget);

    // الخطوة اللي بعدها: أول شاشة من السعي
    await tester.tap(text('متابعة إلى الخطوة التالية').last, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(SaeeStepScreen), findsOneWidget);

    // سهم الرجوع: أتممت الطواف ← الشوط السابع
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(tester.widget<TawafRoundScreen>(find.byType(TawafRoundScreen).last).round, 7);
  });
}
