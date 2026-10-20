import '../../../../core/l10n/api_error_text.dart';
import '../../../../core/l10n/tx.dart';

/// رسائل مركز المساعدة (مش بـ Figma): التحميل، الأخطاء، والحالات اللي ما إلها بيانات
abstract final class HelpMessagesText {
  static const loadingSupervisor = Tx('جاري تحميل بيانات المشرف…', 'Loading your supervisor…');
  static const notLinked = Tx('لم يتم ربطك بمشرف مجموعة بعد', 'You are not linked to a group supervisor yet');
  static const noPhone = Tx('رقم المشرف غير متوفر حالياً', "The supervisor's number isn't available yet");
  static const callFailed = Tx('تعذّر فتح الاتصال على هذا الجهاز', "Couldn't start a call on this device");
  static const sending = Tx('جاري إرسال البلاغ…', 'Sending the report…');
  static const locationDenied = Tx('فعّل الموقع حتى نقدر نرفق موقعك الحالي', 'Turn on location so we can attach your current location');
  static const locationFailed = Tx('تعذّر تحديد موقعك، حاول مرة أخرى', "Couldn't find your location, please try again");
  static const photoFailed = Tx('تعذّر فتح الصور', "Couldn't open photos");
  static const chatUnavailable = Tx('المحادثة مع المشرف غير متاحة حالياً', "The chat with your supervisor isn't available yet");
  static const mapFailed = Tx('تعذّر فتح الخريطة', "Couldn't open the map");
  static const settings = Tx('الإعدادات', 'Settings');

  /// رسالة خطأ السيرفر حسب نوعه (مشتركة — ApiErrorText)
  static Tx forError(Object error) => ApiErrorText.of(error);
}
