import 'package:flutter/material.dart';

// -------------------------------------------------------------
// ميكروفون iOS بخط رمادي (خانة الكتابة بالمحادثة — حبره 11.5×17.5): كبسولة + قوس + ساق + قاعدة
// -------------------------------------------------------------
class MicIcon extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const MicIcon({super.key, required this.width, required this.height, required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(width, height), painter: _MicPainter(color));
}

class _MicPainter extends CustomPainter {
  final Color color;

  _MicPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final kx = size.width / 11.5, ky = size.height / 17.5;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * kx
      ..strokeCap = StrokeCap.round;
    // الكبسولة
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(3.15 * kx, 0.6 * ky, 8.35 * kx, 10.8 * ky), Radius.circular(2.6 * kx)), paint);
    // القوس تحتها
    canvas.drawArc(Rect.fromLTRB(0.6 * kx, 2.4 * ky, 10.9 * kx, 13.4 * ky), 0, 3.14159, false, paint);
    // الساق والقاعدة
    canvas.drawLine(Offset(5.75 * kx, 13.4 * ky), Offset(5.75 * kx, 16.8 * ky), paint);
    canvas.drawLine(Offset(2.8 * kx, 16.8 * ky), Offset(8.7 * kx, 16.8 * ky), paint);
  }

  @override
  bool shouldRepaint(_MicPainter old) => old.color != color;
}
