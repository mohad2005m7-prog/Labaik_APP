import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../l10n/auth_form_text.dart';
import '../l10n/reset_password_text.dart';
import '../widgets/auth_icons.dart';
import '../widgets/auth_widgets.dart';

// -------------------------------------------------------------
// 9.Reset Your Password — مطابقة لـ Figma (18:1128)
// البريد ← "إرسال رمز إعادة التعيين" ← رمز التحقق ← تغيير كلمة المرور
// -------------------------------------------------------------
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _send() {
    FocusScope.of(context).unfocus();
    final email = _email.text.trim();
    if (email.isEmpty || !_emailPattern.hasMatch(email)) {
      AuthController.showMessage(context, email.isEmpty ? AuthFormText.enterEmail() : AuthFormText.invalidEmail());
      return;
    }
    AuthController.forgotPassword(context: context, email: email, setLoading: (value) => setState(() => _loading = value));
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      builder: (c) {
        final s = c.s;
        return [
          authBack(c, context),
          authLogo(c, left: 145, top: 118),
          authTitle(c, ResetPasswordText.title(), left: 77, top: 260, width: 251, align: TextAlign.start),
          c.rect(
            left: 16,
            top: 336,
            width: 360,
            height: 46,
            child: AuthField(
              s: s,
              controller: _email,
              hint: AuthFormText.email(),
              icon: AuthIconView(AuthIcon.mail, size: s.x(24), color: AuthColors.grey),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.send,
              autofillHints: const [AutofillHints.email],
              onSubmitted: (_) => _send(),
            ),
          ),
          authButton(c, ResetPasswordText.send(), left: 16, top: 401, width: 358, loading: _loading, onTap: _send),
          // "تذكرت كلمة السر؟ تسجيل الدخول" → رجوع لتسجيل الدخول
          authLinkLine(c, text: ResetPasswordText.remembered(), link: ResetPasswordText.login(), left: 101, top: 482, width: 199, height: 17, size: 14, textColor: AuthColors.grey, onTap: () => Navigator.maybePop(context)),
        ];
      },
    );
  }
}
