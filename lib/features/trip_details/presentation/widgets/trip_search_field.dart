import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_line.dart';
import 'chevron_down_icon.dart';
import 'trip_colors.dart';

// -------------------------------------------------------------
// حقل الاختيار ("SearchField" — 331×38 أبيض بحد #1F3B2E 1 radius 10، padding 8):
// بالبداية سهم "⌄" (مربعه 24) وبعده بـ 6 الاختيار (16 Regular #1F3B2E) — والضغط بيفتح القائمة
// -------------------------------------------------------------
class TripSearchField extends StatelessWidget {
  final FigmaCanvas c;
  final double left;
  final double top;
  final String text;

  /// لسا ما في اختيار ([text] = النص الإرشادي)
  final bool empty;
  final VoidCallback onTap;

  const TripSearchField({super.key, required this.c, required this.left, required this.top, required this.text, this.empty = false, required this.onTap});

  static const width = 331.0;
  static const height = 38.0;

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    final right = left + width;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.box(left: left, top: top, width: width, height: height, radius: 10, color: Colors.white, borderColor: TripColors.green),
        // مربع السهم 24×24 بعد 8 من طرف الحقل
        c.rect(
          left: right - 8 - 24,
          top: top + 7,
          width: 24,
          height: 24,
          child: Center(child: ChevronDownIcon(width: s.x(9.7), height: s.x(5), stroke: s.x(1.5), color: TripColors.green)),
        ),
        c.line(
          text,
          left: left + 8,
          top: top + 8,
          width: width - 16 - 24 - 6,
          height: 22,
          style: c.style(16, FigmaWeight.sfRegular, empty ? const Color(0xFF717171) : TripColors.green),
        ),
        c.tapArea(left: left, top: top, width: width, height: height, onTap: onTap),
      ],
    );
  }
}
