import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_lines.dart';
import 'company_box.dart';
import 'company_colors.dart';

// -------------------------------------------------------------
// كرت إجراء غامق بالرئيسية ("إنشاء رحلة" / "إنشاء المجموعات"): 170.5×73 من y635 — #1F3B2E — radius 10 — ظل #1F3B2E 25%
// أيقونة 24 بيضا، العنوان SF Compact 556 14 أبيض (y652) وتحته SF Compact 350 10 (y678) — طرفهم اليمين [textRight]
// -------------------------------------------------------------
abstract final class CompanyActionCard {
  static const top = 635.0;

  static List<Widget> build(
    FigmaCanvas c, {
    required double left,
    required double iconLeft,
    required double textRight,
    required String icon,
    required String title,
    required String hint,
    required VoidCallback onTap,
  }) {
    return [
      companyBox(c, left: left, top: top, width: 170.5, height: 73, color: CompanyColors.green, shadow: CompanyColors.greenShadow),
      c.image('$companyAssets/$icon.png', left: iconLeft, top: 651, width: 24, height: 24, color: Colors.white),
      FigmaLines.build(c, title, left: textRight - 150, top: 652, width: 150, style: c.style(14, FigmaWeight.semiBold, Colors.white), wrap: false),
      FigmaLines.build(c, hint, left: textRight - 150, top: 678, width: 150, style: c.style(10, FigmaWeight.poppinsRegular, Colors.white), wrap: false),
      c.tapArea(left: left, top: top, width: 170.5, height: 73, onTap: onTap),
    ];
  }
}
