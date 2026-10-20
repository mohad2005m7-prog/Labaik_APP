import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import 'help_colors.dart';
import 'help_text.dart';

// -------------------------------------------------------------
// حقل بنموذج البلاغ (Figma "Rectangle 128/130/131"): أبيض بحد #1F3B2E 1 و radius 10
// النص (SF Compact 457 14): الـ placeholder رمادي #717171 لحد ما يختار، وبعدها أسود
// [textRight]/[textTop]/[hintWidth]: صندوق الـ placeholder بـ Figma — [room]: المساحة اللي بتوسعها القيمة
// [leading]: الأيقونة جوّا الحقل (مكانها بأرقام Figma) — والضغط بأي مكان بالحقل [onTap]
// -------------------------------------------------------------
abstract final class ReportField {
  static List<Widget> build(
    FigmaCanvas c, {
    required Rect box,
    required String text,
    required bool empty,
    required double textRight,
    required double textTop,
    required double hintWidth,
    required double room,
    required VoidCallback onTap,
    List<Widget> leading = const [],
  }) {
    final style = c.style(14, FigmaWeight.sfRegular, empty ? HelpColors.grey : Colors.black);
    return [
      frame(c, box),
      ...leading,
      // القيمة المختارة ما إلها صندوق بـ Figma → بتاخد المساحة كلها وبتصغر لو طوّلت
      if (empty)
        HelpText.line(c, text, right: textRight, top: textTop, boxWidth: hintWidth, room: room, style: style)
      else
        c.text(text, left: textRight - room, top: textTop, width: room, height: 22, style: style),
      c.tapArea(left: box.left, top: box.top, width: box.width, height: box.height, onTap: onTap),
    ];
  }

  static Widget frame(FigmaCanvas c, Rect box) => c.box(left: box.left, top: box.top, width: box.width, height: box.height, color: Colors.white, radius: 10, borderColor: HelpColors.green);
}
