import 'package:flutter/material.dart';

import 'trip_colors.dart';

// -------------------------------------------------------------
// علامات الاختيار بشاشات التعديل (مقاسة من رندر Figma — 20×20):
// [TripRadio] دائرة بحد #1F3B2E 2 — المختارة معبّاية #4C7A75 وفيها ✓ بيضا، والباقي #4C7A75 10%
// [TripCheckbox] مربع بحد #1F3B2E 2 — المختار معبّى #4C7A75 وفيه ✓ بيضا، والباقي أبيض
// -------------------------------------------------------------
class TripRadio extends StatelessWidget {
  final double size;
  final bool checked;

  const TripRadio({super.key, required this.size, required this.checked});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _MarkPainter(checked: checked, round: true));
}

class TripCheckbox extends StatelessWidget {
  final double size;
  final bool checked;

  const TripCheckbox({super.key, required this.size, required this.checked});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _MarkPainter(checked: checked, round: false));
}

class _MarkPainter extends CustomPainter {
  final bool checked;
  final bool round;

  _MarkPainter({required this.checked, required this.round});

  static const _radioIdle = Color(0x1A4C7A75);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 20;
    canvas.scale(k);
    // الحد جوّا الـ 20×20
    final shape = round ? (Path()..addOval(const Rect.fromLTWH(1, 1, 18, 18))) : (Path()..addRRect(RRect.fromRectXY(const Rect.fromLTWH(1, 1, 18, 18), 1.5, 1.5)));
    final fill = checked ? TripColors.teal : (round ? _radioIdle : Colors.white);
    canvas
      ..drawPath(shape, Paint()..color = fill)
      ..drawPath(shape, Paint()
        ..color = TripColors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
    if (!checked) return;
    canvas.drawPath(
      Path()
        ..moveTo(5.4, 10.4)
        ..lineTo(8.9, 13.9)
        ..lineTo(15.2, 6.3),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.checked != checked || old.round != round;
}
