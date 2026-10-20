import '../../../../core/l10n/tx.dart';

/// نصوص "نموذج الإبلاغ عن طفل مفقود" (Figma 111:6002) — بنفس سطور Figma
/// (عنوان "وصف الطفل وملابسه" التاني فوق حقل الموقع انشال بطلب صاحب المشروع)
abstract final class LostChildText {
  static const title = Tx('الإبلاغ عن طفل مفقود', 'Report a lost child');
  static const description = Tx('أدخل المعلومات المتوفرة عن الطفل لمساعدة المشرف في متابعة\nالبلاغ.', 'Enter what you know about the child to help the supervisor follow up the report.');
  static const ageLabel = Tx('العمر التقريبي للطفل', "Child's approximate age");
  static const ageHint = Tx('مثال : 7 سنوات', 'e.g. 7 years');
  static const descriptionLabel = Tx('وصف الطفل وملابسه', 'The child and their clothes');
  static const descriptionHint = Tx('لون الملابس وأي تفاصيل تساعد في التعرّف عليه...', 'Clothes colour and any detail that helps identify them...');
  static const locationHint = Tx('حدّد المكان أو أرفق موقعك الحالي', 'Attach your current location');
  static const photoLabel = Tx('صورة الطفل (اختياري)', "Child's photo (optional)");
  static const photoHint = Tx('إرفاق صورة إذا كانت متوفرة', 'Attach a photo if you have one');
  static const note = Tx(
    'أدخل المعلومات الضرورية فقط، وتجنّب مشاركة أرقام الهواتف أو\nعنوان المنزل أو أي تفاصيل شخصية غير لازمة.',
    'Share only what is needed — no phone numbers, home addresses or other personal details.',
  );
  static const send = Tx('إرسال البلاغ للمشرف', 'Send report to supervisor');

  // حالات الحقول بعد الاختيار (مش بـ Figma)
  static const locationAttached = Tx('تم إرفاق موقعك الحالي', 'Your current location is attached');
  static const locating = Tx('جاري تحديد موقعك…', 'Finding your location…');
  static const photoAttached = Tx('تم إرفاق صورة الطفل', "The child's photo is attached");

  // اختيار الصورة
  static const camera = Tx('التقاط صورة', 'Take a photo');
  static const gallery = Tx('اختيار من الصور', 'Choose from photos');
  static const removePhoto = Tx('حذف الصورة', 'Remove photo');

  // التحقق قبل الإرسال
  static const chooseAge = Tx('يرجى اختيار العمر التقريبي للطفل', "Please choose the child's approximate age");
  static const enterDescription = Tx('يرجى كتابة وصف الطفل وملابسه', 'Please describe the child and their clothes');
  static const attachLocation = Tx('يرجى إرفاق موقعك الحالي', 'Please attach your current location');

  /// العمر بالعربي حسب العدد (سنة / سنتان / 3 سنوات / 11 سنة)
  static String age(int years) {
    if (!AppLanguage.isArabic) return years == 1 ? '1 year' : '$years years';
    if (years == 1) return 'سنة واحدة';
    if (years == 2) return 'سنتان';
    if (years <= 10) return '$years سنوات';
    return '$years سنة';
  }
}
