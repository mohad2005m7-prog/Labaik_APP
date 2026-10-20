import '../../../../core/l10n/tx.dart';

/// نصوص شاشة "الشروط والأحكام" (Figma 112:3451) — العربي حرفياً من Figma و"\n" مكان كسر سطوره
/// (العنوان الأخضر بأول كل فقرة لحاله، والنص بعده بمسافاته متل Figma)
abstract final class TermsText {
  static const title = Tx('الشروط والأحكام', 'Terms & Conditions');

  // التبويبات
  static const tabTerms = Tx('الشروط والأحكام', 'Terms & Conditions');
  static const tabPrivacy = Tx('سياسة الخصوصية', 'Privacy Policy');
  static const tabRefund = Tx('سياسة الاسترجاع', 'Refund Policy');

  // الشروط والأحكام
  static const introLabel = Tx('المقدمة:', 'Introduction:');
  static const intro = Tx(
    ' باستخدامك لتطبيق لَبَّيك، فإنك توافق\nعلى الالتزام بالشروط والأحكام الموضحة، والتي تنظم\nاستخدام الخدمات المتاحة للمعتمرين والزوار\nوتسهيل تنظيم الرحلات العائلية والجماعية عبر\nالمنصة.',
    ' By using Labbaik, you agree to these terms and conditions, which govern the services for Umrah pilgrims and visitors and make family and group trips easier to organize.',
  );
  static const dutiesLabel = Tx('المسؤوليات:', 'Responsibilities:');
  static const duties = Tx(
    '  يلتزم التطبيق بتقديم إرشادات\nدقيقة للمعتمر، ويحق للمستخدم تقديم أي استفسار\nأو ملاحظة عبر الدعم الفني.',
    ' The app gives pilgrims accurate guidance, and users can send any question or feedback via support.',
  );

  // سياسة الخصوصية
  static const dataLabel = Tx('جمع البيانات:', 'Data collection:');
  static const data = Tx(
    '  نقوم بجمع معلوماتك الأساسية\n(مثل الاسم، رقم الهاتف، والموقع) فقط بالقدر اللازم\nلتحسين تجربة متابعة الرحلة وتسهيل التواصل مع\nالمجموعة.',
    ' We collect basic information (name, phone number and location) only as needed to improve trip tracking and group communication.',
  );
  static const protectionLabel = Tx('حماية المعلومات:', 'Information protection:');
  static const protection = Tx(
    ' نلتزم بالحفاظ على سرية بياناتك\nوعدم مشاركتها مع أي طرف ثالث إلا بالقدر الذي\nيتطلبه تقديم الخدمة أو بناءً على القوانين المعمول\nبها.',
    ' We keep your data confidential and never share it with a third party, except as the service requires or as applicable law demands.',
  );

  // سياسة الاسترجاع
  static const cancelLabel = Tx('إلغاء الطلب:', 'Cancelling a request:');
  static const cancel = Tx(
    ' يمكن للمعتمر إلغاء البلاغ المباشر\nوإيقاف التنبيه فور العثور على الطفل المفقود.',
    ' Pilgrims can cancel a live report and stop the alert as soon as the missing child is found.',
  );
  static const refundLabel = Tx('استرداد الأموال:', 'Refunds:');
  static const refund = Tx(
    ' يُتاح للمستخدم متابعة حالة البلاغ\nالجارية أو إنهاء التتبع في أي وقت بضغطة زر.',
    ' Users can follow an ongoing report or end tracking at any time with one tap.',
  );
}
