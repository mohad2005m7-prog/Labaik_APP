import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_translation.dart';
import 'features/auth/presentation/pages/splash_screen.dart';

void main() {
  runApp(const LabaikApp());
}

class LabaikApp extends StatelessWidget {
  const LabaikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: currentLanguage,
      builder: (context, lang, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Labaik',
          theme: AppTheme.light,
          // مهم: نحط الاتجاه هون بالـ builder حتى ينطبق على كل شاشة
          // بالتطبيق (كل الـ Navigator.push) مش بس أول شاشة (السبلاش).
          builder: (context, child) {
            return Directionality(
              textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            );
          },
          home: const SplashScreen(),
        ); // MaterialApp
      },
    ); // ValueListenableBuilder
  }
}
