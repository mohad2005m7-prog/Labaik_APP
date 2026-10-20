import '../../../../core/l10n/tx.dart';

/// نصوص شاشات الطريق (إلى الميقات / مكة / الفندق / المسجد الحرام) ومسافاتها وأوقاتها
abstract final class RouteText {
  static const miqatTitle = Tx('الطريق إلى ميقات ذو الحليفة', 'Route to Dhul Hulaifah Miqat');
  static const meccaTitle = Tx('الطريق إلى مكة المكرمة', 'Route to Makkah');
  static const hotelTitle = Tx('الطريق إلى فندقك', 'Route to your hotel');
  static const haramTitle = Tx('الطريق إلى المسجد الحرام', 'Route to Al-Masjid Al-Haram');
  static const haramArrivalTitle = Tx('وصلت إلى المسجد الحرام', 'You reached Al-Masjid Al-Haram');
  static const chip8km = Tx(' 8 كم', '8 km');
  static const chip24km = Tx(' 2.4 كم', '2.4 km');
  static const chip12min = Tx('12 دقيقة', '12 min');
  static const miqatStep = Tx(
    'تابع السير إلى الأمام، ثم اتبع الطريق باتجاه ميقات ذو الحليفة.\nاستمر في المسار الحالي حتى تصل إلى الميقات.',
    'Keep going ahead, then follow the road towards Dhul Hulaifah Miqat. Stay on the current route until you reach the Miqat.',
  );
  static const meccaStep = Tx(
    'تابع السير إلى الأمام لمسافة {distance}، ثم اتبع الطريق\nباتجاه مكة المكرمة.',
    'Keep going ahead for {distance}, then follow the road towards Makkah.',
  );
  static const meccaStepNoDistance = Tx('تابع السير إلى الأمام، ثم اتبع الطريق\nباتجاه مكة المكرمة.', 'Keep going ahead, then follow the road towards Makkah.');
  static const miqatNearStep = Tx(
    'تبقّى {distance} للوصول إلى ميقات ذو الحليفة.\nتابع السير، فالوجهة أصبحت قريبة.',
    '{distance} left to reach Dhul Hulaifah Miqat. Keep going, your destination is close.',
  );
  static const meccaNearStep = Tx(
    'أنت على بُعد دقائق من مكة المكرمة،\nتابع السير حتى تصل إلى وجهتك.',
    'You are minutes away from Makkah. Keep going until you reach your destination.',
  );
  static String chipDistance(Object distance) => tr(' $distance', '$distance');
  static String distanceKm(Object value) => tr('$value كم', '$value km');
  static String distanceM(Object value) => tr('$value م', '$value m');
  /// بالعربي: من 3 لـ 10 "دقائق" — غير هيك "دقيقة"
  static String durationMin(int min) => tr(min >= 3 && min <= 10 ? '$min دقائق' : '$min دقيقة', '$min min');
  static String durationHours(Object h) => tr('$h س', '$h h');
  static String durationHoursMin(Object h, Object min) => tr('$h س $min د', '$h h $min min');
  static const hotelStepA = Tx('اتجه إلى الأمام لمسافة 500 م وبعد 7 كم، استمر في المسار\nالأيمن', 'Go ahead for 500 m and after 7 km keep to the right lane');
  static const hotelStepB = Tx('.', '');
  static const hotelStepC = Tx('، ثم انعطف يمينًا باتجاه فندقك.', ', then turn right towards your hotel.');
  static const haramStep = Tx(
    'اتجه إلى الأمام لمسافة {distance}، ثم تابع السير\nباتجاه المسجد الحرام.',
    'Go ahead for {distance}, then keep going towards Al-Masjid Al-Haram.',
  );
  static const haramStepNoDistance = Tx('اتجه إلى الأمام، ثم تابع السير\nباتجاه المسجد الحرام.', 'Go ahead, then keep going towards Al-Masjid Al-Haram.');
  static const haramGateStep = Tx(
    'اخترنا لك أقرب باب مناسب لموقعك. اتجه إلى الأمام\nلمسافة {distance}، ثم تابع باتجاه {gate}',
    'We chose the nearest suitable gate for you. Go ahead for {distance}, then continue towards {gate}',
  );
  static const haramGateStepChosen = Tx('اتجه إلى الأمام لمسافة {distance}،\nثم تابع باتجاه {gate}', 'Go ahead for {distance}, then continue towards {gate}');
  static const haramGateStepNoDistance = Tx('اتجه إلى الأمام، ثم تابع باتجاه {gate}', 'Go ahead, then continue towards {gate}');
  static const miqatHint = Tx('تابع المسار الحالي باتجاه ميقات ذو الحليفة.', 'Stay on the current route towards Dhul Hulaifah Miqat.');
  static const meccaHint = Tx('تابع المسار الحالي باتجاه مكة المكرمة.', 'Stay on the current route towards Makkah.');
  static const hotelHint = Tx('تابع المسار الحالي باتجاه فندقك.', 'Stay on the current route towards your hotel.');
  static const haramHint = Tx('تابع المسار الحالي باتجاه المسجد الحرام', 'Stay on the current route towards Al-Masjid Al-Haram');
  static const arrivedMiqat = Tx('وصلت إلى الميقات ', 'I reached the Miqat');
  static const arrivedMecca = Tx('وصلت إلى مكة  ', 'I reached Makkah');
  static const arrivedHotel = Tx(' وصلت إلى الفندق', 'I reached the hotel');
  static const arrivedHaram = Tx(' وصلت إلى المسجد الحرام', 'I reached Al-Masjid Al-Haram');
  static const lost = Tx('انا ضائع', "I'm lost");
}
