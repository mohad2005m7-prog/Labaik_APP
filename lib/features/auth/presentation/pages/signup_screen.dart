import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/figma_text.dart';
import '../controllers/auth_controller.dart';
import '../controllers/google_sign_in_controller.dart';
import '../l10n/auth_form_text.dart';
import '../l10n/signup_text.dart';
import '../widgets/auth_icons.dart';
import '../widgets/auth_widgets.dart';
import 'login_screen.dart';

// -------------------------------------------------------------
// 6.SignUp — مطابقة لـ Figma (18:893)
// الاسم، البريد، رقم الهاتف، كلمة المرور + الموافقة على الشروط ← إنشاء حساب ← رمز التحقق ← نوع الحساب
// -------------------------------------------------------------
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _confirm = TextEditingController();
  final _password = TextEditingController();
  bool _acceptedTerms = false;
  bool _loading = false;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  // أول خطأ بيطلع برسالة (Figma ما فيه مكان لرسائل تحت الحقول)
  String? _error() {
    final name = _name.text.trim();
    if (name.isEmpty) return SignupText.enterFullName();
    if (name.length < 3) return SignupText.invalidFullName();
    if (_email.text.trim().isEmpty) return AuthFormText.enterEmail();
    if (!_emailPattern.hasMatch(_email.text.trim())) return AuthFormText.invalidEmail();
    if (_password.text.isEmpty) return AuthFormText.enterPassword();
    if (_password.text.length < 6) return SignupText.invalidPassword();
    if (_confirm.text != _password.text) return SignupText.passwordsMismatch();
    if (!_acceptedTerms) return SignupText.acceptTerms();
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final error = _error();
    if (error != null) {
      AuthController.showMessage(context, error);
      return;
    }
    AuthController.register(
      context: context,
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      setLoading: (value) => setState(() => _loading = value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      builder: (c) {
        final s = c.s;
        Widget field(double top, TextEditingController controller, String hint, Widget icon, {bool password = false, TextInputType? type, List<TextInputFormatter>? formatters, Iterable<String>? autofill, bool last = false}) {
          return c.rect(
            left: 17,
            top: top,
            width: 360,
            height: 46,
            child: AuthField(
              s: s,
              controller: controller,
              hint: hint,
              icon: icon,
              password: password,
              keyboardType: type,
              inputFormatters: formatters,
              autofillHints: autofill,
              textInputAction: last ? TextInputAction.done : TextInputAction.next,
            ),
          );
        }

        final grey = authText(c, 15, FigmaWeight.sfRegular, AuthColors.grey);
        return [
          authBack(c, context),
          authLogo(c, left: 139.97, top: 104),
          authTitle(c, SignupText.title(), left: 101, top: 261, width: 191),

          field(321, _name, SignupText.fullName(), authPersonIcon(s), type: TextInputType.name, formatters: [FilteringTextInputFormatter.allow(RegExp(r'[؀-ۿa-zA-Z\s]'))], autofill: const [AutofillHints.name]),
          field(383, _email, AuthFormText.email(), AuthIconView(AuthIcon.mail, size: s.x(24), color: AuthColors.grey), type: TextInputType.emailAddress, autofill: const [AutofillHints.email]),
          // بدل رقم الهاتف (طلب صاحب المشروع): كلمة المرور وتحتها تأكيدها
          field(445, _password, AuthFormText.password(), AuthIconView(AuthIcon.lock, size: s.x(24), color: AuthColors.grey), password: true, autofill: const [AutofillHints.newPassword]),
          field(507, _confirm, SignupText.confirmPassword(), AuthIconView(AuthIcon.lock, size: s.x(24), color: AuthColors.grey), password: true, autofill: const [AutofillHints.newPassword], last: true),

          // أوافق على الشروط والأحكام (Frame 438: المربع 24 بالبداية والنص بعده بـ 7)
          c.rect(left: 350.62, top: 567.5, width: 24, height: 24, child: AuthCheckbox(s: s, value: _acceptedTerms, onChanged: (v) => setState(() => _acceptedTerms = v))),
          c.rich(
            TextSpan(children: [
              TextSpan(text: SignupText.agreeTo(), style: grey),
              TextSpan(text: SignupText.terms(), style: authText(c, 15, FigmaWeight.sfBold, AuthColors.green)),
            ]),
            left: 154,
            top: 568,
            width: 189.62,
            height: 22,
            dy: 0,
          ),
          c.tapArea(left: 154, top: 565, width: 196, height: 29, onTap: () => setState(() => _acceptedTerms = !_acceptedTerms)),

          authButton(c, SignupText.createAccount(), left: 16, top: 606, loading: _loading, onTap: _submit),
          ...authOrDivider(c, AuthFormText.or(), top: 664),
          authGoogleButton(c, top: 694, onTap: () => GoogleSignInController.signIn(context, newAccount: true, setLoading: (value) => setState(() => _loading = value))),

          authLinkLine(
            c,
            text: '${SignupText.haveAccount()} ',
            link: SignupText.login(),
            left: 65,
            top: 756,
            width: 255,
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          ),
        ];
      },
    );
  }
}
