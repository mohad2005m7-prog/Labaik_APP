import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';

// -------------------------------------------------------------
// كرت إشعار (Figma 114:10192 — Group 36809 "إعلان جديد للمجموعة"):
// 345×85 من x24 — #EEF2F2 — radius 10 — بدون ظل
// الجرس 24×24 (334, +8) — العنوان SF Compact 556 16 طرفه x326 (+11) — النص SF Compact 350 14 طرفه x353 (+40) — #1F3B2E
// -------------------------------------------------------------
abstract final class NotificationCard {
  static const height = 85.0;
  static const _fill = Color(0xFFEEF2F2);
  static const _green = Color(0xFF1F3B2E);
  static const _bell = 'assets/images/notifications/ic_bell.png';

  static List<Widget> build(FigmaCanvas c, {required double top, required String title, required String body, required VoidCallback onTap}) {
    return [
      c.box(left: 24, top: top, width: 345, height: height, color: _fill, radius: 10),
      c.image(_bell, left: 334, top: top + 8, width: 24, height: 24),
      c.text(title, left: 40, top: top + 11, width: 286, height: 19, dy: 0, style: c.style(16, FigmaWeight.semiBold, _green, lineHeight: null, letterSpacing: 0)),
      c.text(body, left: 40, top: top + 40, width: 313, height: 17, dy: 0, style: c.style(14, FigmaWeight.poppinsRegular, _green, lineHeight: null, letterSpacing: 0)),
      c.tapArea(left: 24, top: top, width: 345, height: height, onTap: onTap),
    ];
  }
}
