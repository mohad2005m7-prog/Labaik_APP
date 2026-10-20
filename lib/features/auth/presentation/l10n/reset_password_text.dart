import '../../../../core/l10n/tx.dart';

/// نصوص شاشة إعادة تعيين كلمة المرور (9.Reset Your Password)
abstract final class ResetPasswordText {
  static const title = Tx('إعادة تعيين كلمة مرورك', 'Reset your password');
  static const send = Tx('إرسال رمز إعادة التعيين', 'Send reset code');
  static const remembered = Tx('تذكرت كلمة السر؟ ', 'Remembered your password? ');
  static const login = Tx('تسجيل الدخول', 'Log in');
}
