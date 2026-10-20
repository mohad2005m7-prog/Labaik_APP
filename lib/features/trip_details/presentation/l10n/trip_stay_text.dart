import '../../../../core/l10n/tx.dart';

/// نصوص "أين ستقيم؟" بشاشات التعديل (Figma 8 و9 تعديل) — الشرح مكسور بنفس سطور كل إطار
/// (العنوان واسم المدينة والخيارات من نصوص شاشات الإعداد: StayText)
abstract final class TripStayText {
  static const typesDescription = Tx(
    'أخبرنا بمكان إقامتك لنساعدك في الوصول إليه والعثور على\nالأماكن القريبة.',
    'Tell us where you will stay so we can help you get there and find nearby places.',
  );
  static const placesDescription = Tx(
    'أخبرنا بمكان إقامتك لنساعدك في الوصول إليه\nوالعثور على الأماكن القريبة.',
    'Tell us where you will stay so we can help you get there and find nearby places.',
  );
  static const chooseStay = Tx('يرجى اختيار مكان إقامتك بكل مدينة للمتابعة', 'Please choose where you will stay in each city to continue');
  static const enterStay = Tx('يرجى تحديد مكان إقامتك بكل مدينة للمتابعة', 'Please set your place of stay in each city to continue');
}
