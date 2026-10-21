import '../../../../core/l10n/tx.dart';

/// نصوص رسائل الدخول وإنشاء الحساب (نتيجة الطلب من السيرفر)
abstract final class AuthMessagesText {
  static const accountVerified = Tx('تم تأكيد الحساب بنجاح!', 'Account verified successfully!');
  static const codeResent = Tx('تم إعادة إرسال الرمز بنجاح', 'The code was resent successfully');
  static const connectionErrorPrefix = Tx('حدث خطأ في الاتصال: ', 'Connection error: ');
  static const errorPrefix = Tx('حدث خطأ: ', 'An error occurred: ');
  static const invalidCode = Tx('رمز التحقق غير صحيح، يرجى المحاولة مجدداً', 'Incorrect verification code, please try again');
  static const loginInvalid = Tx('بيانات الدخول غير صحيحة', 'Incorrect login details');
  static const passwordChanged = Tx('تم تغيير كلمة المرور بنجاح', 'Password changed successfully');
  static const registerFailed = Tx('حدث خطأ أثناء إنشاء الحساب', 'Something went wrong while creating the account');
  static const resendFailedPrefix = Tx('تعذر إعادة إرسال الرمز: ', 'Could not resend the code: ');
  static const resetFailed = Tx('فشل في إعادة تعيين كلمة المرور', 'Failed to reset the password');
  static const sendCodeFailed = Tx('حدث خطأ أثناء إرسال الرمز', 'Something went wrong while sending the code');

  // الدخول بـ Google (مش بـ Figma)
  static const googleNotReady = Tx('الدخول عبر Google لسا مش مفعّل، جرّب لاحقاً', "Google sign-in isn't enabled yet, try again later");
  static const googleEmailNotVerified = Tx('بريد حساب Google غير مؤكد', 'Your Google email is not verified');
  static const googleFailed = Tx('تعذّر الدخول عبر Google، حاول مرة أخرى', "Couldn't sign in with Google, please try again");
  static const accountDisabled = Tx('هذا الحساب موقوف، تواصل مع الإدارة', 'This account is disabled, please contact support');
  static const supervisorSuspended = Tx('حسابك كمشرف موقوف من الشركة، تواصل معها', 'Your supervisor account is suspended by your company');
  static const emailNotConfirmed = Tx('البريد الإلكتروني غير مؤكد بعد', 'Your email is not confirmed yet');
  static const codeExpired = Tx('انتهت صلاحية الرمز، اطلب رمزاً جديداً', 'The code has expired, request a new one');
  static const weakOrInvalid = Tx('كلمة المرور الجديدة غير مقبولة: 8 أحرف على الأقل وفيها حرف كبير وصغير ورقم ورمز', 'The new password is not accepted: at least 8 characters with upper and lower case, a number and a symbol');
  static const changeFailed = Tx('تعذّر تغيير كلمة المرور، حاول مرة أخرى', "Couldn't change the password, please try again");
  static const dashboardOnly = Tx('هذا الحساب للوحة التحكم على الويب فقط', 'This account is for the web dashboard only');
}
