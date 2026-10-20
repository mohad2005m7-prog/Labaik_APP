import 'package:flutter/material.dart';

// -------------------------------------------------------------
// سهم Figma بخط (chevron) — [width]×[height] = صندوق خط السهم (مركز الخط) ورأسه بنص الطول
// [pointsToEnd]: بيأشّر لنهاية السطر ("<" بالعربي و">" بالإنجليزي — "Icon / chevron.left" بالكروت)
// وإلا لبدايته (">" بالعربي = سهم الرجوع)
// -------------------------------------------------------------
class FigmaChevron extends StatelessWidget {
  final double width;
  final double height;
  final double stroke;
  final Color color;
  final bool pointsToEnd;

  const FigmaChevron({super.key, required this.width, required this.height, required this.stroke, required this.color, this.pointsToEnd = false});

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Transform.flip(
      flipX: pointsToEnd == rtl,
      child: CustomPaint(size: Size(width, height), painter: _ChevronPainter(stroke, color)),
    );
  }
}

/// ">" بخط بأطراف مدوّرة
class _ChevronPainter extends CustomPainter {
  final double stroke;
  final Color color;

  _ChevronPainter(this.stroke, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(Path()..moveTo(0, 0)..lineTo(size.width, size.height / 2)..lineTo(0, size.height), p);
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => old.stroke != stroke || old.color != color;
}
