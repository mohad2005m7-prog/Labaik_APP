import '../../../../core/l10n/tx.dart';

/// نصوص شاشة إنشاء حساب جديد (6.SignUp)
abstract final class SignupText {
  static const title = Tx('إنشاء حساب جديد', 'Create a new account');
  static const fullName = Tx('الاسم كامل', 'Full name');
  static const agreeTo = Tx('أوافق على ', 'I agree to the ');
  static const terms = Tx('الشروط والأحكام', 'Terms & Conditions');
  static const createAccount = Tx('إنشاء حساب', 'Create account');
  static const haveAccount = Tx('هل لديك حساب بالفعل؟', 'Already have an account?');
  static const login = Tx('تسجيل الدخول', 'Log in');
  static const enterFullName = Tx('يرجى إدخال الاسم كامل', 'Please enter your full name');
  static const invalidFullName = Tx('الاسم يجب أن يكون 3 أحرف على الأقل', 'Name must be at least 3 characters');
  static const invalidPassword = Tx('كلمة المرور يجب أن تكون 6 أحرف على الأقل', 'Password must be at least 6 characters');
  static const confirmPassword = Tx('تأكيد كلمة المرور', 'Confirm password');
  static const passwordsMismatch = Tx('كلمتا المرور غير متطابقتين', "Passwords don't match");
  static const acceptTerms = Tx('يرجى الموافقة على الشروط والأحكام', 'Please accept the Terms & Conditions');
}
