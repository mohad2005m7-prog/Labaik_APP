import 'dart:math' as math;

import 'package:flutter/material.dart';

// -------------------------------------------------------------
// أيقونات دائرة العائلة مرسومة (أشكالها مقاسة من لقطات Figma المكبّرة):
//   MapPinIcon     — دبوس موقع (رأس دائري فيه فتحة وطرف تحت) — 16×23 بصندوق 28
//   FlagIcon       — علم نقطة التجمع الأصفر بعمود
//   DotsIcon       — الثلاث نقاط العمودية بالكرت
//   ChatDotsIcon   — فقاعة محادثة مليانة فيها 3 نقاط (قائمة الكرت)
//   TrashIcon      — سلة الحذف (غطا + جسم بخطوط)
//   LocateIcon     — زر موقعي على الخريطة (حلقة + 4 خطوط)
//   PinRings       — دواير بيضاوية تحت دبوسي/نقطة التجمع
//   BallPinIcon    — دبوسي (كرة زرقا على عود)
//   LocationRingsIcon — دبوس بحلقتين (شاشة مشاركة الموقع)
//   FamilyGroupIcon — 3 أشخاص (كرت الدائرة بشاشة العثور عليها)
//   SearchLensIcon — عدسة البحث
// -------------------------------------------------------------
class MapPinIcon extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  /// فتحة الرأس (بيضا) — الدبوس بالقوائم ما إله فتحة لونها غير الخلفية
  final Color hole;

  const MapPinIcon({super.key, required this.width, required this.height, required this.color, this.hole = Colors.white});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(width, height), painter: _PinPainter(color, hole));
}

class _PinPainter extends CustomPainter {
  final Color color;
  final Color hole;

  _PinPainter(this.color, this.hole);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final r = w / 2;
    final cy = r;
    // الرأس دايرة، والجانبين بيلتقوا بالطرف تحت
    final path = Path()
      ..moveTo(w / 2, h)
      ..quadraticBezierTo(w * 0.06, h * 0.58, 0, cy)
      ..arcToPoint(Offset(w, cy), radius: Radius.circular(r))
      ..quadraticBezierTo(w * 0.94, h * 0.58, w / 2, h)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawCircle(Offset(w / 2, cy), r * 0.38, Paint()..color = hole);
  }

  @override
  bool shouldRepaint(_PinPainter old) => old.color != color || old.hole != hole;
}

/// علم نقطة التجمع (Figma — مقاس من لقطاته): عمود #4E5F69 بقاعدة، وقماشة بقطعتين (الثانية أوطى وفيها شق)
/// الصندوق 15×22.5 — [height] = ارتفاعه
class FlagIcon extends StatelessWidget {
  final double height;
  final Color flag;
  final Color wave;
  final Color pole;

  const FlagIcon({super.key, required this.height, this.flag = const Color(0xFFFFD12F), this.wave = const Color(0xFFFFDB56), this.pole = const Color(0xFF4E5F69)});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(height * 15 / 22.5, height), painter: _FlagPainter(flag, wave, pole));
}

class _FlagPainter extends CustomPainter {
  final Color flag;
  final Color wave;
  final Color pole;

  _FlagPainter(this.flag, this.wave, this.pole);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.height / 22.5;
    final far = Path()
      ..moveTo(8.75 * k, 4 * k)
      ..lineTo(15 * k, 4 * k)
      ..lineTo(13.75 * k, 8.6 * k)
      ..lineTo(15 * k, 13.25 * k)
      ..lineTo(8.75 * k, 13.25 * k)
      ..close();
    canvas
      ..drawPath(far, Paint()..color = wave)
      ..drawRect(Rect.fromLTRB(3 * k, 1.5 * k, 9 * k, 11.5 * k), Paint()..color = flag)
      ..drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(1 * k, 0, 3 * k, 22 * k), Radius.circular(0.8 * k)), Paint()..color = pole)
      ..drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(0, 21 * k, 4.5 * k, 22.5 * k), Radius.circular(0.75 * k)), Paint()..color = pole);
  }

  @override
  bool shouldRepaint(_FlagPainter old) => old.flag != flag || old.wave != wave || old.pole != pole;
}

/// [dot]: قطر النقطة (النقاط من فوق لتحت على طول [height])
class DotsIcon extends StatelessWidget {
  final double height;
  final double dot;
  final Color color;

  const DotsIcon({super.key, required this.height, required this.dot, this.color = Colors.black});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(dot, height), painter: _DotsPainter(color));
}

class _DotsPainter extends CustomPainter {
  final Color color;

  _DotsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final paint = Paint()..color = color;
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(r, r + i * (size.height - 2 * r) / 2), r, paint);
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => old.color != color;
}

class ChatDotsIcon extends StatelessWidget {
  final double size;
  final Color color;

  const ChatDotsIcon({super.key, required this.size, this.color = Colors.black});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _ChatPainter(color));
}

class _ChatPainter extends CustomPainter {
  final Color color;

  _ChatPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final paint = Paint()..color = color;
    canvas.drawOval(Rect.fromLTWH(0, 0, s, s * 0.86), paint);
    // ذيل الفقاعة تحت يسار
    canvas.drawPath(
      Path()
        ..moveTo(s * 0.12, s * 0.62)
        ..lineTo(s * 0.04, s)
        ..lineTo(s * 0.4, s * 0.8)
        ..close(),
      paint,
    );
    final white = Paint()..color = Colors.white;
    for (final x in [0.28, 0.5, 0.72]) {
      canvas.drawCircle(Offset(s * x, s * 0.43), s * 0.075, white);
    }
  }

  @override
  bool shouldRepaint(_ChatPainter old) => old.color != color;
}

class TrashIcon extends StatelessWidget {
  final double size;
  final Color color;

  const TrashIcon({super.key, required this.size, this.color = Colors.black});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _TrashPainter(color));
}

class _TrashPainter extends CustomPainter {
  final Color color;

  _TrashPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final paint = Paint()..color = color;
    // المقبض والغطا
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.36, 0, s * 0.28, s * 0.12), Radius.circular(s * 0.04)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.06, s * 0.1, s * 0.88, s * 0.12), Radius.circular(s * 0.04)), paint);
    // الجسم
    final body = Path()
      ..moveTo(s * 0.14, s * 0.26)
      ..lineTo(s * 0.86, s * 0.26)
      ..lineTo(s * 0.8, s)
      ..lineTo(s * 0.2, s)
      ..close();
    canvas.drawPath(body, paint);
    final white = Paint()
      ..color = Colors.white
      ..strokeWidth = s * 0.07
      ..strokeCap = StrokeCap.round;
    for (final x in [0.34, 0.5, 0.66]) {
      canvas.drawLine(Offset(s * x, s * 0.38), Offset(s * x, s * 0.88), white);
    }
  }

  @override
  bool shouldRepaint(_TrashPainter old) => old.color != color;
}

class LocateIcon extends StatelessWidget {
  final double size;
  final Color color;

  const LocateIcon({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _LocatePainter(color));
}

class _LocatePainter extends CustomPainter {
  final Color color;

  _LocatePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.085;
    // حلقة فاضية بالنص (Figma: قطرها 12 من 24) و4 خطوط لطرف المربع
    canvas.drawCircle(c, s * 0.25, stroke);
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      canvas.drawLine(c + Offset(math.cos(a), math.sin(a)) * s * 0.29, c + Offset(math.cos(a), math.sin(a)) * s * 0.5, stroke);
    }
  }

  @override
  bool shouldRepaint(_LocatePainter old) => old.color != color;
}

/// دواير بيضاوية متداخلة (Figma: 64×20 و 40×13 و 28×9 بخط 1) تحت الدبوس — [width] = عرض الكبيرة
/// [core]: البيضاوي الصغير المليان تحت العود (أزرق تحت دبوسي، أصفر تحت العلم)
class PinRings extends StatelessWidget {
  final double width;
  final Color color;
  final Color? core;

  const PinRings({super.key, required this.width, required this.color, this.core});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(width, width * 20 / 64), painter: _RingsPainter(color, core));
}

class _RingsPainter extends CustomPainter {
  final Color color;
  final Color? core;

  _RingsPainter(this.color, this.core);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 64;
    final fill = Paint()..color = Colors.white;
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = k;
    // بـ Figma التلاتة بنفس الأعلى وبنص بعض أفقياً
    for (final (w, h) in [(64.0, 20.0), (40.0, 13.0), (28.0, 9.0)]) {
      final rect = Rect.fromLTWH((64 - w) / 2 * k, 0, w * k, h * k);
      canvas
        ..drawOval(rect, fill)
        ..drawOval(rect, line);
    }
    final coreColor = core;
    if (coreColor != null) canvas.drawOval(Rect.fromLTWH(22.5 * k, 2.5 * k, 19 * k, 5 * k), Paint()..color = coreColor);
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.color != color || old.core != core;
}

/// دبوسي على الخريطة وبالمفتاح ("موقعك أنت"): كرة #372EDD فيها لمعة وتحتها عود رمادي — [height] = الكل (الكرة 12 من 24.5)
class BallPinIcon extends StatelessWidget {
  final double height;
  final Color color;

  const BallPinIcon({super.key, required this.height, required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(height * 12 / 24.5, height), painter: _BallPinPainter(color));
}

class _BallPinPainter extends CustomPainter {
  final Color color;

  _BallPinPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 12;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(5.4 * k, 10 * k, 1.2 * k, size.height - 10 * k), Radius.circular(0.6 * k)), Paint()..color = const Color(0xFF9AA2AC));
    canvas.drawCircle(Offset(6 * k, 6 * k), 6 * k, Paint()..color = color);
    canvas.drawCircle(Offset(4.2 * k, 4.2 * k), 1 * k, Paint()..color = Colors.white.withValues(alpha: 0.45));
  }

  @override
  bool shouldRepaint(_BallPinPainter old) => old.color != color;
}

/// أيقونة "مشاركة موقعك مع عائلتك" (111:5228): دبوس أسود بفتحة وتحته حلقتين مفتوحتين من فوق — 43.5×43.5
class LocationRingsIcon extends StatelessWidget {
  final double size;
  final Color color;

  const LocationRingsIcon({super.key, required this.size, this.color = Colors.black});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _LocationRingsPainter(color));
}

class _LocationRingsPainter extends CustomPainter {
  final Color color;

  _LocationRingsPainter(this.color);

  // قوس بيضاوي من غير الجزء اللي فوق: [gapX] = نص عرض الفتحة نسبةً لنص عرض الحلقة
  static void _openRing(Canvas canvas, Rect rect, double gapX, Paint paint) {
    final edge = math.acos(gapX);
    canvas.drawArc(rect, -edge, 2 * math.pi - (math.pi - 2 * edge), false, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 43.5;
    canvas.saveLayer(Offset.zero & size, Paint());
    final ring = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6 * k
      ..strokeCap = StrokeCap.round;
    // الحلقات (حبرها: الكبيرة 45×13 والصغيرة 29.5×8.5) — الكبيرة مفتوحة من فوق والصغيرة مكان طرف الدبوس
    _openRing(canvas, Rect.fromLTRB(1.3 * k, 31.8 * k, 42.2 * k, 42.2 * k), 0.8, ring);
    _openRing(canvas, Rect.fromLTRB(8.3 * k, 30.8 * k, 35.2 * k, 37 * k), 0.5, ring);
    // الدبوس 24.5×33.5 بالنص
    final w = 24.5 * k, left = 9.5 * k, r = w / 2, tip = 33.5 * k;
    final pin = Path()
      ..moveTo(left + r, tip)
      ..quadraticBezierTo(left + w * 0.05, r * 1.7, left, r)
      ..arcToPoint(Offset(left + w, r), radius: Radius.circular(r))
      ..quadraticBezierTo(left + w * 0.95, r * 1.7, left + r, tip)
      ..close();
    canvas.drawPath(pin, Paint()..color = color);
    // الفتحة شفافة (بيبيّن لون الكرت تحتها)
    canvas.drawCircle(Offset(left + r, 11.25 * k), 5.1 * k, Paint()..blendMode = BlendMode.clear);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LocationRingsPainter old) => old.color != color;
}

/// أيقونة الدائرة بـ "تم العثور على دائرة عائلتك" (Figma — حبرها 48.35×34.8): 3 روس (الأوسط أكبر وأعلى)
/// وتحتهم قبة كبيرة بالنص وربع قبة على كل جنب — كلهم بقاعدة وحدة
class FamilyGroupIcon extends StatelessWidget {
  final double width;
  final Color color;

  const FamilyGroupIcon({super.key, required this.width, required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(width, width * 34.8 / 48.35), painter: _FamilyGroupPainter(color));
}

class _FamilyGroupPainter extends CustomPainter {
  final Color color;

  _FamilyGroupPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 48.35;
    final paint = Paint()..color = color;
    canvas
      ..drawCircle(Offset(24.2 * k, 8.1 * k), 7.95 * k, paint)
      ..drawCircle(Offset(8.1 * k, 15.3 * k), 5.75 * k, paint)
      ..drawCircle(Offset(40.25 * k, 15.3 * k), 5.75 * k, paint)
      ..drawRRect(RRect.fromLTRBAndCorners(11.4 * k, 18.6 * k, 37.1 * k, 34.8 * k, topLeft: Radius.elliptical(12.85 * k, 13 * k), topRight: Radius.elliptical(12.85 * k, 13 * k)), paint)
      ..drawRRect(RRect.fromLTRBAndCorners(0, 23.35 * k, 10.85 * k, 34.8 * k, topLeft: Radius.elliptical(10.85 * k, 10 * k), topRight: Radius.circular(1.5 * k)), paint)
      ..drawRRect(RRect.fromLTRBAndCorners(37.5 * k, 23.35 * k, 48.35 * k, 34.8 * k, topRight: Radius.elliptical(10.85 * k, 10 * k), topLeft: Radius.circular(1.5 * k)), paint);
  }

  @override
  bool shouldRepaint(_FamilyGroupPainter old) => old.color != color;
}

/// عدسة البحث (Figma 15×15 سودا معتمة): دايرة بخط 1.8 ومقبض لتحت يمين
class SearchLensIcon extends StatelessWidget {
  final double size;
  final Color color;

  const SearchLensIcon({super.key, required this.size, this.color = Colors.black});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _LensPainter(color));
}

class _LensPainter extends CustomPainter {
  final Color color;

  _LensPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 15;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * k
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawCircle(Offset(6.3 * k, 6.3 * k), 5.4 * k, paint)
      ..drawLine(Offset(10.4 * k, 10.4 * k), Offset(14.1 * k, 14.1 * k), paint..strokeWidth = 2 * k);
  }

  @override
  bool shouldRepaint(_LensPainter old) => old.color != color;
}
