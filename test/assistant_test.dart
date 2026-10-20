import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labaik/core/l10n/app_language.dart';
import 'package:labaik/features/assistant/presentation/controllers/assistant_controller.dart';
import 'package:labaik/features/assistant/presentation/l10n/assistant_text.dart';
import 'package:labaik/features/assistant/presentation/pages/assistant_screen.dart';

// -------------------------------------------------------------
// المساعد الذكي: الفتح من الرئيسية، الأسئلة المقترحة، والسؤال المكتوب
// (ما في endpoint للمساعد لسا → رسالة إنه مش متاح، والسؤال المكتوب بيضل بالحقل)
// -------------------------------------------------------------
void main() {
  setUp(() => AppLanguage.notifier.value = 'ar');

  testWidgets('home → assistant: suggested questions and typed question reach the assistant', (tester) async {
    // شاشة بحجم إطار Figma (393×852)
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    addTearDown(tester.view.reset);
    // نفس تركيب التطبيق: كل الشاشات (حتى اللي بتنفتح فوق) بالعربي من اليمين
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: Builder(builder: (context) => Scaffold(body: TextButton(onPressed: () => AssistantController.open(context), child: const Text('home')))),
    ));

    await tester.tap(find.text('home'));
    await tester.pumpAndSettle();
    expect(find.byType(AssistantScreen), findsOneWidget);
    expect(find.text(AssistantText.title()), findsOneWidget);
    for (final q in AssistantText.questions) {
      expect(find.text(q()), findsOneWidget);
    }

    // سؤال مقترح
    // (النص نفسه ما بيستقبل ضغطات — الكرت كله منطقة ضغط)
    await tester.tap(find.text(AssistantText.questions[1]()), warnIfMissed: false);
    await tester.pump();
    expect(find.text(AssistantText.unavailable()), findsOneWidget);

    // الإرسال بدون سؤال
    // زر الإرسال (مربع Figma 35..64 × 772..801 — الشاشة بنفس مقاس الإطار)
    await tester.tapAt(const Offset(49.5, 786.5));
    await tester.pumpAndSettle();
    expect(find.text(AssistantText.emptyQuestion()), findsOneWidget);

    // سؤال مكتوب (من زر الكيبورد)
    await tester.enterText(find.byType(TextField), 'وين أقرب صراف؟');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    expect(find.text(AssistantText.unavailable()), findsOneWidget);
    expect(find.text('وين أقرب صراف؟'), findsOneWidget);

    // سهم الرجوع
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tapAt(const Offset(371.25, 80));
    await tester.pumpAndSettle();
    expect(find.byType(AssistantScreen), findsNothing);
  });
}
