import 'package:flutter/material.dart';

// -------------------------------------------------------------
// سهم القائمة "⌄" ("Hicon / Linear / Down" بحقل البحث): خطه 9.7×5 بسماكة 1.5 → حبره ~11×6.5 (مقاس من رندر Figma)
// -------------------------------------------------------------
class ChevronDownIcon extends StatelessWidget {
  final double width;
  final double height;
  final double stroke;
  final Color color;

  const ChevronDownIcon({super.key, required this.width, required this.height, required this.stroke, required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(width, height), painter: _ChevronDownPainter(stroke, color));
}

class _ChevronDownPainter extends CustomPainter {
  final double stroke;
  final Color color;

  _ChevronDownPainter(this.stroke, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(Path()..moveTo(0, 0)..lineTo(size.width / 2, size.height)..lineTo(size.width, 0), p);
  }

  @override
  bool shouldRepaint(_ChevronDownPainter old) => old.stroke != stroke || old.color != color;
}
