import 'package:flutter/material.dart';

import '../utils/figma_canvas.dart';

// -------------------------------------------------------------
// نص Figma بأكتر من سطر وبمقطع أعرض (**...**) — بالعربي سطور Figma نفسها ("\n" وسطر فاضي = "\n\n")
// وكل سطر بينضغط أفقياً لعرضه بـ Figma: Figma بيطبّق letter spacing على كل حرف و Flutter ما بيطبّقه على العربي
// [top]: أعلى صندوق النص بـ Figma (line height [lineHeight]) — والنص بينزل [dy] متل c.text
// بالإنجليزي النص بيلتف لحاله جوّا [width] ([wrap] = false: سطر واحد)، ولو طوّل عن [maxHeight] بيصغر شوي
// -------------------------------------------------------------
abstract final class FigmaLines {
  static Widget build(
    FigmaCanvas c,
    String text, {
    required double left,
    required double top,
    required double width,
    required TextStyle style,
    TextStyle? boldStyle,
    TextAlign align = TextAlign.start,
    double lineHeight = 22,
    double? maxHeight,
    double letterSpacing = -0.408,
    double dy = FigmaCanvas.baselineFix,
    bool wrap = true,
  }) {
    final s = c.s;
    final lines = text.split('\n');
    final lineH = s.y(lineHeight);
    TextStyle fit(TextStyle st) => st.copyWith(height: lineH / st.fontSize!, leadingDistribution: TextLeadingDistribution.even, letterSpacing: 0);
    final normal = fit(style), bold = fit(boldStyle ?? style);
    final center = align == TextAlign.center;
    return c.rect(
      left: left,
      top: top + dy,
      width: width,
      height: maxHeight ?? lineHeight * lines.length,
      child: IgnorePointer(
        child: Builder(
          builder: (context) {
            if (Directionality.of(context) == TextDirection.rtl) {
              return OverflowBox(
                alignment: center ? Alignment.topCenter : AlignmentDirectional.topStart,
                minHeight: 0,
                maxHeight: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final line in lines)
                      _Line(spans: spans(line, normal, bold), letterSpacing: s.x(letterSpacing), width: s.x(width), height: lineH, center: center),
                  ],
                ),
              );
            }
            // [wrap] = false: سطر واحد (عنوان شريحة أو زر) بيصغر بدل ما يلتف
            final english = Text.rich(TextSpan(children: spans(text, normal, bold)), textAlign: align, maxLines: wrap ? null : 1, softWrap: wrap);
            return FittedBox(
              fit: BoxFit.scaleDown,
              alignment: center ? Alignment.topCenter : AlignmentDirectional.topStart,
              child: wrap ? ConstrainedBox(constraints: BoxConstraints(maxWidth: s.x(width)), child: english) : english,
            );
          },
        ),
      ),
    );
  }

  /// "عادي **أعرض** عادي" → مقاطع
  static List<TextSpan> spans(String text, TextStyle normal, TextStyle bold) {
    final parts = text.split('**');
    return [
      for (final (i, part) in parts.indexed)
        if (part.isNotEmpty) TextSpan(text: part, style: i.isOdd ? bold : normal),
    ];
  }
}

class _Line extends StatelessWidget {
  final List<TextSpan> spans;
  final double letterSpacing;
  final double width;
  final double height;
  final bool center;

  const _Line({required this.spans, required this.letterSpacing, required this.width, required this.height, required this.center});

  static bool _arabic(int rune) => (rune >= 0x0600 && rune <= 0x06FF) || (rune >= 0xFB50 && rune <= 0xFEFF);

  @override
  Widget build(BuildContext context) {
    if (spans.isEmpty) return SizedBox(width: width, height: height);
    final span = TextSpan(children: spans);
    final runes = span.toPlainText().runes;
    final painter = TextPainter(text: span, textDirection: Directionality.of(context), textScaler: MediaQuery.textScalerOf(context), maxLines: 1)..layout();
    final squeeze = painter.width <= 0 || !runes.any(_arabic) ? 1.0 : ((painter.width + letterSpacing * runes.length) / painter.width).clamp(0.8, 1.0);
    // لو السطر أعرض من الصندوق (خط النظام أكبر مثلاً) بيصغر كله ليوسع
    final shrink = painter.width * squeeze <= width ? 1.0 : width / (painter.width * squeeze);
    final alignment = center ? Alignment.center : AlignmentDirectional.centerStart;
    return SizedBox(
      width: width,
      height: height,
      child: OverflowBox(
        alignment: alignment,
        minWidth: 0,
        maxWidth: double.infinity,
        child: Transform.scale(scaleX: squeeze * shrink, scaleY: shrink, alignment: alignment, child: Text.rich(span, maxLines: 1, softWrap: false)),
      ),
    );
  }
}
