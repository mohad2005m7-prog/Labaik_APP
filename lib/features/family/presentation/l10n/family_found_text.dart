import '../../../../core/l10n/tx.dart';

/// نصوص "تم العثور على دائرة عائلتك" (111:5199) و"مشاركة موقعك مع عائلتك" (111:5228) — بنفس كتابة وسطور Figma
abstract final class FamilyFoundText {
  static const title = Tx('تم العثور على دائرة عائلتك', 'We found your family circle');
  static const description = Tx('أهلًا بك! وجدت دائرة عائلتك، ويمكنك الآن الانضمام إليها.', 'Welcome! We found your family circle and you can join it now.');
  static const stayInTouch = Tx('انضم إلى دائرتك لتبقى على تواصل مع أفراد عائلتك أثناء الرحلة.', 'Join your circle to stay in touch with your family during the trip.');
  static const join = Tx('انضمام إلى الدائرة', 'Join the circle');

  static const shareTitle = Tx('مشاركة موقعك مع عائلتك', 'Share your location with your family');
  static const shareDescription = Tx('ابقَ قريبًا منهم، واسمح لهم برؤية موقعك أثناء الرحلة', 'Stay close and let them see your location during the trip');
  static const shareNote = Tx(
    'عند مشاركة موقعك، سيتمكن أفراد دائرتك من رؤيته على\nالخريطة.\nيمكنك إيقاف مشاركة موقعك في أي وقت.',
    'When you share your location, your circle can see it on the map. You can stop sharing at any time.',
  );
  static const shareMine = Tx('مشاركة موقعي', 'Share my location');
  static const notNow = Tx('ليس الآن', 'Not now');
}
