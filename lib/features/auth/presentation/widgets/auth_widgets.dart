import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_language.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_back_chevron.dart';
import '../../../../core/widgets/pressable_button.dart';
import '../l10n/auth_form_text.dart';
import 'auth_icons.dart';

// -------------------------------------------------------------
// عناصر شاشات الدخول وإنشاء الحساب (Figma: 5 ← 10 + نوع الحساب) — كلها بأرقام Figma
// -------------------------------------------------------------

abstract final class AuthColors {
  static const green = Color(0xFF1F3B2E);
  static const grey = Color(0xFF717171); // نص الحقول وأيقوناتها
  static const fieldFill = Color(0xFFF9F9F9); // #D9D9D9 بشفافية 15% فوق الأبيض
  static const teal = Color(0xFF4C7A75); // وصف شاشة رمز التحقق
  static const divider = Color(0xFF88888C); // خط "أو"
  static const chevron = Color(0xFF1E1E2D);
  static const codeFill = Color(0xFFEEEEEF);
}

const authLogoAsset = 'assets/images/supervisor/logo.png';

/// ستايل نص Figma (SF Compact → Noto Sans Arabic) بـ line height auto
TextStyle authText(FigmaCanvas c, double size, double weight, Color color) => c.style(size, weight, color, lineHeight: null, letterSpacing: 0);

// -------------------------------------------------------------
// هيكل الشاشة: خلفية بيضا والعناصر بأرقام إطار Figma (852)
// الشاشة ثابتة — بس لما يطلع الكيبورد بتتمرر حتى الحقل المكتوب فيه يضل ظاهر
// -------------------------------------------------------------
class AuthPage extends StatelessWidget {
  final List<Widget> Function(FigmaCanvas c) builder;

  const AuthPage({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    final c = FigmaCanvas(s);
    final keyboard = math.max(0.0, MediaQuery.viewInsetsOf(context).bottom - MediaQuery.paddingOf(context).bottom);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: GestureDetector(
            // الضغط برا الحقول بيسكّر الكيبورد
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.translucent,
            child: Padding(
              padding: EdgeInsets.only(bottom: keyboard),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: s.y(852 - FigmaCanvas.statusBar - 34),
                  child: Stack(clipBehavior: Clip.none, children: builder(c)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// سهم الرجوع (Path 6×12 خط 1.5 #1E1E2D): بالعربي يمين الشاشة ">" — بالإنجليزي بينعكس يسار "<"
/// [width]/[height]/[stroke]: شاشة "نوع الحساب" سهمها أكبر (8×15 خط 2) — [color]: الأدعية سهمها أسود
Widget authBack(FigmaCanvas c, BuildContext context, {double left = 368, double top = 92, double width = 6, double height = 12, double stroke = 1.5, Color color = AuthColors.chevron, VoidCallback? onTap}) =>
    figmaBackChevron(c, context, left: left, top: top, width: width, height: height, stroke: stroke, color: color, onTap: onTap);

/// الشعار (Group 5 — 103.07×135.57)
Widget authLogo(FigmaCanvas c, {required double left, required double top}) {
  // صورة الشعار فيها هامش شفاف صغير — فبتتكبّر شوي حتى يطلع الرسم نفسه 103×135.6 بمكانه
  return c.image(authLogoAsset, left: left - 1.34, top: top - 1.77, width: 105.75, height: 139.1, fit: BoxFit.contain);
}

/// عنوان الشاشة: SF Compact 790 24 #1F3B2E — بالنص (أو من البداية لما يكون Figma محاذيه يمين)
Widget authTitle(FigmaCanvas c, String text, {required double left, required double top, required double width, TextAlign align = TextAlign.center}) {
  // الإنجليزي أطول من صندوق Figma العربي — فبياخد عرض الشاشة بالنص
  if (!AppLanguage.isArabic) {
    left = 16;
    width = 361;
    align = TextAlign.center;
  }
  return c.text(text, left: left, top: top, width: width, height: 29, align: align, dy: 0, style: authText(c, 24, FigmaWeight.sfBold, AuthColors.green));
}

/// زر Figma (Button): أخضر أو أبيض بحد — radius 14 — النص بالنص
Widget authButton(
  FigmaCanvas c,
  String label, {
  required double left,
  required double top,
  required VoidCallback? onTap,
  double width = 361,
  double height = 50,
  bool outlined = false,
  bool loading = false,
  double textSize = 16,
  InlineSpan? span,
}) {
  final color = outlined ? AuthColors.green : Colors.white;
  final style = authText(c, textSize, FigmaWeight.semiBold, color);
  return c.rect(
    left: left,
    top: top,
    width: width,
    height: height,
    child: PressableButton(
      fill: outlined ? Colors.white : AuthColors.green,
      pressedFill: outlined ? const Color(0xFFF0F0F0) : const Color(0xFF092019),
      radius: c.s.x(14),
      border: outlined ? Border.all(color: AuthColors.green, width: c.s.x(1)) : null,
      onTap: loading ? null : onTap,
      child: Center(
        child: loading
            ? SizedBox.square(dimension: c.s.x(22), child: CircularProgressIndicator(strokeWidth: c.s.x(2.2), color: color))
            : FittedBox(fit: BoxFit.scaleDown, child: Text.rich(span ?? TextSpan(text: label, style: style), maxLines: 1)),
      ),
    ),
  );
}

/// زر "الدخول عبر Google" (أبيض بحد) — كلمة Google بحروف لاتينية
Widget authGoogleButton(FigmaCanvas c, {required double top, required VoidCallback onTap, double left = 15.5, double width = 360.5}) {
  final style = authText(c, 16, FigmaWeight.sfSemibold, AuthColors.green);
  return authButton(
    c,
    '',
    left: left,
    top: top,
    width: width,
    outlined: true,
    onTap: onTap,
    span: TextSpan(children: [
      TextSpan(text: AuthFormText.googlePrefix(), style: style),
      TextSpan(text: AuthFormText.google, style: style.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontVariations: const [])),
    ]),
  );
}

/// أيقونة الشخص (نفس أيقونة حقل الاسم بتعديل الملف) — رمادي #717171
Widget authPersonIcon(DesignScale s, {Color color = AuthColors.grey}) => Center(
      child: Image.asset('assets/images/supervisor/ic_field_user.png', width: s.x(17.67), height: s.x(22.67), color: color, colorBlendMode: BlendMode.srcIn),
    );

/// حقل Figma (TextField): 360×46 — #D9D9D9 15% — حد #1F3B2E — radius 10
/// الأيقونة 24 بالبداية (بعد 6) والنص بعدها بـ 10 — وحقل كلمة السر فيه عين بالنهاية
class AuthField extends StatefulWidget {
  final DesignScale s;
  final TextEditingController controller;
  final String hint;
  final Widget? icon;
  final bool password;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  const AuthField({
    super.key,
    required this.s,
    required this.controller,
    required this.hint,
    this.icon,
    this.password = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.autofillHints,
    this.onSubmitted,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final style = figmaText(s, size: 16.5, weight: FigmaWeight.sfRegular, color: AuthColors.green, lineHeight: null, letterSpacing: 0);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AuthColors.fieldFill,
        borderRadius: BorderRadius.circular(s.x(10)),
        border: Border.all(color: AuthColors.green, width: s.x(1)),
      ),
      child: Row(
        children: [
          SizedBox(width: s.x(6)),
          if (widget.icon != null) ...[SizedBox.square(dimension: s.x(24), child: widget.icon), SizedBox(width: s.x(10))] else SizedBox(width: s.x(10)),
          Expanded(
            child: TextField(
              controller: widget.controller,
              obscureText: widget.password && _hidden,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              inputFormatters: widget.inputFormatters,
              autofillHints: widget.autofillHints,
              onSubmitted: widget.onSubmitted,
              cursorColor: AuthColors.green,
              textAlignVertical: TextAlignVertical.center,
              style: style,
              decoration: InputDecoration.collapsed(hintText: widget.hint, hintStyle: style.copyWith(color: AuthColors.grey)),
            ),
          ),
          if (widget.password)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _hidden = !_hidden),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(s.x(10), s.x(8), s.x(6), s.x(8)),
                child: AuthIconView(_hidden ? AuthIcon.eye : AuthIcon.eyeOff, size: s.x(24), color: AuthColors.grey),
              ),
            )
          else
            SizedBox(width: s.x(10)),
        ],
      ),
    );
  }
}

/// مربع الاختيار (24 — radius 4 — حد #1F3B2E) — المختار أخضر وفيه علامة صح
class AuthCheckbox extends StatelessWidget {
  final DesignScale s;
  final bool value;
  final ValueChanged<bool> onChanged;

  const AuthCheckbox({super.key, required this.s, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: value ? AuthColors.green : Colors.white,
          borderRadius: BorderRadius.circular(s.x(4)),
          border: Border.all(color: AuthColors.green, width: s.x(1)),
        ),
        child: value ? Icon(Icons.check_rounded, size: s.x(18), color: Colors.white) : null,
      ),
    );
  }
}

/// "أو" بين خطين (#88888C)
List<Widget> authOrDivider(FigmaCanvas c, String label, {required double top}) {
  const line = ColoredBox(color: AuthColors.divider);
  return [
    c.rect(left: 56, top: top + 12.5, width: 131, height: 1, child: line),
    c.rect(left: 208, top: top + 12.5, width: 146, height: 1, child: line),
    c.text(label, left: 183, top: top, width: 26, height: 21, align: TextAlign.center, dy: 0, style: authText(c, 16, FigmaWeight.semiBold, AuthColors.divider)),
  ];
}

/// سطر فيه نص عادي + رابط عريض (مثل "هل لديك حساب بالفعل؟ تسجيل الدخول")
Widget authLinkLine(
  FigmaCanvas c, {
  required String text,
  required String link,
  required VoidCallback onTap,
  required double left,
  required double top,
  required double width,
  double height = 22,
  double size = 16,
  Color textColor = AuthColors.green,
}) {
  return c.rect(
    left: left,
    top: top,
    width: width,
    height: height,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: text, style: authText(c, size, FigmaWeight.sfRegular, textColor)),
                TextSpan(text: link, style: authText(c, size, FigmaWeight.sfBold, AuthColors.green)),
              ],
            ),
            maxLines: 1,
          ),
        ),
      ),
    ),
  );
}

/// مفتاح اللغة (Group 36750 — 75×33): عربي "AR" والدايرة يمين — إنجليزي "EN" والدايرة يسار
class AuthLanguageToggle extends StatelessWidget {
  final DesignScale s;

  const AuthLanguageToggle({super.key, required this.s});

  @override
  Widget build(BuildContext context) {
    final ar = AppLanguage.isArabic;
    final label = Text(
      ar ? 'AR' : 'EN',
      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: s.x(12.5), color: Colors.white, height: 1),
    );
    // الأماكن ثابتة يمين/يسار (ما بتنعكس مع اتجاه الشاشة)
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => AppLanguage.change(ar ? 'en' : 'ar'),
        child: DecoratedBox(
          decoration: BoxDecoration(color: AuthColors.green, borderRadius: BorderRadius.circular(s.x(16.5))),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: ar ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: s.x(4)),
                  child: Container(width: s.x(20), height: s.x(20), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                ),
              ),
              Align(
                alignment: ar ? const Alignment(-0.24, 0) : const Alignment(0.24, 0),
                child: label,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
