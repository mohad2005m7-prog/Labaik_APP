import 'package:flutter/material.dart';

import '../../../../core/theme/figma_spaced_rich.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../domain/entities/trip.dart';
import '../l10n/trip_details_text.dart';
import '../l10n/trip_format.dart';
import 'trip_colors.dart';

// -------------------------------------------------------------
// كرت الرحلة ("Rectangle 60" — 361×238 #EEF2F2 radius 10 بظل Figma):
// "رحلتك الحالية : …" بخانة متدرجة — موعد الوصول — نقطة الوصول — الميقات — "سنذكّرك…" متدرج
// السطور بنص الكرت (مكان مركز كل سطر بـ Figma) لأنه طولها بيتغير مع بيانات المعتمر
// -------------------------------------------------------------
class TripSummaryCard extends StatelessWidget {
  final FigmaCanvas c;
  final Trip trip;

  const TripSummaryCard({super.key, required this.c, required this.trip});

  // أعرض سطر بيوسع جوّا الكرت (361 ناقص 10 من كل جهة) — الأطول بيصغر ليوسع
  static const _lineMax = 341.0;

  // سطر بنص الكرت: مركزه [centerX] وصندوقه بـ Figma من [top] (طوله 22)
  Widget _centered(double centerX, double top, List<TextSpan> spans, {double maxWidth = _lineMax}) {
    return c.rect(
      left: centerX - 175,
      top: top + FigmaCanvas.baselineFix,
      width: 350,
      height: 22,
      child: IgnorePointer(
        child: OverflowBox(
          maxWidth: double.infinity,
          child: Center(child: FigmaSpacedRich(spans: spans, letterSpacing: c.s.x(-0.408), align: TextAlign.center, maxWidth: c.s.x(maxWidth))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SF Compact 457 و 556 بحجم 16 — #1F3B2E
    final regular = c.style(16, FigmaWeight.sfRegular, TripColors.green);
    final medium = c.style(16, FigmaWeight.semiBold, TripColors.green);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.box(left: 16, top: 155, width: 361, height: 238, color: TripColors.cardFill, radius: 10, hasShadow: true),
        // "Rectangle 61" 161×38 radius 10 متدرج
        c.box(left: 116, top: 179, width: 161, height: 38, gradient: TripColors.gradient, radius: 10),
        _centered(195.5, 187, [TextSpan(text: TripDetailsText.current(TripFormat.type(trip.type)), style: c.style(16, FigmaWeight.semiBold, Colors.white))], maxWidth: 147),
        _centered(194.75, 233, [TextSpan(text: TripDetailsText.arrivalDate(), style: regular), TextSpan(text: TripFormat.date(trip.departureDate), style: medium)]),
        _centered(194, 271, [TextSpan(text: TripDetailsText.arrivalPoint(), style: regular), TextSpan(text: TripFormat.isolate(TripFormat.place(trip)), style: medium)]),
        _centered(192, 309, [TextSpan(text: TripDetailsText.miqat(), style: regular)]),
        // نص متدرج (نفس تدرج الخانة) — صندوقه بـ Figma 34..360، والتدرج عمودي فبنعرّضه لعرض الكرت (الـ ShaderMask بيقص اللي برّاه)
        c.rect(
          left: 197 - _lineMax / 2,
          top: 348 + FigmaCanvas.baselineFix,
          width: _lineMax,
          height: 22,
          child: IgnorePointer(
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: TripColors.gradient.createShader,
              child: OverflowBox(
                maxWidth: double.infinity,
                child: Center(
                  child: FigmaSpacedRich(
                    spans: [TextSpan(text: TripDetailsText.reminder(), style: c.style(16, FigmaWeight.sfRegular, Colors.white))],
                    letterSpacing: c.s.x(-0.408),
                    align: TextAlign.center,
                    maxWidth: c.s.x(_lineMax),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
