import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import 'chevron_down_icon.dart';
import 'trip_colors.dart';
import 'trip_field_icons.dart';

// -------------------------------------------------------------
// حقل التاريخ / الوقت (Figma 7تعديل "Rectangle 24/25" — 336×40 من x27 أبيض بحد #1F3B2E 1 radius 10):
// الأيقونة بالبداية (التقويم 22.5 عند x329.75 أو الساعة 24 عند x331) — القيمة (SF Compact 457 12 #1F3B2E)
// طرفها عند x317 — وسهم بمربع 24 عند x43: "⌄" والقائمة مسكّرة و"⌃" وهي مفتوحة (زي شاشة الإعداد)
// -------------------------------------------------------------
enum TripFieldIcon { calendar, clock }

class TripPickerField extends StatelessWidget {
  final FigmaCanvas c;
  final double top;
  final TripFieldIcon icon;
  final String text;
  final bool empty;
  final bool open;

  /// طرف القيمة (Figma: التاريخ 313.5 والوقت 315 — مقاس)
  final double textRight;
  final VoidCallback onTap;

  const TripPickerField({super.key, required this.c, required this.top, required this.icon, required this.text, this.empty = false, this.open = false, required this.textRight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.box(left: 27, top: top, width: 336, height: 40, radius: 10, color: Colors.white, borderColor: TripColors.green),
        switch (icon) {
          TripFieldIcon.calendar => c.rect(left: 329.75, top: top + 8.75, width: 22.5, height: 22.5, child: Center(child: TripCalendarIcon(size: s.x(22.5)))),
          TripFieldIcon.clock => c.rect(left: 331, top: top + 8, width: 24, height: 24, child: Center(child: TripClockIcon(size: s.x(24)))),
        },
        c.text(text, left: textRight - 240, top: top + 13, width: 240, height: 14, dy: 0, style: c.style(12, FigmaWeight.sfRegular, empty ? const Color(0xFF717171) : TripColors.green, lineHeight: null, letterSpacing: 0)),
        c.rect(
          left: 43,
          top: top + 8,
          width: 24,
          height: 24,
          child: Center(
            child: RotatedBox(quarterTurns: open ? 2 : 0, child: ChevronDownIcon(width: s.x(9.7), height: s.x(5), stroke: s.x(1.5), color: TripColors.green)),
          ),
        ),
        c.tapArea(left: 27, top: top, width: 336, height: 40, onTap: onTap),
      ],
    );
  }
}
