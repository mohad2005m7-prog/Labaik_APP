import 'package:flutter/material.dart';

// -------------------------------------------------------------
// سطر واحد بأكتر من ستايل (مثل "موعد الوصول : 25 سبتمبر 2026") بضغط حروف Figma:
// Figma بيطبّق letter spacing على كل حرف و Flutter ما بيطبّقه على العربي،
// فالسطر بينضغط أفقياً لعرضه بـ Figma (العرض الطبيعي + letterSpacing × عدد الحروف) — زي FigmaSpacedText
// -------------------------------------------------------------
class FigmaSpacedRich extends StatelessWidget {
  final List<TextSpan> spans;

  /// letter spacing بـ Figma (px بعد التحجيم) — سالب
  final double letterSpacing;
  final TextAlign align;

  /// أقصى عرض للسطر (بعد التحجيم) — لو أطول بيصغر كله ليوسع (مثل النص الإنجليزي أو اسم طويل)
  final double? maxWidth;

  const FigmaSpacedRich({super.key, required this.spans, required this.letterSpacing, this.align = TextAlign.start, this.maxWidth});

  static bool _isArabic(int rune) => (rune >= 0x0600 && rune <= 0x06FF) || (rune >= 0xFB50 && rune <= 0xFEFF);

  @override
  Widget build(BuildContext context) {
    final span = TextSpan(children: spans);
    final text = span.toPlainText();
    final direction = Directionality.of(context);
    final painter = TextPainter(text: span, textDirection: direction, textScaler: MediaQuery.textScalerOf(context), maxLines: 1)..layout();
    final arabic = text.runes.any(_isArabic);
    final figma = !arabic || painter.width <= 0 ? 1.0 : ((painter.width + letterSpacing * text.runes.length) / painter.width).clamp(0.8, 1.0);
    final limit = maxWidth;
    final fits = limit == null || painter.width * figma <= limit ? 1.0 : limit / (painter.width * figma);
    final rtl = direction == TextDirection.rtl;
    final alignment = switch (align) {
      TextAlign.center => Alignment.center,
      TextAlign.end => rtl ? Alignment.centerLeft : Alignment.centerRight,
      _ => rtl ? Alignment.centerRight : Alignment.centerLeft,
    };
    return Transform.scale(
      scaleX: figma * fits,
      scaleY: fits,
      alignment: alignment,
      child: Text.rich(span, maxLines: 1, softWrap: false, overflow: TextOverflow.visible),
    );
  }
}
