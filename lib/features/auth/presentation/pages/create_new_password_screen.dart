import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/password_rules.dart';
import '../controllers/auth_controller.dart';
import '../l10n/new_password_text.dart';
import '../widgets/auth_icons.dart';
import '../widgets/auth_widgets.dart';
import 'reset_password_screen.dart';

// -------------------------------------------------------------
// 10.Reset Your Password "تغيير كلمة المرور" — مطابقة لـ Figma (87:5963)
// - بعد رمز التحقق ([code]): كلمة المرور الجديدة وتأكيدها ← "تحديث كلمة المرور" ← تسجيل الدخول
//   (حقل "كلمة المرور الحالية" موجود زي Figma، بس استعادة كلمة المرور بالرمز ما بتحتاجه)
// - [CreateNewPasswordScreen.change]: الحالية + الجديدة (POST /auth/change-password)
//   [forced] = أول دخول بكلمة مرور مؤقتة: لازم يغيّرها (بلا رجوع — بداله "تسجيل الخروج")
//   و[knownPassword] = المؤقتة اللي كتبها بالدخول (بتنكتب لحالها بالحقل)
// -------------------------------------------------------------
class CreateNewPasswordScreen extends StatefulWidget {
  final String email;
  final String? code;
  final bool forced;
  final String? knownPassword;

  const CreateNewPasswordScreen({super.key, required this.email, required String this.code})
      : forced = false,
        knownPassword = null;

  const CreateNewPasswordScreen.change({super.key, this.forced = false, this.knownPassword})
      : email = '',
        code = null;

  bool get isChange => code == null;

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  late final _current = TextEditingController(text: widget.knownPassword);
  final _newPassword = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_current, _newPassword, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  void _update() {
    FocusScope.of(context).unfocus();
    final change = widget.isChange;
    final error = change && _current.text.isEmpty
        ? NewPasswordText.enterCurrentPassword()
        : _newPassword.text.isEmpty
        ? NewPasswordText.enterNewPassword()
        : !PasswordRules.isStrong(_newPassword.text)
            ? NewPasswordText.weakPassword()
            : _confirm.text.isEmpty
                ? NewPasswordText.enterConfirmPassword()
                : _confirm.text != _newPassword.text
                    ? NewPasswordText.passwordsMismatch()
                    : change && _newPassword.text == _current.text
                        ? NewPasswordText.sameAsCurrent()
                        : null;
    if (error != null) {
      AuthController.showMessage(context, error);
      return;
    }
    if (change) {
      AuthController.changePassword(
        context: context,
        currentPassword: _current.text,
        newPassword: _newPassword.text,
        forced: widget.forced,
        setLoading: (value) => setState(() => _loading = value),
      );
      return;
    }
    AuthController.resetPassword(
      context: context,
      email: widget.email,
      code: widget.code!,
      newPassword: _newPassword.text,
      setLoading: (value) => setState(() => _loading = value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: !widget.forced, child: _page(context));
  }

  Widget _page(BuildContext context) {
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
        final forced = widget.forced;
        return [
          if (!forced) authBack(c, context),
          authLogo(c, left: 145, top: 118),
          authTitle(c, NewPasswordText.title(), left: 107, top: 257, width: 175, align: TextAlign.start),
          if (forced) c.text(NewPasswordText.temporaryNote(), left: 16, top: 305, width: 360, height: 34, align: TextAlign.center, dy: 0, style: authText(c, 13, FigmaWeight.sfRegular, AuthColors.grey)),

          // Frame 444
          field(348, _current, NewPasswordText.currentPassword()),
          // "نسيت كلمة المرور؟" (وبالتغيير الإجباري: "تسجيل الخروج")
          c.text(forced ? NewPasswordText.signOut() : NewPasswordText.forgotPassword(), left: 250, top: 398, width: 126, height: 19, dy: 0, style: note),
          c.tapArea(
            left: 250,
            top: 394,
            width: 126,
            height: 30,
            onTap: forced
                ? () => AuthController.signOutToWelcome(context)
                : widget.isChange
                    ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordScreen()))
                    : () => Navigator.maybePop(context),
          ),
          field(445, _newPassword, NewPasswordText.newPassword()),
          c.text(NewPasswordText.rule(), left: 120, top: 496, width: 256, height: 19, dy: 0, style: note),
          field(542, _confirm, NewPasswordText.confirmPassword(), last: true),

          authButton(c, NewPasswordText.update(), left: 16, top: 626, width: 358, loading: _loading, onTap: _update),
        ];
      },
    );
  }
}
