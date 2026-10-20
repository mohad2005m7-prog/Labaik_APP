import 'package:flutter/material.dart';

import '../../../../core/utils/figma_canvas.dart';
import 'trip_colors.dart';

// -------------------------------------------------------------
// التقويم تحت حقل التاريخ — نفس شاشة الإعداد ("DatePicker" 357×325 أبيض radius 13 بظل Figma)
// بالشكل الإنجليزي زي Figma، واليوم المختار #4C7A75 — بيسكّر لما يختار يوم
// -------------------------------------------------------------
class TripCalendarCard extends StatelessWidget {
  final FigmaCanvas c;
  final double top;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;

  const TripCalendarCard({super.key, required this.c, required this.top, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = selected == null || selected!.isBefore(today) ? today : selected!;
    return c.rect(
      left: 18,
      top: top,
      width: 357,
      height: 325,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(c.s.x(13)), boxShadow: [c.shadow]),
        child: Theme(
          data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: TripColors.teal, onPrimary: Colors.white, onSurface: Color(0xFF3C3C43))),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: CalendarDatePicker(initialDate: initial, firstDate: today, lastDate: DateTime(today.year + 2, 12, 31), onDateChanged: onSelected),
          ),
        ),
      ),
    );
  }
}
