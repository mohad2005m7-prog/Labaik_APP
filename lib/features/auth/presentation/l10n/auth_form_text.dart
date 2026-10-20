import '../../../../core/l10n/tx.dart';

/// نصوص مشتركة بين شاشات الدخول وإنشاء الحساب واستعادة كلمة المرور
abstract final class AuthFormText {
  static const email = Tx('البريد الإلكتروني', 'Email');
  static const password = Tx('كلمة المرور', 'Password');
  static const or = Tx('أو', 'or');
  static const googlePrefix = Tx('الدخول عبر ', 'Continue with ');
  static const google = 'Google';
  static const enterEmail = Tx('يرجى إدخال البريد الإلكتروني', 'Please enter your email address');
  static const invalidEmail = Tx('صيغة البريد الإلكتروني غير صحيحة', 'Invalid email format');
  static const enterPassword = Tx('يرجى إدخال كلمة المرور', 'Please enter your password');
}
