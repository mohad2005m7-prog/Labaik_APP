import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/app_preferences.dart';
import '../controllers/auth_controller.dart';
import '../controllers/google_sign_in_controller.dart';
import '../l10n/auth_form_text.dart';
import '../l10n/login_text.dart';
import '../widgets/auth_icons.dart';
import '../widgets/auth_widgets.dart';
import 'reset_password_screen.dart';
import 'signup_screen.dart';

// -------------------------------------------------------------
// 8.Login — مطابقة لـ Figma (18:1057)
// مفتاح اللغة — البريد وكلمة المرور — نسيت كلمة المرور / تذكرني — تسجيل الدخول — Google — إنشاء حساب جديد
// "تذكرني": الإيميل بيضل مكتوب بالحقل المرة الجاي
// -------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _remember = false;
  bool _loading = false;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    AppPreferences.getRememberedEmail().then((email) {
      if (!mounted || email == null) return;
      setState(() {
        _email.text = email;
        _remember = true;
      });
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    FocusScope.of(context).unfocus();
    final email = _email.text.trim();
    final error = email.isEmpty
        ? AuthFormText.enterEmail()
        : !_emailPattern.hasMatch(email)
            ? AuthFormText.invalidEmail()
            : _password.text.isEmpty
                ? AuthFormText.enterPassword()
                : null;
    if (error != null) {
      AuthController.showMessage(context, error);
      return;
    }
    AppPreferences.setRememberedEmail(_remember ? email : null);
    AuthController.login(
      context: context,
      email: email,
      password: _password.text,
      setLoading: (value) => setState(() => _loading = value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      builder: (c) {
        final s = c.s;
        return [
          c.rect(left: 297, top: 68, width: 75, height: 33, child: AuthLanguageToggle(s: s)),
          authLogo(c, left: 145.47, top: 115),
          authTitle(c, LoginText.title(), left: 119, top: 261, width: 156),

          // Frame 441: الحقلين وبينهم 17
          c.rect(
            left: 17,
            top: 337,
            width: 360,
            height: 46,
            child: AuthField(s: s, controller: _email, hint: AuthFormText.email(), icon: AuthIconView(AuthIcon.mail, size: s.x(24), color: AuthColors.grey), keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email]),
          ),
          c.rect(
            left: 17,
            top: 400,
            width: 360,
            height: 46,
            child: AuthField(
              s: s,
              controller: _password,
              hint: AuthFormText.password(),
              icon: AuthIconView(AuthIcon.lock, size: s.x(24), color: AuthColors.grey),
              password: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _login(),
            ),
          ),

          // نسيت كلمة المرور؟ (بداية السطر) — تذكرني ☐ (نهايته)
          c.text(LoginText.forgotPassword(), left: 255, top: 459, width: 121, height: 19, dy: 0, style: authText(c, 14, FigmaWeight.sfSemibold, AuthColors.green)),
          c.tapArea(left: 250, top: 450, width: 127, height: 37, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordScreen()))),
          // ☐ تذكرني: المربع (61→85) والنص قبله بـ 2 — ملزوقين بنهاية السطر (والإنجليزي الأطول بيمتد لجوّا)
          c.rect(
            left: 16,
            top: 456,
            width: 130,
            height: 26,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _remember = !_remember),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.square(dimension: s.x(24), child: AuthCheckbox(s: s, value: _remember, onChanged: (v) => setState(() => _remember = v))),
                    SizedBox(width: s.x(2)),
                    Text(LoginText.rememberMe(), style: authText(c, 14, FigmaWeight.sfRegular, AuthColors.divider)),
                  ],
                ),
              ),
            ),
          ),

          authButton(c, LoginText.login(), left: 16, top: 513, loading: _loading, onTap: _login),
          ...authOrDivider(c, AuthFormText.or(), top: 570),
          authGoogleButton(c, top: 601, onTap: () => GoogleSignInController.signIn(context, newAccount: false, setLoading: (value) => setState(() => _loading = value))),

          authLinkLine(
            c,
            text: LoginText.noAccount(),
            link: LoginText.createAccount(),
            left: 82,
            top: 672,
            width: 221,
            height: 17,
            size: 14,
            textColor: AuthColors.grey,
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
          ),
        ];
      },
    );
  }
}
