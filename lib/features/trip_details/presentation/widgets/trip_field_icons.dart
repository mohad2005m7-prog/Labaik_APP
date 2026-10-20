import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'trip_colors.dart';

// -------------------------------------------------------------
// أيقونتي حقلي التاريخ والوقت (Figma "Group" 22.5×22.5 و "svgexport-7" 24×24 — #1F3B2E)
// مرسومين vector من رندر Figma المكبّر (شاشة "متى ستنطلق في رحلتك إلى مكة؟")
// -------------------------------------------------------------
class TripCalendarIcon extends StatelessWidget {
  final double size;

  const TripCalendarIcon({super.key, required this.size});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _CalendarPainter());
}

class TripClockIcon extends StatelessWidget {
  final double size;

  const TripClockIcon({super.key, required this.size});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _ClockPainter());
}

Paint _line(double width) => Paint()
  ..color = TripColors.green
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

/// تقويم بحلقات فوق وشبكة أيام وشارة ✓ تحت يمين (على مربع 22.5)
class _CalendarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 22.5);
    final line = _line(1.3);
    // جسم التقويم — زاويته تحت يمين مقطوعة للشارة
    canvas.drawPath(
      Path()
        ..moveTo(13.2, 21.2)
        ..lineTo(3.0, 21.2)
        ..arcToPoint(const Offset(1.2, 19.4), radius: const Radius.circular(1.8))
        ..lineTo(1.2, 5.1)
        ..arcToPoint(const Offset(3.0, 3.3), radius: const Radius.circular(1.8))
        ..lineTo(19.5, 3.3)
        ..arcToPoint(const Offset(21.3, 5.1), radius: const Radius.circular(1.8))
        ..lineTo(21.3, 13.6),
      line,
    );
    canvas.drawLine(const Offset(1.2, 7.6), const Offset(21.3, 7.6), _line(1.2));
    // الحلقات
    for (final x in [5.75, 12.0, 17.95]) {
      final ring = RRect.fromRectXY(Rect.fromCenter(center: Offset(x, 3.1), width: 1.9, height: 4.4), 0.95, 0.95);
      canvas
        ..drawRRect(ring, Paint()..color = Colors.white)
        ..drawRRect(ring, _line(0.9));
    }
    // مربعات الأيام (الأخير بالسطر التاني والتالت تحت الشارة)
    const columns = [4.95, 9.5, 14.0, 18.55];
    const rows = [(11.05, 4), (14.5, 3), (17.75, 2)];
    for (final (y, count) in rows) {
      for (final x in columns.take(count)) {
        canvas.drawRRect(RRect.fromRectXY(Rect.fromCenter(center: Offset(x, y), width: 2.2, height: 1.8), 0.6, 0.6), _line(0.8));
      }
    }
    // الشارة
    const badge = Offset(18.55, 17.95);
    canvas
      ..drawCircle(badge, 4.6, Paint()..color = Colors.white)
      ..drawCircle(badge, 3.8, _line(1.2))
      ..drawPath(
        Path()
          ..moveTo(16.55, 18.0)
          ..lineTo(17.75, 19.3)
          ..lineTo(20.45, 16.6),
        _line(1.1),
      );
  }

  @override
  bool shouldRepaint(_CalendarPainter old) => false;
}

/// ساعة: دائرة، 4 شَرطات و4 نقط، وعقربين (على مربع 24)
class _ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    const c = Offset(12, 12);
    canvas.drawCircle(c, 10.9, _line(1.6));
    final mark = _line(1.4);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final dir = Offset(math.sin(a), -math.cos(a));
      if (i.isEven) {
        canvas.drawLine(c + dir * 6.5, c + dir * 7.9, mark);
      } else {
        canvas.drawCircle(c + dir * 8.0, 0.75, Paint()..color = TripColors.green);
      }
    }
    canvas.drawPath(
      Path()
        ..moveTo(12, 7.6)
        ..lineTo(12, 12)
        ..lineTo(16.6, 16.9),
      _line(1.6),
    );
  }

  @override
  bool shouldRepaint(_ClockPainter old) => false;
}
