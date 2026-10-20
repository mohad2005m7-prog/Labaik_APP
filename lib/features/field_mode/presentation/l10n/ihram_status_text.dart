import '../../../../core/l10n/tx.dart';

/// نصوص شاشة "ما حالة إحرامك؟"
abstract final class IhramStatusText {
  static const title = Tx('ما حالة إحرامك؟', "What's your ihram status?");
  static const description = Tx('سنحدد خطوتك التالية بناءً على حالتك الحالية وموقعك.', 'We will set your next step based on your current state and location.');
  static const notMuhrimTitle = Tx(' لم أُحرم بعد', 'Not in ihram yet');
  static const notMuhrimDesc = Tx('لم أدخل في نسك العمرة بعد.', "I haven't started the Umrah rite yet.");
  static const muhrimTitle = Tx('أنا مُحرم', "I'm in ihram");
  static const muhrimDesc = Tx('دخلت في نسك العمرة وأصبحت على إحرامي.', "I've started the Umrah rite and I'm in ihram.");
  static const continueLabel = Tx('متابعة', 'Continue');
}
