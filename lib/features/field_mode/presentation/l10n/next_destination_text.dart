import '../../../../core/l10n/tx.dart';

/// نصوص شاشة "وجهتك القادمة"
abstract final class NextDestinationText {
  static const prepareIhramTitle = Tx('حان وقت الاستعداد للإحرام', 'Time to prepare for ihram');
  static const title = Tx('وجهتك القادمة', 'Your next destination');
  static const tripToMiqat = Tx('رحلتك إلى الميقات', 'Your trip to the Miqat');
  static const tripToMecca = Tx('رحلتك إلى مكة', 'Your trip to Makkah');
  static const tripToHotel = Tx('رحلتك إلى الفندق', 'Your trip to the hotel');
  static const tripToHaram = Tx('رحلتك إلى المسجد الحرام', 'Your trip to Al-Masjid Al-Haram');
  static const miqatIntro = Tx(
    'بناءً على موقعك ومسار رحلتك، سنرشدك إلى نقطة الإحرام\nالمناسبة قبل دخول مكة.',
    'Based on your location and route, we will guide you to the right ihram point before entering Makkah.',
  );
  static const meccaIntro = Tx(
    'اتبع الإرشادات للوصول إلى مكة، وسنخبرك بالخطوة التالية\nأثناء الطريق.',
    'Follow the directions to reach Makkah, and we will tell you the next step along the way.',
  );
  static const hotelIntro = Tx(
    'اتبع الإرشادات للوصول إلى فندقك، وسنرافقك خطوة\nبخطوة حتى الوصول',
    'Follow the directions to reach your hotel, and we will guide you step by step until you arrive',
  );
  static const haramIntro = Tx(
    'بعد وضع أمتعتك، حان وقت التوجه إلى المسجد الحرام.\nسنرافقك خطوة بخطوة حتى الوصول.',
    'After dropping off your luggage, it is time to head to Al-Masjid Al-Haram. We will guide you step by step until you arrive.',
  );
  static const arrivalPointLabel = Tx('نقطة وصولك : ', 'Arrival point: ');
  static const arrivalMiqat = Tx('ميقات ذو الحليفة', 'Dhul Hulaifah Miqat');
  static const arrivalHotel = Tx('برج ساعة مكة', 'Makkah Clock Tower');
  static const arrivalHaram = Tx(' المسجد الحرام', 'Al-Masjid Al-Haram');
  static const distanceLabel = Tx('يبعد عنك', 'Distance');
  static const distance8km = Tx(' : 8 كم', ': 8 km');
  static const distance420km = Tx(' : 420 كم', ': 420 km');
  static const timeLabel = Tx('الوقت المتوقع', 'Estimated time');
  static const time12min = Tx('  : حوالي 12 دقيقة', ': about 12 minutes');
  static const time4h30min = Tx('  : حوالي 4 ساعات و 30 دقيقة', ': about 4 hours and 30 minutes');
  static const currentLocation = Tx('موقعك الحالي', 'Your location');
  static const miqatName = Tx('ميقات ذو الحليفة ', 'Dhul Hulaifah Miqat');
  static const miqatAltName = Tx('( ابار علي )', '(Abyar Ali)');
  static const hotelName = Tx('فندق برج الساعة\nمكة المكرمة', 'Makkah Clock Tower Hotel');
  static const haramName = Tx('المسجد الحرام ', 'Al-Masjid Al-Haram');
  static const onArrivalQuestion = Tx('ماذا ستفعل عند الوصول؟', 'What will you do on arrival?');
  static const onArrivalMiqat = Tx(
    'عند الوصول إلى الميقات، ستستعد للإحرام ثم\nتبدأ رحلتك إلى مكة.',
    'When you reach the Miqat, you will prepare for ihram and then start your trip to Makkah.',
  );
  static const onArrivalMecca = Tx(
    'عند الوصول إلى مكة، سنساعدك في الوصول إلى المسجد\nالحرام والاستعداد لبدء الطواف.',
    'When you reach Makkah, we will help you get to Al-Masjid Al-Haram and prepare to start Tawaf.',
  );
  static const onArrivalHotel = Tx(
    'عند الوصول إلى الفندق ، يمكنك وضع أمتعتك ثم\nالاستعداد للتوجه إلى المسجد الحرام.',
    'When you reach the hotel, you can drop off your luggage and then get ready to head to Al-Masjid Al-Haram.',
  );
  static const onArrivalHaram = Tx(
    'عند وصولك إلى المسجد الحرام، سنساعدك في الوصول\nإلى أقرب باب مناسب ثم نرشدك إلى صحن المطاف.',
    'When you reach Al-Masjid Al-Haram, we will help you get to the nearest suitable gate and then guide you to the Mataf.',
  );
  static const startRoute = Tx('ابدأ الطريق', 'Start the route');
}
