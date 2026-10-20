import '../../../../core/l10n/tx.dart';

/// نصوص شاشة الترحيب (5.SignUp/Login)
abstract final class WelcomeText {
  static const appName = Tx('لَبيــك', 'LABAIK');
  static const description = Tx(
    'رفيق هادئ يرافقك خطوة بخطوة: من الاستعداد\nللسفر، إلى أداء المناسك، وحتى العودة إلى فندقك\nبأمان.',
    'A calm companion, step by step: from getting ready to travel to the rituals and back safely to your hotel.',
  );
  static const createAccount = Tx('إنشاء حساب جديد', 'Create a new account');
  static const login = Tx('تسجيل الدخول', 'Log in');
}
