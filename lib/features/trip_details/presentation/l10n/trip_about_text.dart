import '../../../../core/l10n/tx.dart';

/// نصوص "أخبرنا اكثر عن رحلتك؟" (Figma 10تعديل) — Figma كاتبها للعمرة، وللحج نفس الجمل بكلمة الحج
abstract final class TripAboutText {
  static const title = Tx('أخبرنا اكثر عن رحلتك؟', 'Tell us more about your trip');
  static const enterName = Tx('أدخل اسمك', 'Enter your name');
  static const namePlaceholder = Tx('محمد احمد', 'e.g. Mohammad Ahmad');

  static String firstQuestion(bool hajj) => hajj ? tr('هل هذه أول حجة لك؟', 'Is this your first Hajj?') : tr('هل هذه أول عمرة لك؟', 'Is this your first Umrah?');
  static String firstYes(bool hajj) => hajj ? tr('نعم، هذه أول حجة لي', 'Yes, this is my first Hajj') : tr('نعم، هذه أول عمرة لي', 'Yes, this is my first Umrah');
  // Figma: "لا ، سبق وأديت العمرة" (مسافة قبل الفاصلة) — بدونها
  static String firstNo(bool hajj) => hajj ? tr('لا، سبق وأديت الحج', "No, I've performed Hajj before") : tr('لا، سبق وأديت العمرة', "No, I've performed Umrah before");

  static const companionsQuestion = Tx('مع من ستسافر؟', 'Who are you traveling with?');
  static const companionsHint = Tx('يمكنك اختيار أكثر من خيار', 'You can choose more than one');
  static const alone = Tx('بمفردي', 'Alone');
  static const family = Tx('مع العائلة', 'With family');
  static const group = Tx('مع مجموعة', 'With a group');

  static const answerAll = Tx('يرجى إدخال اسمك والإجابة على الأسئلة للمتابعة', 'Please enter your name and answer the questions to continue');
}
