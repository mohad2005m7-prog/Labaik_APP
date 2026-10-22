import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../controllers/auth_controller.dart';
import '../l10n/verification_text.dart';
import '../widgets/auth_widgets.dart';

// -------------------------------------------------------------
// 7.Write Code — مطابقة لـ Figma (18:1023)
// 6 مربعات للرمز (الكيبورد بيفتح لحاله) — "إعادة إرسال الرمز خلال 55 ثانية" — تأكيد
// إنشاء حساب → نوع الحساب | نسيت كلمة المرور → كلمة المرور الجديدة
// -------------------------------------------------------------
class VerificationCodeScreen extends StatefulWidget {
  final String email;
  final bool isPasswordReset;

  const VerificationCodeScreen({super.key, required this.email, this.isPasswordReset = false});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  static const _length = 6;
  static const _resendSeconds = 55;

  final _code = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _secondsLeft = _resendSeconds;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _code.addListener(() => setState(() {}));
    _focus.addListener(() => setState(() {}));
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) timer.cancel();
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _verify() {
    if (_code.text.length < _length) {
      AuthController.showMessage(context, VerificationText.enterFullCode());
      return;
    }
    FocusScope.of(context).unfocus();
    AuthController.verifyEmail(
      context: context,
      email: widget.email,
      code: _code.text,
      isPasswordReset: widget.isPasswordReset,
      setLoading: (value) => setState(() => _loading = value),
    );
  }

  void _resend() {
    AuthController.resendCode(context, widget.email, isPasswordReset: widget.isPasswordReset);
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      builder: (c) {
        final green = AuthColors.green;
        return [
          authBack(c, context),
          authLogo(c, left: 148.97, top: 110),
          authTitle(c, VerificationText.title(), left: 130, top: 261, width: 142),
          // Frame 50: "أدخل رمز التحقق" ثم الوصف (#4C7A75) تحته بـ 14
          c.text(VerificationText.subtitle(), left: 63, top: 312, width: 280, height: 24, align: TextAlign.center, dy: 0, style: authText(c, 20, FigmaWeight.sfBold, green)),
          c.text(VerificationText.description(), left: 63, top: 350, width: 280, height: 38, align: TextAlign.center, dy: 0, style: authText(c, 16, FigmaWeight.sfRegular, AuthColors.teal)),

          ..._boxes(c),

          // "إعادة إرسال الرمز خلال 55 ثانية" — SF Compact 457 17 والثواني 656 — وبعد ما تخلص: رابط "إعادة إرسال الرمز"
          if (_secondsLeft > 0)
            c.rich(
              TextSpan(children: [
                TextSpan(text: VerificationText.resendIn(), style: authText(c, 17, FigmaWeight.sfRegular, green)),
                TextSpan(text: VerificationText.seconds(_secondsLeft), style: authText(c, 17, FigmaWeight.sfSemibold, green)),
              ]),
              left: 94,
              top: 487,
              width: 204,
              height: 22,
              align: TextAlign.center,
              dy: 0,
            )
          else ...[
            c.text(VerificationText.resendCode(), left: 94, top: 487, width: 204, height: 22, align: TextAlign.center, dy: 0, style: authText(c, 17, FigmaWeight.sfSemibold, green)),
            c.tapArea(left: 94, top: 480, width: 204, height: 36, onTap: _resend),
          ],

          authButton(c, VerificationText.confirm(), left: 17, top: 533, width: 359, loading: _loading, onTap: _verify),
        ];
      },
    );
  }

  // 6 مربعات 48×48 كل 56 (Frame 24) — الأرقام على رمادي #EEEEEF، وآخر رقم مكتوب (المربع اللي عليه الدور) أبيض بحد
  // الترتيب من اليسار لليمين باللغتين (الأرقام بتنكتب LTR)
  List<Widget> _boxes(FigmaCanvas c) {
    final s = c.s;
    final text = _code.text;
    // الأرقام بخط النظام العريض (SF بالآيفون و Roboto بالأندرويد — زي Figma)
    final digitStyle = TextStyle(fontWeight: FontWeight.w700, fontSize: s.x(24), color: Colors.black, height: 1);
    return [
      c.rect(
        left: 22,
        top: 419,
        width: 348,
        height: 68,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _focus.requestFocus(),
          child: Stack(
            children: [
              // الحقل الفعلي (مخفي) — بيستقبل الكتابة واللصق
              Opacity(
                opacity: 0,
                child: TextField(
                  controller: _code,
                  focusNode: _focus,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(_length)],
                  onSubmitted: (_) => _verify(),
                  showCursor: false,
                  enableInteractiveSelection: false,
                  decoration: const InputDecoration.collapsed(hintText: ''),
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: s.x(10), vertical: s.y(10)),
                  child: Row(
                    children: [
                      for (var i = 0; i < _length; i++) ...[
                        if (i > 0) SizedBox(width: s.x(8)),
                        Expanded(child: _box(s, i < text.length ? text[i] : null, active: _focus.hasFocus && i == (text.isEmpty ? 0 : text.length - 1), style: digitStyle)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _box(DesignScale s, String? digit, {required bool active, required TextStyle style}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? Colors.white : AuthColors.codeFill,
        borderRadius: BorderRadius.circular(s.x(10)),
        border: active ? Border.all(color: AuthColors.teal, width: s.x(1)) : null,
      ),
      child: digit == null ? null : Text(digit, style: style),
    );
  }
}
