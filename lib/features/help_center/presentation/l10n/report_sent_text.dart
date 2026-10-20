import '../../../../core/l10n/tx.dart';

/// نصوص رسالة "تم إرسال البلاغ بنجاح!" (Figma 181:7354) — بنفس سطور Figma
abstract final class ReportSentText {
  static const title = Tx('تم إرسال البلاغ بنجاح!', 'Report sent successfully!');
  static const message = Tx(
    'تم تعميم معلومات الطفل المفقود على المشرف\nوالمستخدمين القريبين منك لتقديم المساعدة في أسرع\nوقت',
    "The lost child's details were shared with the supervisor and nearby users so they can help as soon as possible",
  );
  static const confirm = Tx('تأكيد', 'Confirm');
}
