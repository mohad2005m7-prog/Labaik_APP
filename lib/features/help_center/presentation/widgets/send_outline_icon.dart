import 'package:flutter/material.dart';

// -------------------------------------------------------------
// طيارة الإرسال بخط (زر المحادثة — دايرة #1F3B2E 43.98): رأسها لفوق اليمين وفيها شق لنصها
// حبرها ~15×15 (مقاس من لقطة Figma — ما في رسمة الـ vector بالملف المحفوظ)
// -------------------------------------------------------------
class SendOutlineIcon extends StatelessWidget {
  final double size;
  final Color color;

  const SendOutlineIcon({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _SendOutlinePainter(color));
}

class _SendOutlinePainter extends CustomPainter {
  final Color color;

  _SendOutlinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 16;
    Offset p(double x, double y) => Offset(x * k, y * k);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * k
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    // الرأس (فوق يمين) → الجناح الشمال → الشق بالنص → الجناح التحتاني → الرأس
    final tip = p(15.2, 0.8), left = p(0.8, 6.3), notch = p(6.6, 9.4), bottom = p(9.7, 15.2);
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(left.dx, left.dy)
        ..lineTo(notch.dx, notch.dy)
        ..lineTo(bottom.dx, bottom.dy)
        ..close(),
      paint,
    );
    canvas.drawLine(notch, p(10.4, 5.6), paint);
  }

  @override
  bool shouldRepaint(_SendOutlinePainter old) => old.color != color;
}
