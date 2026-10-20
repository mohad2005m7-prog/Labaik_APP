import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../l10n/notifications_text.dart';

// -------------------------------------------------------------
// عنوان اليوم فوق الكروت (Figma "✏️  Time" 267×13 من x63 — بالنص):
// SF Compact 11 — line height 13 — #3C3C43 60% — "اليوم" وزن 457 (ls 0.066) والباقي وزن 556 (ls 0.06)
// "اليوم" / "الأمس 9:40" (وقت أحدث إشعار فيه) / التاريخ للأقدم
// -------------------------------------------------------------
abstract final class NotificationDayLabel {
  static const height = 13.0;
  static const _color = Color(0x993C3C43);

  static String of(DateTime at, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final days = DateTime(n.year, n.month, n.day).difference(DateTime(at.year, at.month, at.day)).inDays;
    if (days <= 0) return NotificationsText.today();
    if (days == 1) return NotificationsText.yesterdayAt('${at.hour % 12 == 0 ? 12 : at.hour % 12}:${at.minute.toString().padLeft(2, '0')}');
    return NotificationsText.date(at);
  }

  static Widget build(FigmaCanvas c, String label, {required double top, required bool first}) {
    return c.text(
      label,
      left: 63,
      top: top,
      width: 267,
      height: height,
      align: TextAlign.center,
      dy: 0,
      style: c.style(11, first ? FigmaWeight.sfRegular : FigmaWeight.semiBold, _color, lineHeight: 13, letterSpacing: first ? 0.066 : 0.06),
    );
  }
}
