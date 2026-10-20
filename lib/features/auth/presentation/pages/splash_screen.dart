import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';

// 1. شاشة البداية (Splash Screen)
// بعد 3 ثواني بتفتح الشاشة المناسبة حسب التقدم المحفوظ (شوف AuthController.initialScreen):
// حساب مسجّل → الرئيسية | شاف الترحيب → اختيار اللغة/الدخول | أول مرة → شاشات الترحيب
// -------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _openNextScreen();
  }

  Future<void> _openNextScreen() async {
    final results = await Future.wait<Object?>([
      AuthController.initialScreen(),
      Future.delayed(const Duration(seconds: 3)),
    ]);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => results.first! as Widget),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset('assets/images/1.Splash.jpg', fit: BoxFit.cover),
      ),
    );
  }
}
