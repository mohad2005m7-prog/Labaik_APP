import 'package:flutter/material.dart';

import '../../../../core/theme/figma_spaced_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_chevron.dart';
import '../../../../core/widgets/figma_lines.dart';
import '../../domain/entities/company_trip.dart';
import '../l10n/company_trips_text.dart';
import 'company_box.dart';
import 'company_colors.dart';

// -------------------------------------------------------------
// كرت رحلة (361×157 من x16 — #4C7A75 10% — ظل (0,4) blur 4 أسود 25%):
//   يمين: مربع الدبوس (#4C7A75 10% فوق الكرت + ظل) — الاسم SF Compact 556 14 وتحته الوجهات والتاريخ SF Compact 457 12 (طرفهم x307)
//   يسار: شارة الحالة ("قادمة" / "راحلة") #1F3B2E ونصها أبيض
//   خط فاصل، وتحته "عرض تفاصيل الرحلة ›" بآخر الكرت
// -------------------------------------------------------------
abstract final class CompanyTripCard {
  static const height = 157.0;

  /// من أعلى كرت للي بعده
  static const pitch = 176.0;

  static List<Widget> build(FigmaCanvas c, CompanyTrip trip, {required double top, required VoidCallback onDetails}) {
    final green = CompanyColors.green;
    final status = trip.status == CompanyTripStatus.upcoming ? CompanyTripsText.statusUpcoming() : CompanyTripsText.statusDeparted();
    return [
      companyBox(c, left: 16, top: top, width: 361, height: height, radius: 12, color: CompanyColors.card, shadow: CompanyColors.shadow),
      companyBox(c, left: 315, top: top + 18, width: 46, height: 44, radius: 8, color: CompanyColors.cardInset, shadow: CompanyColors.shadow),
      c.image('$companyAssets/ic_pin.png', left: 327, top: top + 28, width: 24, height: 24, color: green),
      FigmaLines.build(c, trip.title, left: 108, top: top + 15, width: 200, style: c.style(14, FigmaWeight.semiBold, green), wrap: false),
      FigmaLines.build(c, trip.destinations, left: 108, top: top + 41, width: 200, style: c.style(12, FigmaWeight.sfRegular, green), wrap: false),
      FigmaLines.build(c, trip.dates, left: 108, top: top + 66.5, width: 200, style: c.style(12, FigmaWeight.sfRegular, green), wrap: false),
      // الشارة
      companyBox(c, left: 32, top: top + 16.5, width: 84, height: 21.5, radius: 10.75, color: green),
      FigmaLines.build(c, status, left: 32, top: top + 16.5, width: 84, align: TextAlign.center, style: c.style(12, FigmaWeight.sfRegular, Colors.white, lineHeight: 21.5), lineHeight: 21.5, wrap: false),
      // الخط الفاصل والرابط
      c.box(left: 24.5, top: top + 117.5, width: 344.5, height: 1, color: green.withValues(alpha: 0.57)),
      // "عرض تفاصيل الرحلة ›": السهم بحافة الكرت (x34) والنص ملزوق فيه (بعده بـ 8.5)
      c.rect(left: 34, top: top + 127, width: 200, height: 22, child: _DetailsLink(c: c)),
      c.tapArea(left: 16, top: top + 118, width: 361, height: height - 118, onTap: onDetails),
    ];
  }
}

// السهم "‹" (Icon / chevron.left — حبره 5×11.5 بخط 1.5) وبعده بـ 10 النص SF Compact 457 12
class _DetailsLink extends StatelessWidget {
  final FigmaCanvas c;

  const _DetailsLink({required this.c});

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    final style = c.style(12, FigmaWeight.sfRegular, CompanyColors.green);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final text = CompanyTripsText.details();
    final width = FigmaSpacedText.lineWidth(context, text, style, s.x(-0.408));
    return IgnorePointer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: rtl
                ? SizedBox(width: width, child: FigmaSpacedText(text, style: style, letterSpacing: s.x(-0.408), width: width, maxLines: 1))
                : Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
          ),
          SizedBox(width: s.x(10)),
          Padding(
            padding: EdgeInsets.only(bottom: s.y(2)),
            child: FigmaChevron(width: s.x(3.5), height: s.x(10), stroke: s.x(1.5), color: CompanyColors.green, pointsToEnd: true),
          ),
        ],
      ),
    );
  }
}
