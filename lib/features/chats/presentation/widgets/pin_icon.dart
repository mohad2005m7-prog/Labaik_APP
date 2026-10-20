import 'package:flutter/material.dart';

// -------------------------------------------------------------
// دبوس المحادثة المثبّتة (📌 أسود بقائمة المحادثات — حبره 11×22): غطا عريض، جسم، قاعدة عريضة، وإبرة
// الشكل مقاس من لقطة Figma مكبّرة
// -------------------------------------------------------------
class PinIcon extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const PinIcon({super.key, required this.width, required this.height, this.color = Colors.black});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(width, height), painter: _PinPainter(color));
}

class _PinPainter extends CustomPainter {
  final Color color;

  _PinPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final kx = size.width / 11, ky = size.height / 22;
    Offset p(double x, double y) => Offset(x * kx, y * ky);
    final paint = Paint()..color = color;
    final head = Path()
      ..moveTo(p(1.6, 0).dx, 0)
      ..lineTo(p(9.4, 0).dx, 0)
      ..lineTo(p(9.4, 1.7).dx, p(9.4, 1.7).dy)
      ..lineTo(p(8.0, 1.7).dx, p(8.0, 1.7).dy)
      ..lineTo(p(8.0, 8.4).dx, p(8.0, 8.4).dy)
      ..lineTo(p(10.8, 11.0).dx, p(10.8, 11.0).dy)
      ..lineTo(p(10.8, 12.3).dx, p(10.8, 12.3).dy)
      ..lineTo(p(0.2, 12.3).dx, p(0.2, 12.3).dy)
      ..lineTo(p(0.2, 11.0).dx, p(0.2, 11.0).dy)
      ..lineTo(p(3.0, 8.4).dx, p(3.0, 8.4).dy)
      ..lineTo(p(3.0, 1.7).dx, p(3.0, 1.7).dy)
      ..lineTo(p(1.6, 1.7).dx, p(1.6, 1.7).dy)
      ..close();
    canvas.drawPath(head, paint);
    // الإبرة
    canvas.drawRect(Rect.fromLTRB(p(4.85, 0).dx, p(0, 12.3).dy, p(6.15, 0).dx, size.height), paint);
  }

  @override
  bool shouldRepaint(_PinPainter old) => old.color != color;
}
