import 'package:flutter/material.dart';

import '../../../../core/utils/figma_canvas.dart';

// -------------------------------------------------------------
// زر Figma (361×50 — c.button) وهو بيستنى رد السيرفر: نفس الزر وجوّاه دوّارة بدل النص (وما بينضغط)
// -------------------------------------------------------------
Widget familyButton(
  FigmaCanvas c,
  String label, {
  required double left,
  required double top,
  required VoidCallback onTap,
  bool busy = false,
  bool outlined = false,
  Color borderColor = FigmaCanvas.green,
  double width = 361,
}) {
  if (!busy) return c.button(label, left: left, top: top, width: width, outlined: outlined, borderColor: borderColor, figmaSpacing: true, onTap: onTap);
  final s = c.s;
  final ink = outlined ? FigmaCanvas.green : Colors.white;
  return c.rect(
    left: left,
    top: top,
    width: width,
    height: 50,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: outlined ? Colors.white : FigmaCanvas.green,
        borderRadius: BorderRadius.circular(s.x(14)),
        border: outlined ? Border.all(color: borderColor, width: s.x(1)) : null,
      ),
      child: Center(child: SizedBox.square(dimension: s.x(22), child: CircularProgressIndicator(strokeWidth: 2.4, color: ink))),
    ),
  );
}
