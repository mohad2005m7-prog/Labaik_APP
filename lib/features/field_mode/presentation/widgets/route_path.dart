import 'package:flutter/material.dart';

import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import 'field_colors.dart';

// -------------------------------------------------------------
// المسار المنقّط بين "موقعك الحالي" والوجهة (كرت "وجهتك القادمة")
// 3 خطوط Figma (Line 9/10/11): سماكة 3 — dash 6/6 — #1F3B2E
// والسهم بأوله ("Hicon / Linear / Left 4" مدوّر 27.4°) صورة من Figma
// الخطوط مرسومة بنفس هندسة Figma: نقطة البداية والدوران والطول (relativeTransform)
// وFigma بيوزّع الـ dash على طول الخط: نص شرطة بالأول ونص بالآخر وبالنص شرطات كاملة.
// -------------------------------------------------------------
class RoutePath {
  static const _asset = 'assets/images/field_mode/ic_path_arrow.png';

  // منطقة الرسم بأرقام Figma
  static const _left = 115.0;
  static const _top = 390.0;
  static const _width = 200.0;
  static const _height = 50.0;

  /// [shift]: نفس المسار بمكان تاني (كرت نقطة التجمع 111:6735: (1، −14) وأسود) — [arrow]: مكان السهم وحجمه (null = بدون)
  static List<Widget> build(FigmaCanvas c, {Offset shift = Offset.zero, Color color = FieldColors.green, Rect? arrow = const Rect.fromLTWH(97, 376, 32.36, 32.36)}) {
    return [
      c.rect(
        left: _left + shift.dx,
        top: _top + shift.dy,
        width: _width,
        height: _height,
        child: Builder(
          builder: (context) => CustomPaint(painter: _DashedLinesPainter(c.s, color: color, mirror: Directionality.of(context) == TextDirection.ltr)),
        ),
      ),
      if (arrow != null) c.image(_asset, left: arrow.left, top: arrow.top, width: arrow.width, height: arrow.height, flipInLtr: true, color: color == FieldColors.green ? null : color),
    ];
  }
}

class _Line {
  final double x, y; // نقطة البداية
  final double cos, sin; // اتجاه الخط
  final double length;
  final int periods; // عدد مرات (شرطة + فراغ) على طول الخط

  const _Line(this.x, this.y, this.cos, this.sin, this.length, this.periods);
}

class _DashedLinesPainter extends CustomPainter {
  final DesignScale s;
  final Color color;
  final bool mirror;

  _DashedLinesPainter(this.s, {required this.color, required this.mirror});

  static const _lines = [
    _Line(121, 398, 0.9123587, 0.4093917, 85.4927, 7), // Line 9
    _Line(199, 434, 0.5079850, -0.8613659, 45.2769, 4), // Line 10
    _Line(218, 397, 0.9388763, 0.3442546, 95.8593, 8), // Line 11
  ];
  static const _stroke = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    Offset map(double fx, double fy) {
      final x = s.x(fx - RoutePath._left);
      return Offset(mirror ? size.width - x : x, s.y(fy - RoutePath._top));
    }

    for (final line in _lines) {
      // نقطة على الخط: t على طوله و n عمودي عليه (الشرطة من n=-3 لـ n=0 حسب Figma)
      Offset at(double t, double n) => map(line.x + t * line.cos - n * line.sin, line.y + t * line.sin + n * line.cos);

      void dash(double from, double to) {
        canvas.drawPath(
          Path()
            ..moveTo(at(from, -_stroke).dx, at(from, -_stroke).dy)
            ..lineTo(at(to, -_stroke).dx, at(to, -_stroke).dy)
            ..lineTo(at(to, 0).dx, at(to, 0).dy)
            ..lineTo(at(from, 0).dx, at(from, 0).dy)
            ..close(),
          paint,
        );
      }

      final d = line.length / (2 * line.periods);
      dash(0, d / 2);
      for (var k = 0; k < line.periods - 1; k++) {
        final start = d / 2 + d + 2 * d * k;
        dash(start, start + d);
      }
      dash(line.length - d / 2, line.length);
    }
  }

  @override
  bool shouldRepaint(_DashedLinesPainter old) => old.s.sx != s.sx || old.s.sy != s.sy || old.mirror != mirror || old.color != color;
}
