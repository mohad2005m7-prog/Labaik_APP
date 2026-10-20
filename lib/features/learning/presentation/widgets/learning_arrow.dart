import 'package:flutter/material.dart';

/// السهم "→" قبل نص الزر الذهبي ("ماذا لو انتقض وضوئي…؟") — خط أبيض ورأسه لليمين (مقاس من Figma 9.5×3.5)
class LearningArrow extends StatelessWidget {
  const LearningArrow({super.key});

  @override
  Widget build(BuildContext context) => const CustomPaint(painter: _ArrowPainter());
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.height * 0.36;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final mid = size.height / 2;
    final head = size.height / 2 - stroke / 2;
    canvas.drawLine(Offset(stroke / 2, mid), Offset(size.width - stroke / 2, mid), paint);
    canvas.drawPath(
      Path()
        ..moveTo(size.width - stroke / 2 - head, mid - head)
        ..lineTo(size.width - stroke / 2, mid)
        ..lineTo(size.width - stroke / 2 - head, mid + head),
      paint..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => false;
}
