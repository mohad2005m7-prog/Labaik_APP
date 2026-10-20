import 'package:flutter/widgets.dart';

import '../utils/app_preferences.dart';

// -------------------------------------------------------------
// لغة التطبيق (ar / en):
// أول تشغيل بتكون لغة الجهاز، وبعدها اللي اختارها المستخدم (محفوظة).
// تغييرها بيعيد بناء كل الشاشات المفتوحة بالنصوص الجديدة (LabaikApp بـ main.dart)
// -------------------------------------------------------------
abstract final class AppLanguage {
  static final ValueNotifier<String> notifier = ValueNotifier('ar');

  static String get code => notifier.value;
  static bool get isArabic => notifier.value == 'ar';
  static TextDirection get direction => isArabic ? TextDirection.rtl : TextDirection.ltr;

  /// لغة جهاز المستخدم: عربي → ar، أي لغة ثانية → en
  static String get device => WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'ar' ? 'ar' : 'en';

  /// عند تشغيل التطبيق
  static Future<void> load() async => notifier.value = await AppPreferences.getLanguage() ?? device;

  /// اختيار لغة (شاشة اللغة / الإعدادات) — بتنحفظ وبتتطبق فوراً
  static Future<void> change(String language) async {
    notifier.value = language;
    await AppPreferences.saveLanguage(language);
  }
}
