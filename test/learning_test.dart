import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labaik/core/l10n/app_language.dart';
import 'package:labaik/features/auth/data/account_registry.dart';
import 'package:labaik/features/auth/presentation/l10n/home_text.dart';
import 'package:labaik/features/learning/presentation/controllers/learning_controller.dart';
import 'package:labaik/features/learning/presentation/pages/learning_stage_screen.dart';
import 'package:labaik/features/learning/presentation/widgets/learning_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';

// -------------------------------------------------------------
// مراحل التعلم: التقدّم محفوظ لكل حساب، والتنقل متل البروتوتايب (التالي / النوافذ / الرئيسية / تمت العمرة)
// -------------------------------------------------------------
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppLanguage.notifier.value = 'ar';
  });

  test('progress is saved per account and never goes back', () async {
    final progress = LearningController.progress;
    await AccountRegistry.signedIn('a@example.com');
    expect(await progress.completed(), 0);
    await progress.complete(1);
    await progress.complete(0); // مراجعة مرحلة قبل ما بترجّع التقدّم
    expect(await progress.completed(), 2);

    await AccountRegistry.signedIn('b@example.com');
    expect(await progress.completed(), 0);

    await AccountRegistry.signedIn('a@example.com');
    expect(await progress.completed(), 2);
  });

  test('home next step follows the progress', () {
    expect(HomeText.nextStep(0), 'الخطوة التالية : أكمل التعلم عن الإحرام');
    expect(HomeText.nextStep(1), 'الخطوة التالية : أكمل التعلم عن الطواف');
    expect(HomeText.nextStep(3), 'الخطوة التالية : أكمل التعلم عن التحلل');
    expect(HomeText.nextStep(4), 'أكملت التعلم عن مراحل العمرة');
  });

  testWidgets('continue learning → stages, popups, home, Umrah completed', (tester) async {
    await AccountRegistry.signedIn('p@example.com');
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    tester.view.viewPadding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
        home: Builder(builder: (context) => Scaffold(body: Center(child: TextButton(onPressed: () => LearningController.resume(context), child: const Text('تابع'))))),
      ),
    );

    Finder text(String value) => find.text(value, findRichText: true);
    Future<void> tap(String value) async {
      await tester.ensureVisible(text(value).last);
      await tester.pumpAndSettle();
      await tester.tap(text(value).last, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    LearningStageScreen stage() => tester.widget<LearningStageScreen>(find.byType(LearningStageScreen).last);

    // أول مرة: الإحرام
    await tap('تابع');
    expect(stage().index, 0);
    expect(text('المرحلة الأولى: الإحرام'), findsOneWidget);

    // زر ذهبي → نافذة (بنص الشاشة) → حسناً بيسكّرها
    await tap('المحظورات الخاصة بالرجال');
    expect(find.byType(LearningPopup), findsOneWidget);
    await tap('حسناً');
    expect(find.byType(LearningPopup), findsNothing);

    // التالي → الطواف (والإحرام خلص)
    await tap('التالي');
    expect(stage().index, 1);
    expect(await LearningController.progress.completed(), 1);

    // الرئيسية → ولما يرجع "تابع التعلم" بيكمل من الطواف
    await tap('الرئيسية');
    expect(find.byType(LearningStageScreen), findsNothing);
    await tap('تابع');
    expect(stage().index, 1);

    // ماذا لو انتقض وضوئي…؟
    await tap('ماذا لو انتقض وضوئي أو نسيت عدد الأشواط؟');
    expect(find.byType(LearningPopup), findsOneWidget);
    await tap('حسناً');

    // الطواف → السعي → التحلّل
    await tap('التالي');
    expect(stage().index, 2);
    await tap('شروط وأحكام السعي');
    expect(find.byType(LearningPopup), findsOneWidget);
    await tap('حسناً');
    await tap('التالي');
    expect(stage().index, 3);

    // تمت العمرة → مبروك → الرجوع للرئيسية
    await tap('تمت العمرة');
    expect(text('مبروك إتمام العمرة'), findsOneWidget);
    expect(await LearningController.progress.completed(), 4);
    await tap('الرجوع للرئيسية');
    expect(find.byType(LearningStageScreen), findsNothing);
    expect(find.byType(LearningPopup), findsNothing);

    // خلص كل المراحل: "تابع التعلم" بيفتح من الأول للمراجعة
    await tap('تابع');
    expect(stage().index, 0);
  });
}
