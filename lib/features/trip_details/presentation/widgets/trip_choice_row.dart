import 'package:flutter/material.dart';

import '../../../../core/utils/figma_canvas.dart';
import 'trip_choice_marks.dart';

// -------------------------------------------------------------
// خيار بشاشات التعديل: علامة 20×20 (دائرة أو مربع) عند [markLeft],[markTop]
// والاسم قبلها وطرفه عند [labelRight] (بنص العلامة عمودياً) — الضغط على السطر كله
// -------------------------------------------------------------
class TripChoiceRow extends StatelessWidget {
  final FigmaCanvas c;
  final double markLeft;
  final double markTop;
  final bool round;
  final bool checked;
  final String label;
  final double labelRight;
  final TextStyle style;

  /// إزاحة الاسم عن نص العلامة (أسماء "أين ستقيم؟" بـ Figma أعلى بـ 2.5 — مقاس)
  final double labelDy;
  final VoidCallback onTap;

  const TripChoiceRow({
    super.key,
    required this.c,
    required this.markLeft,
    required this.markTop,
    required this.round,
    required this.checked,
    required this.label,
    required this.labelRight,
    required this.style,
    this.labelDy = 0,
    required this.onTap,
  });

  /// طول صندوق الاسم (line height auto) — الاسم بنص العلامة
  static const _labelBox = 18.0;

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    final mark = round ? TripRadio(size: s.x(20), checked: checked) : TripCheckbox(size: s.x(20), checked: checked);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.rect(left: markLeft, top: markTop, width: 20, height: 20, child: Center(child: mark)),
        c.text(label, left: labelRight - 250, top: markTop + (20 - _labelBox) / 2 + labelDy, width: 250, height: _labelBox, dy: 0, style: style),
        c.tapArea(left: labelRight - 160, top: markTop - 4, width: markLeft + 24 - (labelRight - 160), height: 28, onTap: onTap),
      ],
    );
  }
}
