import '../../../../core/l10n/tx.dart';

/// نصوص شاشتين الإقامة (أين ستقيم؟ + تفاصيل الإقامة)
abstract final class StayText {
  static const title = Tx('أين ستقيم؟', 'Where will you stay?');
  static const description = Tx(
    'أخبرنا بمكان إقامتك لنساعدك في الوصول إليه والعثور على الأماكن القريبة.',
    'Tell us where you will stay so we can help you get there and find nearby places.',
  );
  static String inCity(Object city) => tr('إقامتك في $city', 'Your stay in $city');
  static const notDecided = Tx('لم أحدد مكان إقامتي بعد', "I haven't decided where to stay yet");
  static const search = Tx('ابحث عن مكان اقامتك', 'Search for your place of stay');
  static const enterPlace = Tx('أدخل أو حدّد مكان إقامتك', 'Enter or choose your place of stay');
  static const hotel = Tx('فندق', 'Hotel');
  static const otherPlace = Tx('مكان اخر', 'Another place');
}
