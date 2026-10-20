import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_line.dart';
import 'trip_colors.dart';

// -------------------------------------------------------------
// خيار نوع الرحلة (Figma "Frame 38" — خيارين 361×56 radius 14 بينهم 16):
// المختار معبّى #1F3B2E ونصه وأيقونته بيض — الباقي أبيض بحد #1F3B2E وأيقونته سودا
// مربع الأيقونة 40×40 radius 10 بحد 1 (أبيض بالمختار) — الأيقونة مقصوصة من رندر Figma (34×34 جوّا المربع)
// -------------------------------------------------------------
class TripTypeOption extends StatelessWidget {
  final FigmaCanvas c;
  final double top;
  final String label;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  const TripTypeOption({super.key, required this.c, required this.top, required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ink = selected ? Colors.white : TripColors.green;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.box(left: 16, top: top, width: 361, height: 56, radius: 14, color: selected ? TripColors.green : Colors.white, borderColor: selected ? null : TripColors.green),
        c.box(left: 330, top: top + 8, width: 40, height: 40, radius: 10, color: selected ? null : Colors.white, borderColor: selected ? Colors.white : TripColors.green),
        c.image(icon, left: 333, top: top + 11, width: 34, height: 34, color: selected ? Colors.white : Colors.black),
        // SemiBold 16 — طرفه قبل مربع الأيقونة
        c.line(label, left: 121.25, top: top + 17, width: 200, height: 22, style: c.style(16, FigmaWeight.semiBold, ink)),
        c.tapArea(left: 16, top: top, width: 361, height: 56, onTap: onTap),
      ],
    );
  }
}
