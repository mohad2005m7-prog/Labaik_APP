import '../../../../core/l10n/tx.dart';

/// نصوص شاشة تعديل البيانات الشخصية (المعتمر)
abstract final class EditPilgrimProfileText {
  static const title = Tx('تعديل البيانات الشخصية', 'Edit personal data');
  static const fullName = Tx('الاسم الكامل', 'Full name');
  static const fullNameHint = Tx('مثال:أحمد موسى', 'e.g. Ahmad Mousa');
  static const phone = Tx('رقم الهاتف', 'Phone number');
  static const phoneHint = 'xxxxxxxxxx';
  static const email = Tx('البريد الالكتروني', 'Email');
  static const emailHint = 'example123@gmail.com';
  static const gender = Tx('الجنس', 'Gender');
  static const male = Tx('ذكر', 'Male');
  static const female = Tx('أنثى', 'Female');
  static const save = Tx('حفظ التغييرات', 'Save changes');
  static const saved = Tx('تم حفظ التغييرات', 'Changes saved');
  static const errorName = Tx('يرجى كتابة الاسم', 'Please enter your name');
  static const errorEmail = Tx('يرجى إدخال بريد إلكتروني صحيح', 'Please enter a valid email');
  static const errorPhone = Tx('يرجى إدخال رقم هاتف صحيح', 'Please enter a valid phone number');
  static const photoCamera = Tx('التقاط صورة', 'Take a photo');
  static const photoGallery = Tx('اختيار من المعرض', 'Choose from gallery');
  static const photoRemove = Tx('حذف الصورة', 'Remove photo');
  static const photoError = Tx('تعذّر فتح الكاميرا أو المعرض', "Couldn't open the camera or gallery");
}
