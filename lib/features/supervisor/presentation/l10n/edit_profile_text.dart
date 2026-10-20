import '../../../../core/l10n/tx.dart';

/// نصوص شاشة تعديل البيانات الشخصية
abstract final class EditProfileText {
  static const fullName = Tx('الاسم كامل', 'Full name');
  static const email = Tx('البريد الإلكتروني', 'Email address');
  static const phone = Tx('رقم الهاتف', 'Phone number');
  static const saveChanges = Tx('حفظ التغييرات', 'Save changes');
  static const saved = Tx('تم حفظ التغييرات', 'Changes saved');
  static const errorName = Tx('يرجى كتابة الاسم', 'Please enter your name');
  static const errorEmail = Tx('يرجى إدخال بريد إلكتروني صحيح', 'Please enter a valid email address');
  static const errorPhone = Tx('يرجى إدخال رقم هاتف صحيح', 'Please enter a valid phone number');
}
