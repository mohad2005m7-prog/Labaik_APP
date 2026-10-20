import '../../../../core/l10n/tx.dart';

/// نصوص رسائل وضع الميدان المشتركة
abstract final class FieldModeText {
  static const chooseIhramStatus = Tx('يرجى اختيار حالة الإحرام للمتابعة', 'Please select your ihram status to continue');
  static const locating = Tx('جارٍ تحديد موقعك...', 'Finding your location...');
  static const locationNeeded = Tx('فعّل الموقع حتى نرشدك إلى وجهتك.', 'Turn on location so we can guide you to your destination.');
  static const lostAlertSent = Tx(
    'أرسلنا تنبيه "أنا ضائع" مع موقعك، وحدّثنا المسار من موقعك الحالي.',
    "We sent an \"I'm lost\" alert with your location and updated the route from where you are.",
  );
  static const lostRerouted = Tx('تم تحديث المسار من موقعك الحالي.', 'Route updated from your current location.');
  static const myLocation = Tx('موقعي', 'My location');
  static const compass = Tx('البوصلة (الشمال)', 'Compass (north)');
}
