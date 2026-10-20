import '../../../../core/l10n/api_error_text.dart';
import '../../../../core/l10n/tx.dart';

/// رسائل دائرة العائلة (مش بـ Figma): التحقق، النتائج، والأخطاء
abstract final class FamilyMessagesText {
  static const enterCode = Tx('يرجى إدخال رمز المجموعة', 'Please enter the group code');
  static const notFound = Tx('لم نجد دائرة بهذا الرمز، تأكد منه وحاول مرة أخرى', 'No circle with this code, check it and try again');
  static const invalidQr = Tx('رمز QR هذا مش لدائرة عائلة على لبيك', "This QR code isn't a Labaik family circle");
  static const cameraDenied = Tx('اسمح باستخدام الكاميرا لمسح رمز QR، أو أدخل الرمز يدوياً', 'Allow the camera to scan the QR code, or type the code');
  static const locationOff = Tx('فعّل الموقع حتى تقدر عائلتك تشوف موقعك', 'Turn on location so your family can see you');
  static const noLocation = Tx('موقعه غير متاح حالياً', 'Location unavailable right now');
  static const noMeetingPoint = Tx('لم تُحدَّد نقطة تجمع بعد', 'No meeting point yet');
  static const onlyOwner = Tx('صاحب الدائرة بس بيقدر يحذف أفراد', 'Only the circle owner can remove members');
  static const shareFailed = Tx('تعذّر فتح المشاركة', "Couldn't open sharing");
  static const ownCircle = Tx('هذا رمز دائرتك أنت', 'This is your own circle code');
  static const codeCopied = Tx('تم نسخ الرمز', 'Code copied');
  static const sharingOn = Tx('عائلتك تقدر تشوف موقعك الآن', 'Your family can see your location now');
  static const sharingOff = Tx('تم إيقاف مشاركة موقعك', 'Location sharing stopped');
  static const settings = Tx('الإعدادات', 'Settings');

  static Tx forError(Object error) => ApiErrorText.of(error);
}
