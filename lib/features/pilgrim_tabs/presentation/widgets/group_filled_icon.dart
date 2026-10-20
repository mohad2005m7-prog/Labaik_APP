import 'package:flutter/material.dart';

// -------------------------------------------------------------
// أيقونة "الأفراد" المختارة بشريط التنقل (Figma — مقاسة من لقطته المكبّرة): 3 أشخاص مليانين #1F3B2E
// الأوسط أكبر، وكل جسم تحت راسه — الصندوق 24.1×14.3 (حبر Figma 24×13.5)
// -------------------------------------------------------------
class GroupFilledIcon extends StatelessWidget {
  final double width;
  final Color color;

  const GroupFilledIcon({super.key, required this.width, required this.color});

  static const aspect = 14.3 / 24.1;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(width, width * aspect), painter: _GroupPainter(color));
}

class _GroupPainter extends CustomPainter {
  final Color color;

  _GroupPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24.1;
    final fill = Paint()..color = color;
    final edge = Paint()
      ..color = Color.lerp(color, Colors.black, 0.45)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5 * k;
    void draw(Path path) => canvas
      ..drawPath(path, fill)
      ..drawPath(path, edge);

    Path head(double x, double y, double r) => Path()..addOval(Rect.fromCircle(center: Offset(x * k, y * k), radius: r * k));
    draw(head(3.8, 3.1, 3.0));
    draw(head(12.05, 3.8, 3.8));
    draw(head(20.3, 3.1, 3.0));

    // الجسم الأوسط: قبة عريضة بقاعدة مستوية
    draw(Path()..addRRect(RRect.fromLTRBAndCorners(6.4 * k, 9.3 * k, 17.7 * k, 14.3 * k, topLeft: Radius.elliptical(4.6 * k, 4 * k), topRight: Radius.elliptical(4.6 * k, 4 * k))));

    // الجسمين الجانبيين: ضلع مايل لجهة النص (الأيمن مقلوب الأيسر)
    Path side(bool mirror) {
      double x(double v) => (mirror ? 24.1 - v : v) * k;
      double y(double v) => v * k;
      return Path()
        ..moveTo(x(0), y(8.6))
        ..quadraticBezierTo(x(0), y(7.05), x(1.6), y(7.05))
        ..lineTo(x(7.3), y(7.05))
        ..lineTo(x(5.1), y(12.6))
        ..quadraticBezierTo(x(4.7), y(13.7), x(3.5), y(13.7))
        ..lineTo(x(1.5), y(13.7))
        ..quadraticBezierTo(x(0), y(13.7), x(0), y(12.2))
        ..close();
    }

    draw(side(false));
    draw(side(true));
  }

  @override
  bool shouldRepaint(_GroupPainter old) => old.color != color;
}
