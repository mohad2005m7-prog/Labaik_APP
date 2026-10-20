import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/figma_spaced_text.dart';
import '../theme/figma_text.dart';
import '../widgets/pressable_button.dart';
import 'design_scale.dart';

// -------------------------------------------------------------
// FigmaCanvas — بيحط العناصر جوّا Stack بأرقام إطار Figma نفسها (393×852)
// left/top/width/height = مستطيل العنصر بـ Figma (top من أعلى الإطار، يعني فيه شريط الحالة 59)
// بالعربي (RTL) العنصر بيطلع بنفس مكانه بالتصميم بالظبط، وبالإنجليزي (LTR) بينعكس أفقياً
// لأنه كل شي PositionedDirectional (start = يمين بالعربي).
// الأحجام بتتحجّم لشاشة الجهاز عن طريق DesignScale.
// -------------------------------------------------------------
class FigmaCanvas {
  const FigmaCanvas(this.s, {this.originTop = statusBar});

  final DesignScale s;

  /// الـ y بإطار Figma اللي بيقابل أعلى الـ Stack (عادةً 59 = تحت شريط الحالة).
  /// صفوف القوائم بتاخد كانفس خاص فيها: originTop = أعلى أول صف، وكل صف بنفس أرقام Figma للصف الأول
  final double originTop;

  /// كانفس لعنصر بيبدأ عند y [top] بإطار Figma (صف بقائمة، محتوى بيتمرر...)
  FigmaCanvas at(double top) => FigmaCanvas(s, originTop: top);

  static const frameWidth = 393.0;
  static const statusBar = 59.0;

  /// Figma بيرسم نصوص line height 22 أوطى بـ 1 من صناديقها (مقاس بالمقارنة)
  static const baselineFix = 1.0;

  /// Flutter ما بيطبّق letter spacing (-0.408) على العربي فالسطر أعرض شوي من Figma،
  /// فصندوق النص بياخد هالمسافة الزيادة من جهة نهاية السطر بدل ما يصغر الخط.
  static const textSlack = 24.0;

  // #1F3B2E
  static const green = Color(0xFF1F3B2E);
  // ظل Figma: (0,4) blur 4 أسود 25%
  static const _shadowColor = Color(0x40000000);

  double _start(double left, double width) => s.x(frameWidth - left - width);
  double _top(double top) => s.y(top - originTop);

  /// ظل Figma الافتراضي بالتصميم — blur 4 بـ Figma = sigma 2 → blurRadius 2.6 بـ Flutter
  BoxShadow get shadow => BoxShadow(color: _shadowColor, offset: Offset(0, s.y(4)), blurRadius: s.x(2.6));

  /// ستايل النص (Noto Sans Arabic بأوزان FigmaWeight) — نفس figmaText
  TextStyle style(double size, double weight, Color color, {double? lineHeight = 22, double letterSpacing = -0.408}) {
    return figmaText(s, size: size, weight: weight, color: color, lineHeight: lineHeight, letterSpacing: letterSpacing);
  }

  /// أي ويدجت بمستطيل Figma
  Widget rect({required double left, required double top, required double width, required double height, required Widget child}) {
    return PositionedDirectional(start: _start(left, width), top: _top(top), width: s.x(width), height: s.y(height), child: child);
  }

  /// مستطيل ملوّن (كرت، زر، عنوان...) — radius وحد وظل حسب Figma
  Widget box({
    required double left,
    required double top,
    required double width,
    required double height,
    Color? color,
    Gradient? gradient,
    double radius = 0,
    Color? borderColor,
    double borderWidth = 1,
    bool hasShadow = false,
  }) {
    return rect(
      left: left,
      top: top,
      width: width,
      height: height,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            gradient: gradient,
            borderRadius: radius == 0 ? null : BorderRadius.circular(s.x(radius)),
            // الحد جوّا المستطيل (Inside بـ Figma)
            border: borderColor == null ? null : Border.all(color: borderColor, width: s.x(borderWidth)),
            boxShadow: hasShadow ? [shadow] : null,
          ),
        ),
      ),
    );
  }

  /// صورة/أيقونة: حجمها بيتحجّم أفقياً (بدون تمطيط) ومركزها العمودي بمكانه النسبي
  /// [flipInLtr]: للصور اللي إلها اتجاه (مثل المسار) — بتنقلب بالإنجليزي مع انعكاس الشاشة
  /// [fixedLeft]: بتضل بمكانها من اليسار باللغتين (مثل سهم الرجوع يسار الشاشة) — ما بتنعكس
  /// [color]: تلوين أيقونة بلون واحد (نفس الأيقونة بأكتر من لون بالتصميم)
  Widget image(
    String asset, {
    required double left,
    required double top,
    required double width,
    required double height,
    double radius = 0,
    bool flipInLtr = false,
    bool fixedLeft = false,
    Color? color,
    BoxFit fit = BoxFit.fill,
    int? cacheWidth,
  }) {
    // [cacheWidth]: الصور الكبيرة بتنفك بحجم عرضها بالشاشة بس (أخف على الذاكرة وأسرع)
    Widget child = IgnorePointer(
      child: Image.asset(asset, width: s.x(width), height: s.x(height), fit: fit, color: color, colorBlendMode: color == null ? null : BlendMode.srcIn, cacheWidth: cacheWidth),
    );
    if (radius > 0) {
      child = ClipRRect(borderRadius: BorderRadius.circular(s.x(radius)), child: child);
    }
    if (flipInLtr) {
      final picture = child;
      child = Builder(
        builder: (context) => Transform.flip(flipX: Directionality.of(context) == TextDirection.ltr, child: picture),
      );
    }
    final imageTop = s.y(top - originTop + height / 2) - s.x(height / 2);
    if (fixedLeft) {
      return Positioned(left: s.x(left), top: imageTop, width: s.x(width), height: s.x(height), child: child);
    }
    return PositionedDirectional(
      start: _start(left, width),
      top: imageTop,
      width: s.x(width),
      height: s.x(height),
      child: child,
    );
  }

  /// نص بصندوق Figma — [align] = محاذاة Figma (start = RIGHT بالعربي، end = LEFT)
  /// [poppinsLatin]: نص Poppins 500 فيه أرقام (بتترسم بـ Poppins زي Figma — شوف poppinsLatinSpan)
  /// السطور العربية بتنكسر بنفس مكان Figma عن طريق "\n" بالنص نفسه، والإنجليزي بيلتف لحاله.
  /// لو النص ما وسع الصندوق بيصغر (FittedBox) بدل ما يطلع برا.
  Widget text(
    String value, {
    required double left,
    required double top,
    required double width,
    required double height,
    required TextStyle style,
    TextAlign align = TextAlign.start,
    double dy = baselineFix,
    bool poppinsLatin = false,
    FontWeight latinWeight = FontWeight.w500,
  }) {
    return rich(
      poppinsLatin ? poppinsLatinSpan(value, style, latinWeight: latinWeight) : TextSpan(text: value, style: style),
      left: left,
      top: top,
      width: width,
      height: height,
      align: align,
      dy: dy,
    );
  }

  /// نص بأكتر من ستايل (مثل "نقطة وصولك : ميقات ذو الحليفة")
  Widget rich(
    InlineSpan span, {
    required double left,
    required double top,
    required double width,
    required double height,
    TextAlign align = TextAlign.start,
    double dy = baselineFix,
  }) {
    // الصندوق بيتوسع من جهة نهاية السطر لحد حافة الإطار (أو بـ textSlack من الجهتين لو بالنص)
    // والنص بيضل ملزوق ببداية صندوق Figma (أو بنصه)
    var l = left;
    var w = width;
    var englishWidth = width; // العرض المتاح للنص الإنجليزي (مش مصمم بـ Figma)
    final AlignmentDirectional alignment;
    switch (align) {
      case TextAlign.center:
        final extra = math.min(textSlack / 2, math.min(left, frameWidth - left - width));
        l = left - extra;
        w = width + 2 * extra;
        englishWidth = width;
        alignment = AlignmentDirectional.center;
      case TextAlign.end:
      case TextAlign.left:
        w = math.min(width + textSlack, frameWidth - left);
        englishWidth = width;
        alignment = AlignmentDirectional.centerEnd;
      default:
        l = 0;
        w = left + width;
        englishWidth = math.max(width, w - 16); // هامش 16 عن حافة الشاشة
        alignment = AlignmentDirectional.centerStart;
    }
    // عدد سطور النص بـ Figma (line height 22)
    final lines = math.max(1, (height / 22).round());

    final textAlign = align == TextAlign.left ? TextAlign.end : align;
    return rect(
      left: l,
      top: top,
      width: w,
      height: height,
      // النص للعرض بس — ما بيستقبل ضغطات (صندوقه ممكن يغطي زر جنبه)
      child: IgnorePointer(
        child: Transform.translate(
          offset: Offset(0, s.y(dy)),
          // بالعربي السطور مكسورة بالنص نفسه زي Figma فما بتلتف (ولو سطر ما وسع بيصغر شوي)
          // بالإنجليزي: نص السطر الواحد بيضل سطر واحد (وبيصغر لو ما وسع)، والأكتر من سطر بيلتف لحاله
          child: Builder(
            builder: (context) {
              final rtl = Directionality.of(context) == TextDirection.rtl;
              final maxWidth = s.x(rtl ? w : englishWidth);
              return Align(
                alignment: alignment,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: alignment,
                    child: rtl || lines == 1
                        ? Text.rich(span, textAlign: textAlign, softWrap: false)
                        : ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child: Text.rich(span, textAlign: textAlign),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// زر Figma (مكوّن Button): 361×50 — radius 14 — Poppins 600 20
  /// [outlined]: أبيض بحد (زر "انا ضائع")
  /// [figmaSpacing]: النص العربي بيضيق زي Figma (letter spacing -0.408 — شوف FigmaSpacedText)
  /// [labelSize]/[labelWeight]: لو نص الزر بـ Figma مش 20 SemiBold (مثل "تعديل تفاصيل الرحلة")
  /// [labelDx]: لو نص الزر بـ Figma مش بالنص بالظبط (+ = لجهة البداية، يمين بالعربي)
  Widget button(
    String label, {
    required double left,
    required double top,
    required VoidCallback onTap,
    double width = 361,
    double height = 50,
    bool outlined = false,
    Color borderColor = green,
    double borderWidth = 1,
    bool figmaSpacing = false,
    double labelSize = 20,
    double labelWeight = FigmaWeight.semiBold,
    double labelDx = 0,
  }) {
    final labelStyle = style(labelSize, labelWeight, outlined ? green : Colors.white);
    return rect(
      left: left,
      top: top,
      width: width,
      height: height,
      child: PressableButton(
        fill: outlined ? Colors.white : green,
        pressedFill: outlined ? const Color(0xFFF0F0F0) : const Color(0xFF092019),
        radius: s.x(14),
        border: outlined ? Border.all(color: borderColor, width: s.x(borderWidth)) : null,
        onTap: onTap,
        child: Builder(
          builder: (context) => Transform.translate(
            offset: Offset(s.x(labelDx) * (Directionality.of(context) == TextDirection.rtl ? 1 : -1), s.y(baselineFix)),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              // Figma بيوسّط النص بدون المسافات اللي بآخره (مثل "وصلت إلى الميقات ")
              child: figmaSpacing
                  ? FigmaSpacedText(label.trimRight(), style: labelStyle, letterSpacing: s.x(-0.408), width: s.x(width - 20), align: TextAlign.center, maxLines: 1)
                  : Text(label.trimRight(), maxLines: 1, softWrap: false, style: labelStyle),
            ),
          ),
        ),
      ),
    );
  }

  /// منطقة ضغط شفافة فوق عناصر مرسومة (كرت اختيار مثلاً)
  Widget tapArea({required double left, required double top, required double width, required double height, required VoidCallback onTap}) {
    return rect(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap),
    );
  }
}
