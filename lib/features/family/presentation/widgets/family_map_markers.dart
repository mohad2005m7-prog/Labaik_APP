import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import 'family_colors.dart';
import 'family_icons.dart';

// -------------------------------------------------------------
// دبابيس خريطة العائلة (Figma 111:6522 — مقاسة من لقطته):
//   فرد: دبوس 16×23 (أحمر متصل / أحمر 50% غير متصل) واسمه تحته (Poppins 600 13 #1F3B2E)
//   أنا: كرة زرقا على عود فوق حلقات زرقا 64×20 و"أنت" تحتهم
//   نقطة التجمع: العلم فوق حلقات صفرا و"نقطة التجمع" تحتهم
// كل دبوس بيعرف وين طرفه ([tipY]) حتى ينحط بالظبط على الإحداثيات
// -------------------------------------------------------------
abstract final class FamilyMarkerSize {
  static const width = 90.0;

  // فرد: الدبوس 23 + الاسم
  static const memberTip = 23.0;
  static const memberHeight = memberTip + 1 + 18;

  // أنا ونقطة التجمع: الحلقات بتبلش فوق الطرف بـ 4 وطولها 20، والاسم بعدها بـ 2
  static const ringedTip = 24.0;
  static const ringedHeight = ringedTip + 16 + 2 + 18;
}

TextStyle _label(DesignScale s) => figmaText(s, size: 13, weight: FigmaWeight.semiBold, color: FamilyColors.green, lineHeight: null, letterSpacing: 0);

Widget _name(DesignScale s, String text, double top) => Positioned(
      left: 0,
      right: 0,
      top: s.x(top),
      height: s.x(18),
      child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: Text(text, maxLines: 1, style: _label(s)))),
    );

class FamilyMemberMarker extends StatelessWidget {
  final DesignScale s;
  final String name;
  final bool online;

  const FamilyMemberMarker({super.key, required this.s, required this.name, required this.online});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: s.x(FamilyMarkerSize.width / 2 - 8),
          top: 0,
          child: MapPinIcon(width: s.x(16), height: s.x(23), color: online ? FamilyColors.pinOnline : FamilyColors.pinOffline, hole: const Color(0xFFFBEDE3)),
        ),
        _name(s, name, FamilyMarkerSize.memberTip + 1),
      ],
    );
  }
}

/// أنا (كرة زرقا) أو نقطة التجمع (علم) فوق حلقاتهم
class FamilyRingedMarker extends StatelessWidget {
  final DesignScale s;
  final String label;
  final bool meetingPoint;

  const FamilyRingedMarker({super.key, required this.s, required this.label, this.meetingPoint = false});

  @override
  Widget build(BuildContext context) {
    const tip = FamilyMarkerSize.ringedTip, center = FamilyMarkerSize.width / 2;
    final ring = meetingPoint ? FamilyColors.meeting : FamilyColors.me;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: s.x(center - 32),
          top: s.x(tip - 4),
          child: PinRings(width: s.x(64), color: ring, core: meetingPoint ? const Color(0xFFFFC94A) : FamilyColors.me),
        ),
        if (meetingPoint)
          // العلم: عموده (من 1 لـ 3 بصندوقه) على الطرف
          Positioned(left: s.x(center - 2 * 22 / 22.5), top: s.x(tip - 22), child: FlagIcon(height: s.x(22)))
        else
          Positioned(left: s.x(center - 6), top: 0, child: BallPinIcon(height: s.x(tip), color: FamilyColors.me)),
        _name(s, label, tip + 18),
      ],
    );
  }
}
