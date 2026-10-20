import 'package:flutter/material.dart';

// -------------------------------------------------------------
// السهم بأول المسار المنقّط بكرت نقطة التجمع (Figma "image 5" — شيفرون مدوّر لفوق يسار):
// زاوية عند (0.5، 1.5) وذراعين ~16 بخط 3 — مقاس من لقطة Figma (الصندوق 15×17)
// -------------------------------------------------------------
class GroupPathArrow extends StatelessWidget {
  final double width;
  final Color color;

  const GroupPathArrow({super.key, required this.width, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    final mirror = Directionality.of(context) == TextDirection.ltr;
    return Transform.flip(flipX: mirror, child: CustomPaint(size: Size(width, width * 17 / 15), painter: _ArrowPainter(color)));
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;

  _ArrowPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 15;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(14 * k, 1 * k)
        ..lineTo(1.5 * k, 2.5 * k)
        ..lineTo(2.5 * k, 15.5 * k),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.color != color;
}
