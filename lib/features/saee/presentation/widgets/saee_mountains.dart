import 'package:flutter/material.dart';

// -------------------------------------------------------------
// رسم جبل الصفا أو جبل المروة (CustomPainter) — Figma (SVG مُصدَّر 120×120)
// كلا الجبلين بنفس لون TawafColors.green (#1F3B2E) — silhouette مملوءة
// -------------------------------------------------------------
class SaeeMountainPainter extends CustomPainter {
  final bool isSafa;
  final Color color;

  const SaeeMountainPainter({required this.isSafa, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.017
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final path = Path();

    if (isSafa) {
      // الصفا: قمة واحدة بارزة يمنة وسطح خشن
      path
        ..moveTo(0, h)
        ..lineTo(w * 0.04, h * 0.82)
        ..lineTo(w * 0.12, h * 0.88)
        ..lineTo(w * 0.20, h * 0.70)
        ..lineTo(w * 0.28, h * 0.76)
        ..lineTo(w * 0.36, h * 0.54)
        ..lineTo(w * 0.45, h * 0.38)
        ..lineTo(w * 0.52, h * 0.10) // قمة رئيسية
        ..lineTo(w * 0.60, h * 0.32)
        ..lineTo(w * 0.68, h * 0.18) // قمة ثانوية صغيرة
        ..lineTo(w * 0.76, h * 0.44)
        ..lineTo(w * 0.84, h * 0.58)
        ..lineTo(w * 0.92, h * 0.68)
        ..lineTo(w, h * 0.78)
        ..lineTo(w, h)
        ..close();
    } else {
      // المروة: قمتان واضحتان بشكل مختلف
      path
        ..moveTo(0, h)
        ..lineTo(w * 0.04, h * 0.72)
        ..lineTo(w * 0.14, h * 0.55)
        ..lineTo(w * 0.22, h * 0.14) // قمة أولى
        ..lineTo(w * 0.30, h * 0.40)
        ..lineTo(w * 0.38, h * 0.50)
        ..lineTo(w * 0.46, h * 0.28) // قمة ثانية
        ..lineTo(w * 0.54, h * 0.44)
        ..lineTo(w * 0.62, h * 0.56)
        ..lineTo(w * 0.72, h * 0.62)
        ..lineTo(w * 0.82, h * 0.70)
        ..lineTo(w * 0.92, h * 0.78)
        ..lineTo(w, h * 0.84)
        ..lineTo(w, h)
        ..close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SaeeMountainPainter old) => old.isSafa != isSafa || old.color != color;
}
