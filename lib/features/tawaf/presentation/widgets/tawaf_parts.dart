import 'package:flutter/material.dart';

import '../../../../core/l10n/app_language.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_lines.dart';
import 'tawaf_page.dart';
import 'tawaf_step_spec.dart';

// -------------------------------------------------------------
// عناصر مشتركة بشاشات الطواف بأرقام Figma:
//   العنوان الفرعي: SF Compact 556 16 #4C7A75 — طرفه اليمين بصندوقه
//   الكرت: radius 10 #4C7A75 10% بظل Figma — ونصه SF Compact 556 14 #1F3B2E بالنص
//   النصوص بالنص (centered): بالإنجليزي بتاخد عرض الكروت
// -------------------------------------------------------------
abstract final class TawafParts {
  static Widget subtitle(FigmaCanvas c, String text, TawafTextBox box) {
    final arabic = AppLanguage.isArabic;
    return FigmaLines.build(
      c,
      text,
      left: arabic ? box.left : 16,
      // Figma بيرسم هالسطر (16) أعلى بـ 1.5 من صندوقه (مقاس)
      top: box.top - 1.5,
      width: arabic ? box.width : 361,
      wrap: false,
      style: c.style(16, FigmaWeight.semiBold, TawafColors.accent),
    );
  }

  /// نص بالنص (سطر أو أكتر) — [maxHeight]: مساحة الإنجليزي
  static Widget centered(FigmaCanvas c, String text, TawafTextBox box, TextStyle style, {double? maxHeight}) {
    final arabic = AppLanguage.isArabic;
    return FigmaLines.build(
      c,
      text,
      left: arabic ? box.left : 18,
      top: box.top,
      width: arabic ? box.width : 357,
      maxHeight: maxHeight,
      align: TextAlign.center,
      style: style,
    );
  }

  static Widget card(FigmaCanvas c, Rect r) => c.box(left: r.left, top: r.top, width: r.width, height: r.height, color: TawafColors.card, radius: 10, hasShadow: true);

  static TextStyle cardStyle(FigmaCanvas c, {double size = 14}) => c.style(size, FigmaWeight.semiBold, TawafColors.green);

  /// الزر الأخضر (مكوّن Button بـ Figma)
  static Widget button(FigmaCanvas c, Rect r, String label, VoidCallback onTap) =>
      c.button(label, left: r.left, top: r.top, width: r.width, height: r.height, figmaSpacing: true, onTap: onTap);
}
