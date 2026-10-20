import '../../../../core/l10n/tx.dart';

/// نصوص "Success Screen" (Figma 176:6844) بعد حفظ تفاصيل الرحلة — الرسالة بنفس سطور Figma
abstract final class TripSuccessText {
  static const title = Tx('تمت إضافة التفاصيل بنجاح!', 'Details added successfully!');
  static const message = Tx(
    'يمكنك الآن متابعة مرحلة استعدادك، تصفح الأدعية،\nوإدارة رحلتك بسهولة من الشاشة الرئيسية',
    'You can now follow your preparation, browse duas, and manage your trip from home.',
  );
  static const goHome = Tx('الذهاب للرئيسية', 'Go to home');
}
