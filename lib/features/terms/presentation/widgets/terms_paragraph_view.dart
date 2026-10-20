import 'package:flutter/material.dart';

import '../../../../core/utils/figma_canvas.dart';

// -------------------------------------------------------------
// فقرة بكرت الشروط: "المقدمة:" (Bold 16 أخضر) وبعدها النص (Regular 16 أسود) — بدون letter spacing
// (مقاس بعرض كل سطور Figma: الفرق ≤ 1.5 بكسل)
// بالعربي سطور Figma نفسها ("\n")، والإنجليزي بيلتف لحاله ولو طوّل عن مساحته بيصغر شوي
// [baseline]: خط كتابة أول سطر بإطار Figma — [bottom]: آخر المساحة المتاحة للفقرة
// -------------------------------------------------------------
abstract final class TermsParagraphView {
  static const left = 35.5;
  static const width = 319.0;

  static Widget build(
    FigmaCanvas c, {
    required String label,
    required String body,
    required double baseline,
    required double bottom,
    required double lineHeight,
    required TextStyle labelStyle,
    required TextStyle bodyStyle,
  }) {
    final lineH = c.s.y(lineHeight);
    TextStyle fit(TextStyle style) => style.copyWith(height: lineH / style.fontSize!, leadingDistribution: TextLeadingDistribution.even, letterSpacing: 0);
    final labelText = fit(labelStyle), bodyText = fit(bodyStyle);
    final boxWidth = c.s.x(width);

    return c.rect(
      left: left,
      top: baseline,
      width: width,
      height: bottom - baseline,
      child: IgnorePointer(
        child: Builder(
          builder: (context) {
            final direction = Directionality.of(context);
            // من أعلى السطر لخط كتابته — الفقرة بتطلع لفوق بقده حتى خط أول سطر يجي بمكانه
            final ascent = (TextPainter(text: TextSpan(text: label, style: labelText), textDirection: direction, textScaler: MediaQuery.textScalerOf(context))..layout())
                .computeDistanceToActualBaseline(TextBaseline.alphabetic);

            final Widget content;
            if (direction == TextDirection.rtl) {
              content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (i, line) in body.split('\n').indexed)
                    SizedBox(
                      height: lineH,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        // السطر ما بيلتف — ولو ما وسع (خط النظام أكبر مثلاً) بيصغر
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text.rich(TextSpan(children: [if (i == 0) TextSpan(text: label, style: labelText), TextSpan(text: line, style: bodyText)]), maxLines: 1, softWrap: false),
                        ),
                      ),
                    ),
                ],
              );
            } else {
              content = SizedBox(
                height: c.s.y(bottom - baseline) + ascent,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.topStart,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: boxWidth),
                    child: Text.rich(TextSpan(children: [TextSpan(text: label, style: labelText), TextSpan(text: body.replaceAll('\n', ' '), style: bodyText)])),
                  ),
                ),
              );
            }
            return OverflowBox(
              alignment: AlignmentDirectional.topStart,
              minHeight: 0,
              maxHeight: double.infinity,
              child: Transform.translate(offset: Offset(0, -ascent), child: SizedBox(width: boxWidth, child: content)),
            );
          },
        ),
      ),
    );
  }
}
