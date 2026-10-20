import '../../../../core/l10n/tx.dart';

/// نصوص شاشة تغيير كلمة المرور (10.Reset Your Password)
abstract final class NewPasswordText {
  static const title = Tx('تغيير كلمة المرور', 'Change password');
  static const currentPassword = Tx('كلمة المرور الحالية', 'Current password');
  static const forgotPassword = Tx('نسيت كلمة المرور؟', 'Forgot password?');
  static const newPassword = Tx('كلمة المرور الجديدة', 'New password');
  static const rule = Tx('8 أحرف على الأقل، رقم، وحرف كبير', 'At least 8 characters, a number and a capital letter');
  static const confirmPassword = Tx('تأكيد كلمة المرور الجديدة', 'Confirm the new password');
  static const update = Tx('تحديث كلمة المرور', 'Update password');
  static const enterNewPassword = Tx('يرجى إدخال كلمة المرور الجديدة', 'Please enter the new password');
  static const weakPassword = Tx('كلمة المرور لازم تكون 8 أحرف على الأقل وفيها رقم وحرف كبير', 'The password needs at least 8 characters, a number and a capital letter');
  static const enterConfirmPassword = Tx('يرجى تأكيد كلمة المرور الجديدة', 'Please confirm the new password');
  static const passwordsMismatch = Tx('كلمتا المرور غير متطابقتين', 'Passwords do not match');

  // تغيير كلمة المرور وأنا داخل (والإجباري بعد كلمة مرور مؤقتة)
  static const enterCurrentPassword = Tx('يرجى إدخال كلمة المرور الحالية', 'Please enter the current password');
  static const sameAsCurrent = Tx('كلمة المرور الجديدة لازم تختلف عن الحالية', 'The new password must differ from the current one');
  static const wrongCurrent = Tx('كلمة المرور الحالية غير صحيحة', 'The current password is incorrect');
  static const temporaryNote = Tx('تم إنشاء حسابك بكلمة مرور مؤقتة، يرجى تغييرها للمتابعة', 'Your account has a temporary password. Please change it to continue');
  static const signOut = Tx('تسجيل الخروج', 'Sign out');
}
