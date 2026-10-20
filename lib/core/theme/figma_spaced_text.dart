import 'package:flutter/material.dart';

// -------------------------------------------------------------
// نص عربي بنفس سطور Figma بالظبط
// Figma بيطبّق letter spacing (مثل -0.408) على كل حرف حتى التشكيل والمسافات، فسطوره أضيق،
// و Flutter ما بيطبّقه على العربي أبداً — فهون بنكسر السطور كلمة كلمة بعرض Figma نفسه
// (العرض الطبيعي + letterSpacing × عدد الحروف) وكل سطر بينضغط أفقياً لعرضه بـ Figma
// (مقاس على 60 نص أدعية: نفس عدد السطور ونفس أماكن الكسر، وأماكن النص بفرق ~0.5 بكسل)
// [fitWidth]: سطر واحد صندوقه بـ Figma على قد النص (Auto width) → بينضغط لعرض الصندوق بالظبط
// النص الإنجليزي ما بينضغط — Flutter بيطبّق عليه الـ letter spacing لحاله
// -------------------------------------------------------------
class FigmaSpacedText extends StatelessWidget {
  final String text;
  final TextStyle style;

  /// letter spacing بـ Figma (px بعد التحجيم) — سالب
  final double letterSpacing;

  /// عرض صندوق النص بـ Figma (بعد التحجيم)
  final double width;

  /// null = اتجاه الشاشة (نصوص الأدعية نفسها دايماً rtl)
  final TextDirection? direction;
  final TextAlign align;

  /// [maxLines]: الزيادة بتنقطع بـ "…"
  final int? maxLines;
  final bool fitWidth;

  const FigmaSpacedText(
    this.text, {
    super.key,
    required this.style,
    required this.letterSpacing,
    required this.width,
    this.direction,
    this.align = TextAlign.start,
    this.maxLines,
    this.fitWidth = false,
  });

  // متل Figma: ما بينكسر السطر قبل علامة ترقيم (": . ! ؟ ؛") حتى لو قبلها مسافة، ولا بعد علامة فتح ("{ (")
  // — بتلزق بالكلمة اللي جنبها (الفاصلة "،" والأقواس المسكّرة Figma بيكسر قبلهم عادي — مقاس على الأدعية)
  static final _noBreakBefore = RegExp(r'^[:.!?;؛؟]+$');
  static final _noBreakAfter = RegExp(r'^[{(\[]+$');

  static List<String> _breakUnits(String text) {
    final units = <String>[];
    for (final word in text.split(' ')) {
      if (units.isNotEmpty && (_noBreakBefore.hasMatch(word) || _noBreakAfter.hasMatch(units.last))) {
        units.last = '${units.last} $word';
      } else {
        units.add(word);
      }
    }
    return units;
  }

  /// عرض السطر بـ Figma (بعد التحجيم) — لصندوق بيكبر مع النص (مثل خانة المبلغ)
  static double lineWidth(BuildContext context, String text, TextStyle style, double letterSpacing) {
    final painter = TextPainter(text: TextSpan(text: text, style: style), textDirection: Directionality.of(context), textScaler: MediaQuery.textScalerOf(context), maxLines: 1)..layout();
    return text.runes.any(_isArabic) ? painter.width + letterSpacing * text.runes.length : painter.width;
  }

  static bool _isArabic(int rune) => (rune >= 0x0600 && rune <= 0x06FF) || (rune >= 0x0750 && rune <= 0x077F) || (rune >= 0xFB50 && rune <= 0xFEFF);

  @override
  Widget build(BuildContext context) {
    final textDirection = direction ?? Directionality.of(context);
    if (!text.runes.any(_isArabic)) {
      return SizedBox(
        width: width,
        child: Text(text, style: style, textDirection: textDirection, textAlign: align, maxLines: maxLines, overflow: maxLines == null ? null : TextOverflow.ellipsis),
      );
    }

    final scaler = MediaQuery.textScalerOf(context);
    TextPainter measure(String s) => TextPainter(text: TextSpan(text: s, style: style), textDirection: textDirection, textScaler: scaler, maxLines: 1)..layout();
    double figmaWidth(String s, TextPainter p) => p.width + letterSpacing * s.runes.length;

    // كسر السطور كلمة كلمة بعرض Figma
    final lines = <(String, TextPainter)>[];
    if (fitWidth) {
      lines.add((text, measure(text)));
    } else {
      var current = '';
      TextPainter? currentPainter;
      for (final word in _breakUnits(text)) {
        final next = current.isEmpty ? word : '$current $word';
        final painter = measure(next);
        if (current.isNotEmpty && figmaWidth(next, painter) > width) {
          lines.add((current, currentPainter!));
          current = word;
          currentPainter = measure(word);
        } else {
          current = next;
          currentPainter = painter;
        }
      }
      if (current.isNotEmpty) lines.add((current, currentPainter!));
    }

    final rtl = textDirection == TextDirection.rtl;
    final edge = switch (align) {
      TextAlign.center => Alignment.center,
      TextAlign.end => rtl ? Alignment.centerLeft : Alignment.centerRight,
      _ => rtl ? Alignment.centerRight : Alignment.centerLeft,
    };
    // [p]: قياس السطر نفسه — نسبة الضغط منه (للسطر المقطوع بـ "…" من السطر اللي مكانه)
    Widget line(String s, TextPainter p, {bool ellipsis = false}) {
      final measured = ellipsis ? lines[maxLines! - 1].$1 : s;
      final target = fitWidth ? width : figmaWidth(measured, p);
      final squeeze = p.width <= 0 ? 1.0 : (target / p.width).clamp(0.8, 1.0);
      return SizedBox(
        width: width,
        height: p.height,
        child: OverflowBox(
          alignment: edge,
          minWidth: 0,
          maxWidth: ellipsis ? width / squeeze : double.infinity,
          child: Transform.scale(
            scaleX: squeeze,
            scaleY: 1,
            alignment: edge,
            child: Text(s, style: style, textDirection: textDirection, maxLines: 1, softWrap: false, overflow: ellipsis ? TextOverflow.ellipsis : TextOverflow.visible),
          ),
        ),
      );
    }

    final limit = maxLines;
    if (limit != null && lines.length > limit) {
      // آخر سطر مسموح بياخد باقي النص وبينقطع بـ "…"
      final rest = lines.skip(limit - 1).map((l) => l.$1).join(' ');
      return Column(mainAxisSize: MainAxisSize.min, children: [
        for (final l in lines.take(limit - 1)) line(l.$1, l.$2),
        line(rest, lines[limit - 1].$2, ellipsis: true),
      ]);
    }
    return Column(mainAxisSize: MainAxisSize.min, children: [for (final l in lines) line(l.$1, l.$2)]);
  }
}
