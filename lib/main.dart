import 'package:flutter/material.dart';

import 'core/l10n/app_language.dart';
import 'core/network/session_events.dart';
import 'core/l10n/language_builder.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/pages/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // اللغة: اللي اختارها المستخدم قبل، وإذا لسا ما اختار → لغة جهازه
  // (فشاشات الترحيب بتطلع عربي يمين لشمال أو إنجليزي شمال ليمين حسب الجهاز)
  await AppLanguage.load();
  // الجلسة انتهت من السيرفر → الشاشة الصح (بدل شاشات فاضية)
  SessionEvents.handler = AuthController.onSessionEnded;
  runApp(const LabaikApp());
}

class LabaikApp extends StatelessWidget {
  const LabaikApp({super.key});

  @override
  Widget build(BuildContext context) {
    // تغيير اللغة بيعيد بناء كل الشاشات بالنصوص والاتجاه الجديد (LanguageBuilder)
    return LanguageBuilder(
      builder: (context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: SessionEvents.navigatorKey,
        title: 'Labaik',
        theme: AppTheme.light,
        // مهم: نحط الاتجاه هون بالـ builder حتى ينطبق على كل شاشة
        // بالتطبيق (كل الـ Navigator.push) مش بس أول شاشة (السبلاش).
        builder: (context, child) => Directionality(textDirection: AppLanguage.direction, child: child!),
        home: const SplashScreen(),
      ),
    );
  }
}
