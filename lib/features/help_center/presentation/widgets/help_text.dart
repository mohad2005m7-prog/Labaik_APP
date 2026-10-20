import 'package:flutter/material.dart';

import '../../../../core/theme/figma_spaced_text.dart';
import '../../../../core/utils/figma_canvas.dart';

// -------------------------------------------------------------
// نصوص Figma بشاشات مركز المساعدة (letter spacing -0.408 زي Figma — شوف FigmaSpacedText):
//   line: سطر واحد صندوقه بـ Figma على قد النص (Auto width) وطرفه عند [right]
//   paragraph: سطور Figma مكسورة بـ "\n" (والإنجليزي بيلتف لحاله ولو طوّل بيصغر شوي)
// -------------------------------------------------------------
abstract final class HelpText {
  static bool arabic(String text) => text.runes.any((r) => r >= 0x0600 && r <= 0x06FF);

  /// [boxWidth]: عرض صندوق Figma — [room]: المساحة اللي بتوسعها الترجمة (افتراضياً نفس الصندوق)
  static Widget line(
    FigmaCanvas c,
    String text, {
    required double right,
    required double top,
    required double boxWidth,
    required TextStyle style,
    double? room,
    double height = 22,
    double dy = FigmaCanvas.baselineFix,
    TextAlign align = TextAlign.start,
  }) {
    final width = room ?? boxWidth;
    final center = align == TextAlign.center;
    final alignment = center ? AlignmentDirectional.center : AlignmentDirectional.centerStart;
    return c.rect(
      left: center ? right - boxWidth / 2 - width / 2 : right - width,
      top: top + dy,
      width: width,
      height: height,
      child: IgnorePointer(
        child: Builder(
          builder: (context) => Align(
            alignment: alignment,
            child: Directionality.of(context) == TextDirection.rtl && arabic(text)
                ? FigmaSpacedText(text, style: style, letterSpacing: c.s.x(-0.408), width: c.s.x(boxWidth), fitWidth: true, align: align)
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: alignment,
                    child: Text(text, style: style, maxLines: 1, softWrap: false),
                  ),
          ),
        ),
      ),
    );
  }

  /// فقرة بصندوق Figma [left]..[left+width] — [lines]: عدد سطورها بـ Figma (line height 22)
  static Widget paragraph(
    FigmaCanvas c,
    String text, {
    required double left,
    required double top,
    required double width,
    required int lines,
    required TextStyle style,
    TextAlign align = TextAlign.start,
    double lineHeight = 22,
    double dy = FigmaCanvas.baselineFix,
  }) {
    final parts = text.split('\n');
    final alignment = align == TextAlign.center ? Alignment.topCenter : AlignmentDirectional.topStart;
    return c.rect(
      left: left,
      top: top + dy,
      width: width,
      height: lineHeight * lines,
      child: IgnorePointer(
        child: Align(
          alignment: alignment,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: alignment,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [for (final part in parts) FigmaSpacedText(part, style: style, letterSpacing: c.s.x(-0.408), width: c.s.x(width), align: align, maxLines: parts.length == 1 ? lines + 1 : 1)],
            ),
          ),
        ),
      ),
    );
  }
}

/// placeholder بحقل كتابة بسطر Figma واحد (العربي بينضغط لعرض صندوقه [width] بالظبط — والإنجليزي بيصغر لو ما وسع)
class HelpHint extends StatelessWidget {
  final String text;
  final double width;
  final TextStyle style;

  const HelpHint({super.key, required this.text, required this.width, required this.style});

  @override
  Widget build(BuildContext context) {
    if (Directionality.of(context) == TextDirection.rtl && HelpText.arabic(text)) {
      return FigmaSpacedText(text, style: style, letterSpacing: 0, width: width, fitWidth: true);
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Text(text, style: style, maxLines: 1, softWrap: false),
    );
  }
}
