import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/design_scale.dart';
import '../l10n/field_mode_text.dart';
import 'field_colors.dart';

// -------------------------------------------------------------
// زر البوصلة فوق الخريطة (فوق يسار — مقابل زر "موقعي"):
// الإبرة الحمرا بتأشّر على الشمال دايماً، والضغط بيرجّع الخريطة للشمال بنعومة
// -------------------------------------------------------------
class MapCompassButton extends StatelessWidget {
  final DesignScale scale;
  final ValueListenable<double> northDegrees; // زاوية الشمال على الشاشة (مع عقارب الساعة)
  final VoidCallback onTap;

  const MapCompassButton({super.key, required this.scale, required this.northDegrees, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = scale.x(38);
    return Positioned(
      top: scale.x(10),
      left: scale.x(10),
      child: Tooltip(
        message: FieldModeText.compass(),
        child: Material(
          color: Colors.white,
          elevation: 2,
          borderRadius: BorderRadius.circular(scale.x(8)),
          child: InkWell(
            borderRadius: BorderRadius.circular(scale.x(8)),
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: ValueListenableBuilder<double>(
                  valueListenable: northDegrees,
                  builder: (context, degrees, _) => Transform.rotate(
                    angle: degrees * math.pi / 180,
                    child: CustomPaint(size: Size(scale.x(14), scale.x(24)), painter: const _NeedlePainter()),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NeedlePainter extends CustomPainter {
  const _NeedlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final north = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, h / 2)
      ..lineTo(0, h / 2)
      ..close();
    final south = Path()
      ..moveTo(0, h / 2)
      ..lineTo(w, h / 2)
      ..lineTo(w / 2, h)
      ..close();
    canvas.drawPath(north, Paint()..color = const Color(0xFFE74C3C));
    canvas.drawPath(south, Paint()..color = FieldColors.green.withValues(alpha: 0.35));
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.14, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_NeedlePainter oldDelegate) => false;
}
