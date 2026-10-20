import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_lines.dart';
import '../../domain/entities/company_group.dart';
import '../l10n/company_groups_text.dart';
import 'company_box.dart';
import 'company_colors.dart';
import 'company_trip_card.dart';

// -------------------------------------------------------------
// كرت مجموعة — Figma "المجموعات" (473:4874) و"تفاصيل الرحلة" (738:4590): 361×158 من x16
//   يمين: مربع 45 فيه أيقونة المجموعة — الاسم / "25 معتمر" / "مشرف المجموعة : أحمد محمد" (طرفهم x308، كل 26)
//   يسار: شارة "مكتملة" (فيها مشرف) أو "غير مكتملة" (بلا مشرف) 83×21
//   خط فاصل، وتحته "عرض تفاصيل المجموعة ›" — [withLink] false بتفاصيل المجموعة (الكرت 120 بلا رابط)
// -------------------------------------------------------------
abstract final class CompanyGroupCard {
  static const height = 158.0;

  /// من أعلى كرت للي بعده
  static const pitch = 174.0;

  static List<Widget> build(FigmaCanvas c, CompanyGroup group, {required double top, VoidCallback? onTap, bool withLink = true}) {
    final green = CompanyColors.green;
    final complete = group.supervisorName != null;
    return [
      companyBox(c, left: 16, top: top, width: 361, height: withLink ? height : 120, radius: 12, color: CompanyColors.card, shadow: CompanyColors.shadow),
      companyBox(c, left: 316, top: top + 18, width: 45, height: 45, radius: 8, color: CompanyColors.cardInset, shadow: CompanyColors.shadow),
      c.image('$companyAssets/ic_groups.png', left: 327, top: top + 29, width: 24, height: 24, color: green),
      FigmaLines.build(c, group.name, left: 128, top: top + 16, width: 180, style: c.style(14, FigmaWeight.semiBold, green), wrap: false),
      FigmaLines.build(c, CompanyGroupsText.pilgrimCount(group.memberCount), left: 128, top: top + 42, width: 180, style: c.style(12, FigmaWeight.sfRegular, green), wrap: false),
      FigmaLines.build(c, CompanyGroupsText.supervisorLine(group.supervisorName ?? CompanyGroupsText.noSupervisor()), left: 128, top: top + 68, width: 180, style: c.style(12, FigmaWeight.sfRegular, green), wrap: false),
      // الشارة
      companyBox(c, left: 32, top: top + 17, width: 83, height: 21, radius: 10.5, color: complete ? green : CompanyColors.incomplete),
      FigmaLines.build(c, complete ? CompanyGroupsText.complete() : CompanyGroupsText.incomplete(), left: 32, top: top + 17, width: 83, align: TextAlign.center, style: c.style(12, FigmaWeight.sfRegular, Colors.white, lineHeight: 21), lineHeight: 21, wrap: false),
      if (withLink) ...[
        c.box(left: 24.5, top: top + 118, width: 344.5, height: 1, color: green.withValues(alpha: 0.57)),
        c.rect(left: 34, top: top + 127, width: 200, height: 22, child: CompanyDetailsLink(c: c, text: CompanyGroupsText.details())),
      ],
      if (onTap != null) c.tapArea(left: 16, top: top, width: 361, height: withLink ? height : 120, onTap: onTap),
    ];
  }
}
