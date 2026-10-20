import 'package:flutter/material.dart';

import '../../../../core/theme/figma_spaced_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../auth/presentation/l10n/stay_text.dart';
import 'trip_colors.dart';

// -------------------------------------------------------------
// "إقامتك في …" فوق خيارات كل مدينة (Figma 8 و9 تعديل): 161×28 #4C7A75 25% بحد #1F3B2E 50% 1 radius 9
// النص (SF Compact 656 12 #1F3B2E) بنص الخانة تقريباً (مركزه أبعد بـ 3.25 لليمين — مقاس)
// -------------------------------------------------------------
class TripStayChip extends StatelessWidget {
  final FigmaCanvas c;
  final double left;
  final double top;
  final String city;

  const TripStayChip({super.key, required this.c, required this.left, required this.top, required this.city});

  static const width = 161.0;
  static const height = 28.0;
  static const _fill = Color(0x404C7A75);
  static const _border = Color(0x801F3B2E);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.box(left: left, top: top, width: width, height: height, radius: 9, color: _fill, borderColor: _border),
        c.rect(
          left: left + 3.25,
          top: top,
          width: width,
          height: height,
          child: IgnorePointer(
            child: Center(
              child: FigmaSpacedText(
                StayText.inCity(city),
                style: c.style(12, 690, TripColors.green, lineHeight: null),
                letterSpacing: c.s.x(-0.408),
                width: c.s.x(width - 12),
                align: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
