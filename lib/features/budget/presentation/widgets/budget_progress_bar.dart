import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/utils/figma_canvas.dart';
import 'budget_colors.dart';

// -------------------------------------------------------------
// شريط الميزانية ("Group 36786"): خلفية #4C7A75 بعرض الكرت، وفوقها #1F3B2E بنسبة اللي صرفه
// من البداية (يمين بالعربي) — أطرافه مدوّرة — سماكته 10.5
// -------------------------------------------------------------
class BudgetProgressBar extends StatelessWidget {
  final FigmaCanvas c;

  /// نسبة المصروف من الميزانية (0…1)
  final double share;

  const BudgetProgressBar({super.key, required this.c, required this.share});

  static const _left = 16.5, _top = 252.0, _width = 360.0, _height = 10.5;

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    final radius = BorderRadius.circular(s.y(_height / 2));
    // أي مصروف بيبيّن على الأقل دايرة صغيرة
    final filled = share <= 0 ? 0.0 : math.max(_height, share * _width);
    return c.rect(
      left: _left,
      top: _top,
      width: _width,
      height: _height,
      child: Stack(
        children: [
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(color: BudgetColors.teal, borderRadius: radius))),
          if (filled > 0)
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              width: s.x(filled),
              child: DecoratedBox(decoration: BoxDecoration(color: BudgetColors.green, borderRadius: radius)),
            ),
        ],
      ),
    );
  }
}
