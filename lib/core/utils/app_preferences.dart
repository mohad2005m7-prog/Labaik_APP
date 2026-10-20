import 'package:shared_preferences/shared_preferences.dart';

// -------------------------------------------------------------
// AppPreferences
// إعدادات التطبيق المحفوظة على جهاز المستخدم (نفس فكرة TokenStorage):
// - هل شاف شاشات الترحيب (Onboarding) — بتظهر أول مرة بس
// - اللغة اللي اختارها بشاشة اختيار اللغة
// - مفتاح الإشعارات بإعدادات المشرف (نوع الحساب نفسه بـ AccountRegistry — مربوط بالحساب)
// -------------------------------------------------------------
class AppPreferences {
  static const _onboardingSeenKey = 'onboarding_seen';
  static const _languageKey = 'app_language';

  static Future<bool> isOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingSeenKey) ?? false;
  }

  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSeenKey, true);
  }

  /// اللغة اللي اختارها المستخدم (null = لسا ما اختار)
  static Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  /// مفتاح "إعدادات الإشعارات" بشاشة الإعدادات (مفعّل افتراضياً)
  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  static const _notificationsKey = 'notifications_enabled';

  /// "تذكرني" بشاشة تسجيل الدخول: الإيميل بيضل مكتوب المرة الجاية (null = ما بدو)
  static Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rememberedEmailKey);
  }

  static Future<void> setRememberedEmail(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    email == null ? await prefs.remove(_rememberedEmailKey) : await prefs.setString(_rememberedEmailKey, email);
  }

  static const _rememberedEmailKey = 'remembered_email';
}
