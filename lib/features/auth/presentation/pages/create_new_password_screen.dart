import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../controllers/auth_controller.dart';
import '../l10n/new_password_text.dart';
import '../widgets/auth_icons.dart';
import '../widgets/auth_widgets.dart';

// -------------------------------------------------------------
// 10.Reset Your Password "تغيير كلمة المرور" — مطابقة لـ Figma (87:5963)
// بعد رمز التحقق: كلمة المرور الجديدة وتأكيدها ← "تحديث كلمة المرور" ← تسجيل الدخول
// حقل "كلمة المرور الحالية" موجود زي Figma، بس استعادة كلمة المرور بالرمز ما بتحتاجه (فما بنطلبه)
// -------------------------------------------------------------
class CreateNewPasswordScreen extends StatefulWidget {
  final String email;
  final String code;

  const CreateNewPasswordScreen({super.key, required this.email, required this.code});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _current = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  // 8 أحرف على الأقل، رقم، وحرف كبير
  static final _strong = RegExp(r'^(?=.*[0-9])(?=.*[A-Z]).{8,}$');

  @override
  void dispose() {
    for (final c in [_current, _newPassword, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  void _update() {
    FocusScope.of(context).unfocus();
    final error = _newPassword.text.isEmpty
        ? NewPasswordText.enterNewPassword()
        : !_strong.hasMatch(_newPassword.text)
            ? NewPasswordText.weakPassword()
            : _confirm.text.isEmpty
                ? NewPasswordText.enterConfirmPassword()
                : _confirm.text != _newPassword.text
                    ? NewPasswordText.passwordsMismatch()
                    : null;
    if (error != null) {
      AuthController.showMessage(context, error);
      return;
    }
    AuthController.resetPassword(
      context: context,
      email: widget.email,
      code: widget.code,
      newPassword: _newPassword.text,
      setLoading: (value) => setState(() => _loading = value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      builder: (c) {
        final s = c.s;
        Widget field(double top, TextEditingController controller, String hint, {bool last = false}) => c.rect(
              left: 16,
              top: top,
              width: 360,
              height: 46,
              child: AuthField(
                s: s,
                controller: controller,
                hint: hint,
                icon: AuthIconView(AuthIcon.lock, size: s.x(24), color: AuthColors.grey),
                password: true,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: last ? TextInputAction.done : TextInputAction.next,
                onSubmitted: last ? (_) => _update() : null,
              ),
            );
        final note = authText(c, 14, FigmaWeight.sfSemibold, AuthColors.green);
        return [
          authBack(c, context),
          authLogo(c, left: 145, top: 118),
          authTitle(c, NewPasswordText.title(), left: 107, top: 257, width: 175, align: TextAlign.start),

          // Frame 444
          field(348, _current, NewPasswordText.currentPassword()),
          c.text(NewPasswordText.forgotPassword(), left: 250, top: 398, width: 126, height: 19, dy: 0, style: note),
          c.tapArea(left: 250, top: 394, width: 126, height: 30, onTap: () => Navigator.maybePop(context)),
          field(445, _newPassword, NewPasswordText.newPassword()),
          c.text(NewPasswordText.rule(), left: 120, top: 496, width: 256, height: 19, dy: 0, style: note),
          field(542, _confirm, NewPasswordText.confirmPassword(), last: true),

          authButton(c, NewPasswordText.update(), left: 16, top: 626, width: 358, loading: _loading, onTap: _update),
        ];
      },
    );
  }
}
