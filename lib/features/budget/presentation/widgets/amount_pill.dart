import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/figma_spaced_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import 'budget_colors.dart';

// -------------------------------------------------------------
// خانة المبلغ ("Rectangle 135"): #A59063 — radius 10 — طولها 33
// المبلغ (SF Compact 656 24 أبيض) من البداية على بعد 13 — والخانة بتكبر لو المبلغ أطول من عرضها بـ Figma
// -------------------------------------------------------------
class AmountPill extends StatelessWidget {
  final FigmaCanvas c;
  final String amount;

  /// طرف الخانة من جهة البداية (يمين بالعربي) بأرقام Figma
  final double right;
  final double top;
  final double minWidth;

  /// أعلى صندوق المبلغ (22) بأرقام Figma
  final double textTop;

  const AmountPill({super.key, required this.c, required this.amount, required this.right, required this.top, required this.minWidth, required this.textTop});

  static const _height = 33.0;
  static const _textInset = 13.0;
  static const _endInset = 10.0;

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    final style = c.style(24, FigmaWeight.sfSemibold, Colors.white);
    final textWidth = FigmaSpacedText.lineWidth(context, amount, style, s.x(-0.408)) / s.sx;
    final width = math.max(minWidth, textWidth + _textInset + _endInset);
    return c.rect(
      left: right - width,
      top: top,
      width: width,
      height: _height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(color: BudgetColors.gold, borderRadius: BorderRadius.circular(s.x(10))))),
          PositionedDirectional(
            start: s.x(_textInset),
            top: s.y(textTop - top + FigmaCanvas.baselineFix),
            height: s.y(22),
            child: Center(child: FigmaSpacedText(amount, style: style, letterSpacing: s.x(-0.408), width: s.x(textWidth), maxLines: 1)),
          ),
        ],
      ),
    );
  }
}
