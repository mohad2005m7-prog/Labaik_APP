import 'dart:math' as math;

import 'package:flutter/material.dart';

// -------------------------------------------------------------
// أيقونات شاشات الدخول وإنشاء الحساب (Outline بخط 1 — زي Figma) مرسومة كـ vector
// فبتطلع حادة بأي دقة شاشة. الأرقام بمربع 24×24 (أرقام Figma).
// -------------------------------------------------------------
enum AuthIcon { mail, call, lock, eye, eyeOff, pilgrim, supervisor, company }

class AuthIconView extends StatelessWidget {
  final AuthIcon icon;
  final double size;
  final Color color;

  const AuthIconView(this.icon, {super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _AuthIconPainter(icon, color));
  }
}

class _AuthIconPainter extends CustomPainter {
  final AuthIcon icon;
  final Color color;

  _AuthIconPainter(this.icon, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;

    switch (icon) {
      case AuthIcon.mail:
        // مربع بزوايا حادة وجواه "V"
        canvas.drawRect(const Rect.fromLTRB(1.0, 1.5, 23.0, 21.5), p..strokeJoin = StrokeJoin.miter);
        canvas.drawPath(Path()..moveTo(5.5, 7.6)..lineTo(12.0, 12.8)..lineTo(18.5, 7.6), p..strokeJoin = StrokeJoin.round);
      case AuthIcon.call:
        // سماعة الهاتف مع موجتين
        canvas
          ..save()
          ..translate(12, 11.5)
          ..scale(1.1, 1.075)
          ..translate(-12, -12.25);
        canvas.drawPath(
          Path()
            ..moveTo(6.6, 2.6)
            ..cubicTo(5.6, 2.2, 3.1, 4.2, 2.9, 5.6)
            ..cubicTo(2.4, 9.6, 6.6, 15.6, 10.6, 18.6)
            ..cubicTo(13.6, 20.9, 17.6, 22.6, 19.4, 21.2)
            ..cubicTo(20.4, 20.4, 21.5, 19.2, 21.0, 18.4)
            ..cubicTo(20.3, 17.3, 18.4, 15.8, 17.3, 15.4)
            ..cubicTo(16.2, 15.0, 15.4, 16.6, 14.6, 17.1)
            ..cubicTo(13.4, 17.8, 9.8, 14.6, 8.9, 13.4)
            ..cubicTo(8.1, 12.4, 6.8, 10.6, 7.6, 9.6)
            ..cubicTo(8.2, 8.8, 9.6, 8.2, 9.2, 7.0)
            ..cubicTo(8.8, 5.8, 7.6, 3.1, 6.6, 2.6)
            ..close(),
          p,
        );
        canvas.drawArc(Rect.fromCircle(center: const Offset(13.2, 10.8), radius: 4.6), -1.45, 1.35, false, p);
        canvas.drawArc(Rect.fromCircle(center: const Offset(13.2, 10.8), radius: 8.3), -1.45, 1.4, false, p);
        canvas.restore();
      case AuthIcon.lock:
        // القفل: جسم مستطيل + قوس + خط المفتاح
        canvas.drawRect(const Rect.fromLTRB(3.0, 8.9, 20.5, 21.3), p..strokeJoin = StrokeJoin.miter);
        canvas.drawPath(Path()..moveTo(6.6, 8.9)..lineTo(6.6, 6.6)..arcToPoint(const Offset(16.9, 6.6), radius: const Radius.circular(5.15))..lineTo(16.9, 8.9), p);
        canvas.drawLine(const Offset(11.75, 13.6), const Offset(11.75, 16.2), p);
      case AuthIcon.eye:
      case AuthIcon.eyeOff:
        // العين (إظهار كلمة المرور) — مشطوبة لما تكون ظاهرة
        canvas.drawPath(
          Path()
            ..moveTo(1.9, 12)
            ..cubicTo(5.2, 5.6, 8.6, 3.2, 12, 3.2)
            ..cubicTo(15.4, 3.2, 18.8, 5.6, 22.1, 12)
            ..cubicTo(18.8, 18.4, 15.4, 20.8, 12, 20.8)
            ..cubicTo(8.6, 20.8, 5.2, 18.4, 1.9, 12)
            ..close(),
          p,
        );
        canvas.drawCircle(const Offset(12, 12), 3, p);
        if (icon == AuthIcon.eyeOff) canvas.drawLine(const Offset(4, 20), const Offset(20, 4), p);
      case AuthIcon.pilgrim:
      case AuthIcon.supervisor:
      case AuthIcon.company:
        // أيقونات "نوع الحساب" مرسومة بمربعها كامل (40×40 بـ Figma) — فبنرجع لوحدات 40
        canvas.scale(24 / 40);
        p.strokeWidth = 1.2;
        _accountType(canvas, p, fill);
    }
  }

  // الأرقام بمربع الأيقونة 40×40 (من رسمة Figma)
  void _accountType(Canvas canvas, Paint p, Paint fill) {
    switch (icon) {
      case AuthIcon.pilgrim:
        // معتمر/حاج: الراس + الجسم بالإحرام (الشريط على الكتف)
        canvas.drawCircle(const Offset(19.8, 14.8), 5.2, p);
        canvas.drawRRect(
          RRect.fromLTRBAndCorners(8.4, 23.6, 31.2, 30.9, topLeft: const Radius.circular(3.5), topRight: const Radius.circular(3.5)),
          p..strokeJoin = StrokeJoin.miter,
        );
        canvas.drawLine(const Offset(24.4, 24.0), const Offset(20.1, 30.6), p);
        canvas.drawLine(const Offset(26.6, 24.2), const Offset(26.6, 30.6), p);
        canvas.drawLine(const Offset(11.8, 27.2), const Offset(11.8, 30.6), p);
        canvas.drawCircle(const Offset(15.7, 27.8), 0.7, fill);
      case AuthIcon.supervisor:
        // مشرف المجموعة: شخص (شعره ظاهر) قدام لابتوب ومسنّن جنبه
        canvas.drawCircle(const Offset(22.5, 12.8), 4.3, p);
        canvas.drawPath(Path()..moveTo(18.4, 11.6)..cubicTo(19.6, 9.6, 23.6, 8.4, 26.7, 11.2), p);
        canvas.drawPath(Path()..moveTo(15.0, 24.2)..cubicTo(15.4, 19.6, 18.2, 17.8, 22.4, 17.8)..cubicTo(26.6, 17.8, 29.2, 19.6, 29.6, 24.2), p);
        canvas.drawRect(const Rect.fromLTRB(15.0, 24.2, 28.0, 30.6), p..strokeJoin = StrokeJoin.miter);
        canvas.drawLine(const Offset(13.8, 31.8), const Offset(29.2, 31.8), p);
        canvas.drawCircle(const Offset(21.5, 27.4), 0.7, fill);
        _gear(canvas, p, const Offset(11.8, 22.0), 3.1);
      case AuthIcon.company:
        // الشركة: برج بنوافذ مايلة + مبنى صغير بنافذتين + قاعدة
        canvas.drawPath(Path()..moveTo(10.6, 28.2)..lineTo(10.6, 11.2)..lineTo(14.8, 9.4)..lineTo(24.6, 12.6)..lineTo(24.6, 28.2), p..strokeJoin = StrokeJoin.miter);
        canvas.drawLine(const Offset(14.8, 9.4), const Offset(14.8, 7.4), p);
        for (var i = 0; i < 6; i++) {
          final y = 14.6 + i * 2.2;
          canvas.drawLine(Offset(12.8, y + 1.0), Offset(20.6, y - 0.6), p);
        }
        canvas.drawRect(const Rect.fromLTRB(21.4, 17.8, 29.0, 28.2), p..strokeJoin = StrokeJoin.miter);
        canvas.drawRect(const Rect.fromLTRB(23.2, 19.8, 27.2, 22.2), p);
        canvas.drawRect(const Rect.fromLTRB(23.2, 23.4, 27.2, 25.8), p);
        canvas.drawRRect(RRect.fromLTRBR(7.9, 28.2, 32.0, 30.8, const Radius.circular(0.8)), p);
        canvas.drawRect(const Rect.fromLTRB(14.2, 24.4, 17.4, 28.2), p);
      default:
        break;
    }
  }

  // مسنّن صغير: 8 أسنان حول دايرتين
  void _gear(Canvas canvas, Paint p, Offset c, double r) {
    final teeth = Path();
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      teeth
        ..moveTo(c.dx + r * math.cos(a), c.dy + r * math.sin(a))
        ..lineTo(c.dx + r * 1.35 * math.cos(a), c.dy + r * 1.35 * math.sin(a));
    }
    canvas.drawPath(teeth, p);
    canvas.drawCircle(c, r, p);
    canvas.drawCircle(c, r * 0.42, p);
  }

  @override
  bool shouldRepaint(_AuthIconPainter old) => old.icon != icon || old.color != color;
}
