import '../../../../core/l10n/tx.dart';

/// نصوص شاشة تسجيل الدخول (8.Login)
abstract final class LoginText {
  static const title = Tx('تسجيل الدخول', 'Log in');
  static const forgotPassword = Tx('نسيت كلمة المرور؟', 'Forgot password?');
  static const rememberMe = Tx('تذكرني', 'Remember me');
  static const login = Tx('تسجيل الدخول', 'Log in');
  static const noAccount = Tx('ليس لديك حساب؟', "Don't have an account? ");
  static const createAccount = Tx('إنشاء حساب جديد', 'Create a new account');
}
