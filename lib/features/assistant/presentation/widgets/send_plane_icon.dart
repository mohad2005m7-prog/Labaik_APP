import 'package:flutter/material.dart';

// -------------------------------------------------------------
// طيارة الإرسال (Figma "Vector" 16.5×16.5 أبيض، مدوّرة 36° — صندوقها بعد التدوير 23.05×23.05):
// مثلث رأسه لقدّام وجناحين لورا، وبينهم شق لنص الطيارة
// الشكل مقاس بشبكة على لقطة الإطار (ما في رسمة الـ vector نفسها بملف Figma المحفوظ)
// -------------------------------------------------------------
class SendPlaneIcon extends StatelessWidget {
  /// عرض/طول الصندوق بعد التدوير (23.05 بـ Figma، بعد التحجيم)
  final double size;
  final Color color;

  const SendPlaneIcon({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _SendPlanePainter(color));
}

class _SendPlanePainter extends CustomPainter {
  final Color color;

  _SendPlanePainter(this.color);

  static const _side = 16.5;
  static const _rotation = -0.6305997903168046; // Figma (عكس عقارب الساعة)
  static const _box = 23.054206240741223;

  // الطيارة قبل التدوير (رأسها لليمين) على صندوق 16.5×16.5
  static final _path = Path()
    ..moveTo(0.4, 0.2)
    ..lineTo(16.5, 8.25)
    ..lineTo(0.4, 16.3)
    ..lineTo(2.0, 9.1)
    ..lineTo(8.2, 8.25)
    ..lineTo(2.0, 7.4)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / _box;
    canvas
      ..translate(size.width / 2, size.height / 2)
      ..scale(k)
      ..rotate(_rotation)
      ..translate(-_side / 2, -_side / 2);
    canvas.drawPath(_path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SendPlanePainter old) => old.color != color;
}
