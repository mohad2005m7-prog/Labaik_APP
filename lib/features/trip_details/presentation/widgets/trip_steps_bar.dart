import 'package:flutter/material.dart';

import '../../../../core/utils/figma_canvas.dart';
import 'trip_colors.dart';

// -------------------------------------------------------------
// خطوات التعديل ("Slider" فوق شاشات التعديل): 7 خطوط 37.2×4 كل 53.75 (مقاسة من رندر Figma)
// اللي وصلها المعتمر #1F3B2E والباقي #1F3B2E 50% — بتتعبّى من البداية (اليمين بالعربي)
// -------------------------------------------------------------
class TripStepsBar extends StatelessWidget {
  final FigmaCanvas c;
  final int done;

  const TripStepsBar({super.key, required this.c, required this.done});

  static const count = 7;
  static const _firstRight = 367.6;
  static const _pitch = 53.75;
  static const _width = 37.2;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (var i = 0; i < count; i++)
          c.box(left: _firstRight - _width - i * _pitch, top: 127.55, width: _width, height: 4, radius: 2, color: i < done ? TripColors.green : TripColors.stepIdle),
      ],
    );
  }
}
