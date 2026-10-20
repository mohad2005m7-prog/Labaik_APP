import 'package:flutter/material.dart';

import '../../../../core/utils/design_scale.dart';

// -------------------------------------------------------------
// حقوق بيانات OpenStreetMap (مطلوبة) — بزاوية الخريطة تحت (مكان "Map data" بصور Figma)
// بخلفية بيضا شفافة، والنص بيصغر لو الخريطة ضيقة (ما بيطلع برا)
// -------------------------------------------------------------
class MapAttribution extends StatelessWidget {
  final DesignScale s;

  const MapAttribution({super.key, required this.s});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: IgnorePointer(
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.6),
          color: const Color(0xB3FFFFFF),
          padding: EdgeInsets.symmetric(horizontal: s.x(4), vertical: s.x(1.5)),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('© OpenStreetMap contributors', maxLines: 1, textDirection: TextDirection.ltr, style: TextStyle(fontSize: s.x(9), color: const Color(0xFF555555))),
          ),
        ),
      ),
    );
  }
}
