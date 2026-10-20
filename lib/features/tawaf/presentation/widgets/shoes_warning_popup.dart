import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_lines.dart';
import '../../../../core/widgets/top_popup.dart';
import '../l10n/tawaf_steps_text.dart';
import 'tawaf_page.dart';

// -------------------------------------------------------------
// "تنبيه قبل المتابعة" (Figma 302:13279 — 360×108 #FFFCE8 radius 16 بحد رفيع غامق)
// ⚠️ ذهبي (#A59063) + العنوان (Bold 16) + سطرين (16) كلهم #1F3B2E — أوزانهم مقاسة بعرض سطور Figma — بتسكّر لحالها بعد ثانيتين (البروتوتايب)
// -------------------------------------------------------------
class ShoesWarningPopup extends StatelessWidget {
  const ShoesWarningPopup({super.key});

  static const height = 108.0;
  // الكرت 360 بنص الشاشة (393)
  static const _x = 16.5;

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    final c = FigmaCanvas(s, originTop: 0);
    return TopPopup(
      height: height,
      child: Stack(
        children: [
          c.box(left: _x, top: 0, width: 360, height: height, color: TawafColors.warningFill, radius: 16, borderColor: TawafColors.warningBorder),
          c.rect(left: _x + 318.5, top: 15.5, width: 25, height: 19.5, child: const IgnorePointer(child: CustomPaint(painter: _WarningPainter()))),
          FigmaLines.build(c, TawafStepsText.shoesTitle(), left: _x + 20, top: 14.25, width: 292, wrap: false, style: c.style(16, 640, TawafColors.green)),
          FigmaLines.build(c, TawafStepsText.shoesBody(), left: _x + 14, top: 42.25, width: 329, maxHeight: 60, style: c.style(16, FigmaWeight.sfLight, TawafColors.green)),
        ],
      ),
    );
  }
}

/// مثلث التنبيه (خط ذهبي بزوايا مدوّرة) وبنصه "!"
class _WarningPainter extends CustomPainter {
  const _WarningPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final stroke = w * 0.055;
    final paint = Paint()
      ..color = TawafColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final inset = stroke / 2 + 0.5;
    canvas.drawPath(
      Path()
        ..moveTo(w / 2, inset)
        ..lineTo(w - inset, h - inset)
        ..lineTo(inset, h - inset)
        ..close(),
      paint,
    );
    canvas.drawLine(Offset(w / 2, h * 0.38), Offset(w / 2, h * 0.64), paint);
    canvas.drawCircle(Offset(w / 2, h * 0.79), stroke * 0.7, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_WarningPainter old) => false;
}
