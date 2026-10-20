import 'package:flutter/material.dart';

// -------------------------------------------------------------
// أيقونة "مركز المساعدة" المختارة بشريط التنقل: دايرة #1F3B2E مليانة وجوّاها "i" بيضا
// -------------------------------------------------------------
class InfoFilledIcon extends StatelessWidget {
  final double size;
  final Color color;

  const InfoFilledIcon({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _InfoPainter(color));
}

class _InfoPainter extends CustomPainter {
  final Color color;

  _InfoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 20;
    final center = size.center(Offset.zero);
    canvas.drawCircle(center, 10 * k, Paint()..color = color);
    final white = Paint()..color = Colors.white;
    // النقطة فوق والخط تحتها
    canvas.drawCircle(center.translate(0, -4.6 * k), 1.35 * k, white);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center.translate(0, 1.9 * k), width: 2.3 * k, height: 7.4 * k), Radius.circular(1.15 * k)), white);
  }

  @override
  bool shouldRepaint(_InfoPainter old) => old.color != color;
}
