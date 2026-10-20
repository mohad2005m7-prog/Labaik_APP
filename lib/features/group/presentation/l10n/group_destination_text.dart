import '../../../../core/l10n/tx.dart';

/// نصوص "وجهتك القادمة" لنقطة التجمع (Figma 111:6735) — بنفس كتابة Figma
/// (سطر "نسخ الكابشن" بآخر الفقرة بـ Figma بقايا نسخ ولصق — انشال)
abstract final class GroupDestinationText {
  static const title = Tx('وجهتك القادمة', 'Your next destination');
  static const pill = Tx('نقطة تجمع مجموعتك.', "Your group's meeting point.");
  static const intro = Tx('تعرّف على موقع نقطة التجمع، وسنتولى إرشادك للوصول إليها.', "See where the meeting point is and we'll guide you there.");
  static const arrivalLabel = Tx('نقطة وصولك : ', 'Your arrival point: ');
  static const distanceLabel = Tx('يبعد عنك : ', 'Distance: ');
  static const timeLabel = Tx('الوقت المتوقع  : ', 'Expected time: ');
  static String about(String time) => tr('حوالي $time', 'About $time');
  static const groupPoint = Tx('نقطة تجمع مجموعتك', 'Group meeting point');
  static const currentLocation = Tx('موقعك الحالي ', 'Your location');
  static const question = Tx('ماذا ستفعل عند الوصول؟', 'What to do when you arrive?');
  static const outro = Tx(
    'عند وصولك، توجّه إلى نقطة التجمع المحددة وسجّل وصولك\nليتمكّن مشرف المجموعة من الاطمئنان عليك.',
    'When you arrive, go to the meeting point and confirm your arrival so your group supervisor knows you are safe.',
  );
  static const start = Tx('ابدأ الطريق', 'Start the route');

  // قبل ما نعرف موقعك (مش بـ Figma)
  static const unknown = Tx('--', '--');
}
