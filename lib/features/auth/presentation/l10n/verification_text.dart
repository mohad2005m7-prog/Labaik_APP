import '../../../../core/l10n/tx.dart';

/// نصوص شاشة رمز التحقق (7.Write Code)
abstract final class VerificationText {
  static const title = Tx('تأكيد الحساب', 'Verify your account');
  static const subtitle = Tx('أدخل رمز التحقق', 'Enter the verification code');
  static const description = Tx(
    'أدخل الرمز المكون من 6 أرقام الذي تم\nإرساله إلى البريد الإلكتروني المسجل.',
    'Enter the 6-digit code that was sent to your registered email.',
  );
  static const confirm = Tx('تأكيد', 'Confirm');
  static const enterFullCode = Tx('يرجى إدخال رمز التحقق كاملاً (6 أرقام)', 'Please enter the full verification code (6 digits)');
  static const resendIn = Tx('إعادة إرسال الرمز خلال ', 'Resend the code in ');
  static String seconds(Object n) => tr('$n ثانية', '$n seconds');
  static const resendCode = Tx('إعادة إرسال الرمز', 'Resend the code');
}
