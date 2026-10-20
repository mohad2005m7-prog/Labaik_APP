import 'package:flutter/material.dart';

import '../../../../core/theme/figma_spaced_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/content_direction.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../domain/entities/personal_dua.dart';
import '../l10n/duas_text.dart';
import 'duas_colors.dart';

// -------------------------------------------------------------
// كرت دعاء خاص ("Rectangle 138" — 359×90 أبيض بحد أسود 1 و radius 10)
// العنوان (16 #1F3B2E) عند +8، النص (12 أسود) عند +43، آخر تعديل (10 #717171) عند +62
// كل واحد سطر واحد — الطويل بينقطع بـ "…"
// الضغط عليه بيفتحه للتعديل، والضغطة المطوّلة: تعديل / حذف
// -------------------------------------------------------------
class PersonalDuaCard extends StatelessWidget {
  final FigmaCanvas c;
  final PersonalDua dua;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const PersonalDuaCard({super.key, required this.c, required this.dua, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    TextStyle style(double size, double weight, Color color) => c.style(size, weight, color, lineHeight: null, letterSpacing: 0);
    // العنوان والنص كتبهم المعتمر: اتجاههم حسب لغتهم (دعاء عربي بالواجهة الإنجليزية بيضل من اليمين)
    Widget line(String text, TextStyle style, {required double start, required double top, required double height}) {
      final direction = contentDirection(text) ?? Directionality.of(context);
      return PositionedDirectional(
        start: s.x(start),
        end: s.x(19),
        top: s.y(top),
        height: s.y(height),
        child: Align(
          alignment: direction == TextDirection.rtl ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: direction, style: style),
        ),
      );
    }

    final card = Container(
      height: s.y(90),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s.x(10)),
        border: Border.all(color: Colors.black, width: s.x(1)),
      ),
      child: Stack(
        children: [
          line(dua.title, style(16, FigmaWeight.sfRegular, DuasColors.green), start: 5, top: 8, height: 19),
          line(dua.text, style(12, FigmaWeight.sfRegular, Colors.black), start: 7, top: 43, height: 14),
          PositionedDirectional(
            start: s.x(12),
            top: s.y(62),
            height: s.y(22),
            child: Center(
              child: FigmaSpacedText(
                DuasText.lastEdited(dua.updatedAt),
                style: c.style(10, FigmaWeight.sfLight, DuasColors.grey),
                letterSpacing: s.x(-0.408),
                width: s.x(150),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, onLongPress: onLongPress, child: card);
  }
}
