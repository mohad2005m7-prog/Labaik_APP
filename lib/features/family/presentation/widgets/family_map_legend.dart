import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../l10n/family_map_text.dart';
import 'family_colors.dart';
import 'family_icons.dart';

// -------------------------------------------------------------
// مفتاح الخريطة (Figma: 4 كروت #EEF2F2 radius 10 تحت الخريطة) — الأيقونة بطرف الكرت والنص قبلها:
//   متصلون بالانترنت (206,570) 📍أحمر — نقطة التجمع (16,570) 🚩 — موقعك أنت (16,619) 🔵 — غير متصلون (206,620) 📍فاتح
// النصوص Poppins 600 (12 و 13 بـ Figma — بالعربي 11.1 و 12.2 حتى يطلعوا بنفس عرض حبر Figma) #1F3B2E
// -------------------------------------------------------------
/// [dy]: إزاحة عمودية (خريطة المجموعة 111:6611 الكروت أعلى بـ 7)
List<Widget> familyMapLegend(FigmaCanvas c, {double dy = 0}) {
  final s = c.s;
  TextStyle style(double size) => c.style(size, FigmaWeight.semiBold, FamilyColors.green, lineHeight: null, letterSpacing: 0);
  Widget chip(Rect r) => c.box(left: r.left, top: r.top + dy, width: r.width, height: r.height, color: FamilyColors.cardFill, radius: 10);
  // نص طرفه [right] ومركزه العمودي [centerY]
  Widget label(String text, {required double right, required double centerY, required double size, double room = 120}) =>
      c.text(text, left: right - room, top: centerY + dy - 10, width: room, height: 20, dy: 0, style: style(size));
  return [
    chip(const Rect.fromLTWH(206, 570, 171, 34)),
    c.rect(left: 339.5, top: 574 + dy, width: 16, height: 23, child: IgnorePointer(child: MapPinIcon(width: s.x(16), height: s.x(23), color: FamilyColors.pinOnline))),
    label(FamilyMapText.online(), right: 324, centerY: 586, size: 11.1),

    chip(const Rect.fromLTWH(16, 570, 173, 34)),
    c.rect(left: 156.5, top: 575 + dy, width: 14.3, height: 21.5, child: IgnorePointer(child: FlagIcon(height: s.x(21.5)))),
    label(FamilyMapText.meetingPoint(), right: 127.5, centerY: 586.5, size: 12.2),

    chip(const Rect.fromLTWH(16, 619, 173, 34)),
    c.rect(left: 156.5, top: 623.5 + dy, width: 12, height: 24.5, child: IgnorePointer(child: BallPinIcon(height: s.x(24.5), color: FamilyColors.me))),
    label(FamilyMapText.you(), right: 129, centerY: 633.75, size: 12.2),

    chip(const Rect.fromLTWH(206, 620, 171, 34)),
    c.rect(left: 339.5, top: 623.5 + dy, width: 16, height: 23, child: IgnorePointer(child: MapPinIcon(width: s.x(16), height: s.x(23), color: FamilyColors.pinOffline))),
    label(FamilyMapText.offline(), right: 320.5, centerY: 634.5, size: 11.1, room: 140),
  ];
}
