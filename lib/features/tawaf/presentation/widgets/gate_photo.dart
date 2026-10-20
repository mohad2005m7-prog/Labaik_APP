import 'package:flutter/material.dart';

import '../../../field_mode/data/models/destination_info_dto.dart';
import '../../../field_mode/data/sources/haram_gates.dart';
import 'tawaf_page.dart';

// -------------------------------------------------------------
// صورة الباب اللي وصله المعتمر (شاشة "وصلت إلى باب …" — 361×386 radius 10):
//   باب الملك فهد: صورة Figma نفسها — باقي الأبواب: صورتها من السيرفر (imageUrl)
//   وإذا ما في صورة: مكانها بلون الكرت وأيقونة باب (ما بنحط صورة باب غيره)
// -------------------------------------------------------------
class GatePhoto extends StatelessWidget {
  final DestinationInfoDto gate;

  const GatePhoto({super.key, required this.gate});

  static const kingFahdAsset = 'assets/images/tawaf/gate_king_fahd.jpg';

  @override
  Widget build(BuildContext context) {
    final url = gate.imageUrl;
    final Widget placeholder = ColoredBox(
      color: TawafColors.card,
      child: Center(
        child: Icon(Icons.door_front_door_outlined, size: 56, color: TawafColors.accent.withValues(alpha: 0.6)),
      ),
    );
    if (gate.targetId == HaramGates.defaultGateId) return Image.asset(kingFahdAsset, fit: BoxFit.cover);
    if (url == null) return placeholder;
    return Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder);
  }
}
