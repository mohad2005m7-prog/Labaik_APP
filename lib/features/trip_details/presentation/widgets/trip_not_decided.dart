import 'package:flutter/material.dart';

import '../../../../core/utils/figma_canvas.dart';
import '../../../auth/presentation/l10n/departure_text.dart';
import 'trip_choice_marks.dart';
import 'trip_colors.dart';

// -------------------------------------------------------------
// "لم أحدد موعد الوصول بعد" (Figma 7تعديل: مربع "Group 39" 20×20 عند x341 y435 والنص "Group 40" لحد x331)
// المربع نفس مربعات شاشات التعديل التانية (فاضي أبيض بحد #1F3B2E، والمختار #4C7A75 بـ ✓)
// -------------------------------------------------------------
class TripNotDecided extends StatelessWidget {
  final FigmaCanvas c;
  final bool checked;
  final VoidCallback onTap;

  const TripNotDecided({super.key, required this.c, required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.rect(left: 341, top: 435, width: 20, height: 20, child: Center(child: TripCheckbox(size: c.s.x(20), checked: checked))),
        c.text(DepartureText.arrivalNotDecided(), left: 129.5, top: 437, width: 200, height: 15, dy: 0, style: c.style(12, 450, TripColors.green, lineHeight: null, letterSpacing: 0)),
        // الضغط على المربع أو النص
        c.tapArea(left: 131, top: 427, width: 238, height: 36, onTap: onTap),
      ],
    );
  }
}
