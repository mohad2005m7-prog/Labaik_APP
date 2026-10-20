import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tawaf_page.dart';

// -------------------------------------------------------------
// حلقة الشوط (Figma "Group 36817…"): دائرة 286 بخط 15 — المسار #4C7A75 30% والتقدّم #1F3B2E
// التقدّم بيبدأ من فوق مع عقارب الساعة وبأطراف مدوّرة — طوله لكل شوط متل Figma ([sweeps])
// والرقم بالنص (يُرسم بالشاشة)
// -------------------------------------------------------------
class TawafRing extends StatelessWidget {
  final int round;
  final double stroke;

  const TawafRing({super.key, required this.round, required this.stroke});

  /// زاوية التقدّم (درجات) لكل شوط — مقاسة من إطارات Figma
  static const sweeps = [30.0, 50.0, 66.0, 165.0, 208.0, 270.0, 360.0];

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    // بالإنجليزي الشاشة معكوسة فالتقدّم بيمشي عكس عقارب الساعة (نفس اتجاه القراءة)
    return CustomPaint(painter: _RingPainter(sweep: sweeps[(round - 1).clamp(0, 6)], stroke: stroke, clockwise: rtl));
  }
}

class _RingPainter extends CustomPainter {
  final double sweep;
  final double stroke;
  final bool clockwise;

  const _RingPainter({required this.sweep, required this.stroke, required this.clockwise});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawOval(rect, paint..color = TawafColors.track);
    final radians = sweep * math.pi / 180 * (clockwise ? 1 : -1);
    canvas.drawArc(rect, -math.pi / 2, radians, false, paint
      ..color = TawafColors.green
      ..strokeCap = sweep >= 360 ? StrokeCap.butt : StrokeCap.round);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.sweep != sweep || old.stroke != stroke || old.clockwise != clockwise;
}
