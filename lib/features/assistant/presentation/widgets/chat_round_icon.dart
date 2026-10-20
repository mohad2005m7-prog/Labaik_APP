import 'package:flutter/material.dart';

// -------------------------------------------------------------
// أيقونة السؤال المقترح ("Hicon" massge=False — 24×24): فقاعة محادثة دائرية بذيل تحت يسار
// خط 1.5 — الشكل مطابق لرندر Figma (مقاس بشبكة على لقطة الإطار)
// -------------------------------------------------------------
class ChatRoundIcon extends StatelessWidget {
  final double size;
  final Color color;

  const ChatRoundIcon({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _ChatRoundPainter(color));
}

class _ChatRoundPainter extends CustomPainter {
  final Color color;

  _ChatRoundPainter(this.color);

  // أرقام الأيقونة على شبكة 24×24
  static final _path = Path()
    ..moveTo(12, 22)
    ..cubicTo(17.5228, 22, 22, 17.5228, 22, 12)
    ..cubicTo(22, 6.47715, 17.5228, 2, 12, 2)
    ..cubicTo(6.47715, 2, 2, 6.47715, 2, 12)
    ..cubicTo(2, 13.5997, 2.37562, 15.1116, 3.04346, 16.4525)
    ..cubicTo(3.22094, 16.8088, 3.28001, 17.2161, 3.17712, 17.6006)
    ..lineTo(2.58151, 19.8267)
    ..cubicTo(2.32295, 20.793, 3.20701, 21.677, 4.17335, 21.4185)
    ..lineTo(6.39939, 20.8229)
    ..cubicTo(6.78393, 20.72, 7.19121, 20.7791, 7.54753, 20.9565)
    ..cubicTo(8.88837, 21.6244, 10.4003, 22, 12, 22)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.scale(k);
    canvas.drawPath(
      _path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ChatRoundPainter old) => old.color != color;
}
