// -------------------------------------------------------------
// شروط كلمة المرور — نفس شروط السيرفر بالضبط (ASP.NET Identity: 8 أحرف على الأقل، حرف كبير، حرف صغير، رقم، ورمز)
// لو التطبيق قبل كلمة مرور السيرفر بيرفضها: بإنشاء الحساب بيفشل، وبنسيت كلمة المرور بيروح الرمز على الفاضي
// (الحروف العربية بتنحسب حروف مش رموز، زي السيرفر)
// -------------------------------------------------------------
abstract final class PasswordRules {
  static final _upper = RegExp(r'\p{Lu}', unicode: true);
  static final _lower = RegExp(r'\p{Ll}', unicode: true);
  static final _digit = RegExp(r'\p{Nd}', unicode: true);
  static final _symbol = RegExp(r'[^\p{L}\p{N}]', unicode: true);

  static bool isStrong(String password) =>
      password.length >= 8 && _upper.hasMatch(password) && _lower.hasMatch(password) && _digit.hasMatch(password) && _symbol.hasMatch(password);
}
