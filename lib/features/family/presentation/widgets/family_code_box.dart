import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/design_scale.dart';
import 'family_colors.dart';

// -------------------------------------------------------------
// رمز دائرتي ("رمز المجموعة :" — Figma 357×40 #EEF2F2 بحد أسود و radius 10): الرمز بالنص
// الضغط المطوّل بينسخه — لحد ما ينشئه السيرفر بيضل فاضي
// -------------------------------------------------------------
class FamilyCodeBox extends StatelessWidget {
  final DesignScale s;
  final String? code;
  final VoidCallback onCopied;

  const FamilyCodeBox({super.key, required this.s, required this.code, required this.onCopied});

  /// الرمز لاتيني (Poppins 500 15 أسود) — مقاس من حبر Figma
  static TextStyle style(DesignScale s, Color color) => TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: s.x(15), height: 1.2, color: color, letterSpacing: 0);

  @override
  Widget build(BuildContext context) {
    final value = code;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: value == null
          ? null
          : () async {
              await Clipboard.setData(ClipboardData(text: value));
              onCopied();
            },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: FamilyColors.cardFill,
          borderRadius: BorderRadius.circular(s.x(10)),
          border: Border.all(color: Colors.black, width: s.x(1)),
        ),
        child: Center(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(value ?? '', maxLines: 1, style: style(s, Colors.black)),
          ),
        ),
      ),
    );
  }
}
