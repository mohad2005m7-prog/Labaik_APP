import '../../../../core/l10n/tx.dart';

/// نصوص شاشة "المساعد الذكي" (Figma 111:6047)
abstract final class AssistantText {
  static const title = Tx('المساعد الذكي', 'Smart Assistant');
  // Figma: "مساعدك خلال رحلة  في النسك " (مسافتين بين "رحلة" و"في") — مكتوبة بمسافة وحدة
  static const subtitle = Tx('مساعدك خلال رحلة في النسك', 'Your assistant throughout your journey');
  static const hello = Tx('أهلًا فيك! كيف بقدر أساعدك؟', 'Welcome! How can I help you?');
  static const intro = Tx(
    'اسألني عن استخدام التطبيق، أو إرشادات المناسك، أو كيف توصل لخدمات التطبيق.',
    'Ask me about using the app, rituals guidance, or how to reach the app services.',
  );
  static const suggested = Tx('أسئلة مقترحة', 'Suggested questions');
  static const questions = [
    Tx('كيف أستخدم الخريطة؟', 'How do I use the map?'),
    Tx('كيف أتواصل مع مشرف مجموعتي؟', 'How do I contact my group supervisor?'),
    Tx('كيف أرجع إلى الفندق؟', 'How do I get back to the hotel?'),
    Tx('شو المرحلة الحالية من المناسك؟', 'What is the current ritual stage?'),
  ];
  static const hint = Tx('اكتب سؤالك هنا...', 'Type your question here...');
  static const emptyQuestion = Tx('يرجى كتابة سؤالك أولاً', 'Please type your question first');
  static const unavailable = Tx('المساعد الذكي غير متاح حالياً', 'The smart assistant is not available yet');
}
