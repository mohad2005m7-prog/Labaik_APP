import '../../../../core/l10n/tx.dart';

/// نصوص شاشات "تعديل تفاصيل الرحلة" (Figma 1تعديل … 7تعديل)
/// (عناوين الأسئلة نفسها نصوص شاشات إعداد الرحلة — والشروح هون مكسورة بـ "\n" بنفس سطور Figma)
abstract final class TripEditText {
  static const title = Tx('تعديل تفاصيل الرحلة', 'Edit Trip Details');
  static const reassure = Tx('لا تقلق، يمكنك تعديل أي معلومة أدخلتها هنا', "Don't worry, you can edit any information you entered here");
  static const arrivalMethodDescription = Tx('اختر وسيلة السفر التي ستستخدمها للوصول إلى السعودية.', 'Choose how you will travel to Saudi Arabia.');
  static const entryPortDescription = Tx('اختر منفذ الدخول الذي ستستخدمه للوصول\nإلى السعودية.', 'Choose the entry port you will use to reach Saudi Arabia.');
  static const routeDescription = Tx(
    'أضف المدن التي ستزورها بالترتيب لنساعدك في\nالتنقل والاستعداد لكل مرحلة من رحلتك.',
    'Add the cities you will visit, in order, so we can help you at every stage.',
  );
  static const departureDescription = Tx(
    'يرجى إدخال تاريخ ووقت انطلاقك لنتمكن من\nتنبيهك بخطوات الإحرام في الوقت المناسب.',
    'Enter your departure date and time for timely ihram reminders.',
  );
  static const firstDestination = Tx('وجهتك الاولى', 'Your first destination');
  static const nextDestination = Tx('وجهتك التالية', 'Your next destination');
  static const addStop = Tx('+ إضافة محطة', '+ Add a stop');
  static const canChangeLater = Tx('يمكنك تعديل الموعد لاحقًا إذا تغيرت خطتك.', 'You can change the time later if your plans change.');
  static const chooseDeparture = Tx('يرجى اختيار تاريخ ووقت الانطلاق للمتابعة', 'Please choose the departure date and time to continue');
}
