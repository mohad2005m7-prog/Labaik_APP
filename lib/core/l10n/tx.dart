import 'app_language.dart';

export 'app_language.dart';

/// نص بلغتين — كل شاشة إلها ملف نصوص (l10n/*_text.dart) فيه نصوصها بس:
///   static const title = Tx('تسجيل الدخول', 'Log In');
///   Text(LoginText.title())   ← بيرجع نسخة اللغة الحالية وقت بناء الشاشة
class Tx {
  final String ar;
  final String en;

  const Tx(this.ar, this.en);

  String call() => of(AppLanguage.code);

  /// بلغة معيّنة (مثلاً معاينة اللغة بشاشة اختيار اللغة قبل ما تتطبق)
  String of(String language) => language == 'ar' ? ar : en;
}

/// نص فيه قيم (اسم، رقم، وقت...) — للدوال بملفات النصوص:
///   static String greeting(Object name) => tr('السلام عليكم، $name', 'Assalamu Alaikum, $name');
String tr(String ar, String en) => AppLanguage.isArabic ? ar : en;
