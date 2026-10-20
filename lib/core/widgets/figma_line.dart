import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../theme/figma_spaced_text.dart';
import '../utils/figma_canvas.dart';

// -------------------------------------------------------------
// سطر نص Figma فيه letter spacing (-0.408) بصندوقه بـ Figma:
// العربي بيضيق زي Figma (FigmaSpacedText) — [fit]: صندوق Figma على قد النص (Auto width) فبينضغط لعرضه بالظبط
// (للنصوص الثابتة؛ النص المتغيّر مثل المبالغ بيضيق بنسبة Figma بدون fit)
// الإنجليزي (مش مصمم بـ Figma) زي باقي نصوص التطبيق (c.text)
// [align]: start = يمين بالعربي، end = يسار، center
// -------------------------------------------------------------
extension FigmaLine on FigmaCanvas {
  Widget line(
    String value, {
    required double left,
    required double top,
    required double width,
    required double height,
    required TextStyle style,
    TextAlign align = TextAlign.start,
    bool fit = false,
    double dy = FigmaCanvas.baselineFix,
  }) {
    if (!AppLanguage.isArabic) return text(value, left: left, top: top, width: width, height: height, style: style, align: align == TextAlign.end ? TextAlign.left : align, dy: dy);
    final alignment = switch (align) {
      TextAlign.center => AlignmentDirectional.center,
      TextAlign.end => AlignmentDirectional.centerEnd,
      _ => AlignmentDirectional.centerStart,
    };
    return rect(
      left: left,
      top: top + dy,
      width: width,
      height: height,
      child: IgnorePointer(
        child: OverflowBox(
          alignment: alignment,
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: FigmaSpacedText(value, style: style, letterSpacing: s.x(-0.408), width: s.x(width), align: align, maxLines: 1, fitWidth: fit),
        ),
      ),
    );
  }
}
