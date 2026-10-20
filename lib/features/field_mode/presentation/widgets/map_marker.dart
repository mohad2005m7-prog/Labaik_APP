import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';

/// علامة على Google Maps مع النقطة اللي بتنزل على الإحداثيات (رأس الدبوس)
typedef MapMarkerIcon = ({BitmapDescriptor icon, Offset anchor});

// -------------------------------------------------------------
// علامات الخريطة:
// دبوس الوجهة زي Figma (svgexport-22 بإطار 28×28):
//   الدبوس #E74C3C من (5.5, 1.8) بحجم 16.9×24.4 — ودائرة #EFE8D8 قطرها 8 من (10, 6)
//   واسم المكان تحته (Poppins 600 14 أسود)
// ونقطة موقع المستخدم الفعلي (أزرق بحد أبيض) للخريطة البديلة
// -------------------------------------------------------------
class MapMarker {
  static const pinSize = 28.0;
  static const tipY = 26.2; // رأس الدبوس من فوق الإطار
  static const labelHeight = 22.0; // سطر الاسم (line height 22)
  static const _pinColor = Color(0xFFE74C3C);
  static const _dotColor = Color(0xFFEFE8D8);

  static const userDotSize = 18.0;
  static const _userColor = Color(0xFF4285F4);

  /// شكل الدبوس (location pin) بأرقام Figma داخل إطار 28×28 مضروبة بـ [k]
  static void paintPin(Canvas canvas, Offset origin, double k) {
    // الشكل بإحداثيات أيقونة 24×24 (العرض من 5 لـ 19 والطول من 2 لـ 22) → مستطيل الدبوس بـ Figma
    const left = 5.5, top = 1.8, width = 16.9, height = 24.4;
    Offset p(double x, double y) => origin + Offset((left + (x - 5) * width / 14) * k, (top + (y - 2) * height / 20) * k);

    final a = p(12, 2), b1 = p(8.13, 2), b2 = p(5, 5.13), b = p(5, 9);
    final c1 = p(5, 14.25), c = p(12, 22), d2 = p(19, 14.25), d = p(19, 9);
    final e1 = p(19, 5.13), e2 = p(15.87, 2);
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(b1.dx, b1.dy, b2.dx, b2.dy, b.dx, b.dy)
      ..cubicTo(c1.dx, c1.dy, c.dx, c.dy, c.dx, c.dy)
      ..cubicTo(c.dx, c.dy, d2.dx, d2.dy, d.dx, d.dy)
      ..cubicTo(e1.dx, e1.dy, e2.dx, e2.dy, a.dx, a.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = _pinColor);
    canvas.drawCircle(origin + Offset(14 * k, 10 * k), 4 * k, Paint()..color = _dotColor);
  }

  /// نقطة موقع المستخدم: دائرة زرقاء بحد أبيض وظل خفيف (مركزها = [center])
  static void paintUserDot(Canvas canvas, Offset center, double k) {
    final radius = userDotSize / 2 * k;
    canvas.drawCircle(center + Offset(0, k), radius + k, Paint()..color = const Color(0x33000000)..maskFilter = MaskFilter.blur(BlurStyle.normal, k));
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
    canvas.drawCircle(center, radius - 3 * k, Paint()..color = _userColor);
  }

  static TextStyle labelStyle(DesignScale scale) => figmaText(scale, size: 14, weight: FigmaWeight.semiBold, color: Colors.black);

  /// دبوس الوجهة مع اسمها كصورة لـ Google Maps
  static Future<MapMarkerIcon> pin({
    required String label,
    required DesignScale scale,
    required double pixelRatio,
    required TextDirection direction,
  }) async {
    final text = TextPainter(
      text: TextSpan(text: label, style: labelStyle(scale)),
      textDirection: direction,
      maxLines: 1,
    )..layout();

    final pin = scale.x(pinSize);
    final width = math.max(pin, text.width).ceilToDouble();
    final height = (pin + text.height).ceilToDouble();

    final bytes = await _render(width, height, pixelRatio, (canvas) {
      paintPin(canvas, Offset((width - pin) / 2, 0), scale.sx);
      text.paint(canvas, Offset((width - text.width) / 2, pin));
    });
    return (icon: BitmapDescriptor.bytes(bytes, imagePixelRatio: pixelRatio), anchor: Offset(0.5, scale.x(tipY) / height));
  }

  /// دبوس بدون اسم كصورة لـ Google Maps (أبواب الحرم غير المختارة — زي Figma 21:1859)
  static Future<MapMarkerIcon> plainPin({required DesignScale scale, required double pixelRatio}) async {
    final pin = scale.x(pinSize);
    final bytes = await _render(pin, pin, pixelRatio, (canvas) => paintPin(canvas, Offset.zero, scale.sx));
    return (icon: BitmapDescriptor.bytes(bytes, imagePixelRatio: pixelRatio), anchor: Offset(0.5, tipY / pinSize));
  }

  static Future<Uint8List> _render(double width, double height, double pixelRatio, void Function(Canvas canvas) paint) async {
    final recorder = ui.PictureRecorder();
    paint(Canvas(recorder)..scale(pixelRatio));
    final image = await recorder.endRecording().toImage((width * pixelRatio).ceil(), (height * pixelRatio).ceil());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  }
}

/// دبوس الوجهة مع اسمها كويدجت (للخريطة البديلة)
class DestinationPin extends StatelessWidget {
  final String label;
  final DesignScale scale;

  const DestinationPin({super.key, required this.label, required this.scale});

  @override
  Widget build(BuildContext context) {
    final pin = scale.x(MapMarker.pinSize);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(size: Size(pin, pin), painter: _PinPainter(scale.sx)),
        SizedBox(
          height: scale.x(MapMarker.labelHeight),
          child: FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1, softWrap: false, style: MapMarker.labelStyle(scale))),
        ),
      ],
    );
  }
}

/// دبوس بدون اسم كويدجت (أبواب الحرم غير المختارة بالخريطة البديلة)
class PlainPin extends StatelessWidget {
  final DesignScale scale;

  const PlainPin({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    final pin = scale.x(MapMarker.pinSize);
    return CustomPaint(size: Size(pin, pin), painter: _PinPainter(scale.sx));
  }
}

/// نقطة موقع المستخدم كويدجت (للخريطة البديلة وزر "موقعي")
class UserDot extends StatelessWidget {
  final DesignScale scale;

  const UserDot({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    final size = scale.x(MapMarker.userDotSize + 4);
    return CustomPaint(size: Size(size, size), painter: _UserDotPainter(scale.sx));
  }
}

class _PinPainter extends CustomPainter {
  final double k;

  const _PinPainter(this.k);

  @override
  void paint(Canvas canvas, Size size) => MapMarker.paintPin(canvas, Offset.zero, k);

  @override
  bool shouldRepaint(_PinPainter oldDelegate) => oldDelegate.k != k;
}

class _UserDotPainter extends CustomPainter {
  final double k;

  const _UserDotPainter(this.k);

  @override
  void paint(Canvas canvas, Size size) => MapMarker.paintUserDot(canvas, size.center(Offset.zero), k);

  @override
  bool shouldRepaint(_UserDotPainter oldDelegate) => oldDelegate.k != k;
}
