import 'package:flutter/material.dart';

import '../../../../core/utils/figma_canvas.dart';

// -------------------------------------------------------------
// مستطيل Figma بظل (0,4) blur 4 بلون الظل تبعه (أسود 25% أو #1F3B2E 25%) — وحد اختياري
// (blur 4 بـ Figma = blurRadius 2.6 بـ Flutter، زي FigmaCanvas.shadow)
// -------------------------------------------------------------
Widget companyBox(
  FigmaCanvas c, {
  required double left,
  required double top,
  required double width,
  required double height,
  required Color color,
  double radius = 10,
  Color? shadow,
  Color? borderColor,
  bool circle = false,
}) {
  final s = c.s;
  return c.rect(
    left: left,
    top: top,
    width: width,
    height: height,
    child: IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(s.x(radius)),
          border: borderColor == null ? null : Border.all(color: borderColor, width: s.x(1)),
          boxShadow: shadow == null ? null : [BoxShadow(color: shadow, offset: Offset(0, s.y(4)), blurRadius: s.x(2.6))],
        ),
      ),
    ),
  );
}
