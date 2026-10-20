import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_lines.dart';
import 'company_box.dart';
import 'company_colors.dart';

/// مكان كرت رقم بالرئيسية (Figma 455:2885): الكرت، دائرة الأيقونة 32، الأيقونة، طرف النص اليمين، طرف الرقم اليمين
typedef CompanyStatSlot = ({Rect card, Offset circle, Rect icon, double labelTop, double labelRight, double numberTop, double numberRight});

// -------------------------------------------------------------
// كرت رقم (170.5×73 — #ECF4F1 — radius 10 — ظل (0,4) blur 4 #1F3B2E 25%):
// [onTap] = الكرت كله بيفتح شاشته — دائرة 32 وراء الأيقونة، العنوان SF Compact 556 14 والرقم SF Compact 556 16 (letter spacing -0.408، طرفهم اليمين ثابت)
// -------------------------------------------------------------
abstract final class CompanyStatCard {
  static List<Widget> build(FigmaCanvas c, CompanyStatSlot slot, {required String icon, required String label, required int value, VoidCallback? onTap}) {
    final style = c.style(14, FigmaWeight.semiBold, CompanyColors.green);
    final number = c.style(16, FigmaWeight.semiBold, CompanyColors.green);
    final card = slot.card;
    return [
      companyBox(c, left: card.left, top: card.top, width: card.width, height: card.height, color: CompanyColors.statCard, shadow: CompanyColors.greenShadow),
      companyBox(c, left: slot.circle.dx, top: slot.circle.dy, width: 32, height: 32, color: CompanyColors.cardInset, circle: true, shadow: CompanyColors.shadow),
      c.image('$companyAssets/$icon.png', left: slot.icon.left, top: slot.icon.top, width: slot.icon.width, height: slot.icon.height, color: CompanyColors.green),
      FigmaLines.build(c, label, left: slot.labelRight - 150, top: slot.labelTop, width: 150, style: style, wrap: false),
      FigmaLines.build(c, '$value', left: slot.numberRight - 80, top: slot.numberTop, width: 80, style: number, wrap: false),
      if (onTap != null) c.tapArea(left: card.left, top: card.top, width: card.width, height: card.height, onTap: onTap),
    ];
  }
}
