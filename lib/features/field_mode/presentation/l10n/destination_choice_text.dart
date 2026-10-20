import '../../../../core/l10n/tx.dart';

/// نصوص شاشة "أين تريد التوجه الآن؟"
abstract final class DestinationChoiceText {
  static const title = Tx('أين تريد التوجه الآن؟', 'Where do you want to go now?');
  static const hotel = Tx('الفندق', 'The hotel');
  static const hotelChoiceDesc = Tx('أضع أمتعتي ثم أتوجه إلى المسجد الحرام.', 'I drop off my luggage, then head to Al-Masjid Al-Haram.');
  static const goToHotel = Tx('الذهاب إلى الفندق', 'Go to the hotel');
  static const haram = Tx('المسجد الحرام', 'Al-Masjid Al-Haram');
  static const haramChoiceDesc = Tx('أتوجه مباشرة لأداء النسك.', 'I head straight to perform the rite.');
  static const goToHaram = Tx('الذهاب إلى المسجد الحرام', 'Go to Al-Masjid Al-Haram');
  static const routeMeccaTitle = Tx('الطريق إلى مكة المكرمة', 'Route to Makkah');
}
