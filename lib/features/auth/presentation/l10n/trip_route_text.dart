import '../../../../core/l10n/tx.dart';

/// نصوص شاشة مسار الرحلة
abstract final class TripRouteText {
  static const title = Tx('ما مسار رحلتك؟', 'What is your trip route?');
  static const description = Tx(
    'أضف المدن التي ستزورها بالترتيب لنساعدك في التنقل والاستعداد لكل مرحلة من رحلتك.',
    'Add the cities you will visit in order so we can help you get around and prepare for every stage of your trip.',
  );
  static const firstStop = Tx('المحطة الأولى', 'First Stop');
  static const nextStop = Tx('المحطة التالية', 'Next Stop');
  static const addStop = Tx('إضافة محطة', 'Add a Stop');
  static const searchFirst = Tx('ابحث عن وجهتك الاولى', 'Search for your first destination');
  static const searchNext = Tx('ابحث عن وجهتك التالية', 'Search for your next destination');
}
