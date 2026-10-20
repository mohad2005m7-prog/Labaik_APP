import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_line.dart';
import 'trip_colors.dart';

// -------------------------------------------------------------
// خيار وسيلة الوصول (Figma "Group 19/20/21" — 342×47.37 من x27):
// المختار معبّى #1F3B2E ونصه وأيقونته بيض — الباقي أبيض بحد #1F3B2E وأيقونته #1F3B2E
// الاسم SemiBold 14 قبل الأيقونة ("svgexport-20" عند x331 — مقصوصة من رندر Figma)
// -------------------------------------------------------------
class ArrivalMethodOption extends StatelessWidget {
  final FigmaCanvas c;
  final double top;
  final String label;
  final String icon;

  /// مكان الأيقونة من أعلى الخيار وطولها (Figma: 17.34/23 للطائرة، 13.82/22 للحافلة، 16.29/23 للسيارة)
  final double iconTop;
  final double iconHeight;

  /// إزاحة الاسم عن نص الخيار (Figma: اسم "طائرة" أعلى بـ 3.5 من الباقي — مقاس)
  final double labelDy;
  final bool selected;
  final VoidCallback onTap;

  const ArrivalMethodOption({
    super.key,
    required this.c,
    required this.top,
    required this.label,
    required this.icon,
    required this.iconTop,
    required this.iconHeight,
    this.labelDy = 0,
    required this.selected,
    required this.onTap,
  });

  static const height = 47.37;

  @override
  Widget build(BuildContext context) {
    final ink = selected ? Colors.white : TripColors.green;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.box(left: 27, top: top, width: 342, height: height, radius: 10, color: selected ? TripColors.green : Colors.white, borderColor: selected ? null : TripColors.green),
        c.image(icon, left: 331, top: top + iconTop, width: 22, height: iconHeight, color: ink),
        c.line(label, left: 123.5, top: top + (height - 22) / 2 + labelDy, width: 200, height: 22, style: c.style(14, FigmaWeight.semiBold, ink)),
        c.tapArea(left: 27, top: top, width: 342, height: height, onTap: onTap),
      ],
    );
  }
}
