import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../l10n/welcome_text.dart';
import '../widgets/auth_widgets.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'signup_screen.dart';

// -------------------------------------------------------------
// 5.SignUp/Login — مطابقة لـ Figma (18:835)
// مفتاح اللغة (AR/EN) — الشعار — "لَبيــك" والوصف — إنشاء حساب جديد / تسجيل الدخول
// -------------------------------------------------------------
class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  // الرجوع: للشاشة اللي قبلها (شاشات الترحيب) — ولو فاتح التطبيق عليها مباشرة بترجع شاشات الترحيب
  void _back(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      builder: (c) => [
        c.rect(left: 16, top: 92, width: 75, height: 33, child: AuthLanguageToggle(s: c.s)),
        authBack(c, context, onTap: () => _back(context)),
        authLogo(c, left: 145, top: 104),
        authTitle(c, WelcomeText.appName(), left: 165.33, top: 261, width: 64),
        // SF Compact 656 16 أسود بالنص — 3 سطور زي Figma
        c.text(
          WelcomeText.description(),
          left: 14,
          top: 321,
          width: 360,
          height: 57,
          align: TextAlign.center,
          dy: 0,
          style: authText(c, 16, FigmaWeight.sfSemibold, Colors.black),
        ),
        authButton(c, WelcomeText.createAccount(), left: 16, top: 391, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()))),
        authButton(c, WelcomeText.login(), left: 16, top: 457, outlined: true, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()))),
      ],
    );
  }
}
