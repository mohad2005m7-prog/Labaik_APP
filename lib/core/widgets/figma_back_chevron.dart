import 'package:flutter/material.dart';

import '../utils/figma_canvas.dart';
import 'figma_chevron.dart';

// -------------------------------------------------------------
// سهم الرجوع بتصاميم Figma (Path بخط): بالعربي ">" يمين الشاشة — بالإنجليزي بينعكس "<" يسار
// منطقة الضغط 44×44 حوالين السهم
// -------------------------------------------------------------
Widget figmaBackChevron(
  FigmaCanvas c,
  BuildContext context, {
  required double left,
  required double top,
  required double width,
  required double height,
  required double stroke,
  required Color color,
  VoidCallback? onTap,
}) {
  return c.rect(
    left: left + width / 2 - 22,
    top: top + height / 2 - 22,
    width: 44,
    height: 44,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ?? () => Navigator.maybePop(context),
      child: Center(child: FigmaChevron(width: c.s.x(width), height: c.s.x(height), stroke: c.s.x(stroke), color: color)),
    ),
  );
}
