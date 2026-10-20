import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_lines.dart';
import '../cubits/company_trips_cubit.dart';
import '../l10n/company_trips_text.dart';
import 'company_box.dart';
import 'company_colors.dart';

// -------------------------------------------------------------
// أزرار الفلترة (81×48 من y151 — بينهم 9): الكل / القادمة / الراحلة
// المختار #1F3B2E ونصه أبيض — الباقي أبيض بحد 1 #1F3B2E — النص SF Compact 556 16 بالنص (letter spacing -0.408)
// -------------------------------------------------------------
abstract final class CompanyFilterChips {
  static const top = 151.0;
  static const height = 48.0;

  static const _chips = [
    (CompanyTripsFilter.all, 296.5, CompanyTripsText.all),
    (CompanyTripsFilter.upcoming, 207.0, CompanyTripsText.upcoming),
    (CompanyTripsFilter.departed, 117.0, CompanyTripsText.departed),
  ];

  static List<Widget> build(FigmaCanvas c, {required CompanyTripsFilter selected, required ValueChanged<CompanyTripsFilter> onSelect}) {
    return [
      for (final (filter, left, label) in _chips) ...[
        companyBox(
          c,
          left: left,
          top: top,
          width: 81,
          height: height,
          radius: 14,
          color: filter == selected ? CompanyColors.green : Colors.white,
          borderColor: filter == selected ? null : CompanyColors.green,
        ),
        FigmaLines.build(c, label(), left: left + 6, top: top + 13, width: 69, align: TextAlign.center, style: c.style(16, FigmaWeight.semiBold, filter == selected ? Colors.white : CompanyColors.green), wrap: false),
        c.tapArea(left: left, top: top, width: 81, height: height, onTap: () => onSelect(filter)),
      ],
    ];
  }
}
