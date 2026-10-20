import 'package:flutter/material.dart';

import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_chevron.dart';
import 'help_colors.dart';
import 'help_text.dart';

/// نص بكرت: (النص، طرف صندوقه اليمين، أعلاه، عرضه بـ Figma، الستايل)
typedef HelpCardLine = ({String text, double right, double top, double width, TextStyle style});

// -------------------------------------------------------------
// كرت بمركز المساعدة: #4C7A75 10% radius 10 وظل (0,4) blur 4 أسود 25%
// أيقونة (PNG شفاف بيتلوّن #1F3B2E) + عنوان + سطر شرح — والكروت العريضة فيها سهم "<" (18×18 من x32)
// كل الكرت بينضغط
// -------------------------------------------------------------
abstract final class HelpCard {
  static List<Widget> build(
    FigmaCanvas c, {
    required Rect card,
    required String icon,
    required Rect iconBox,
    required HelpCardLine title,
    required HelpCardLine subtitle,
    required double textRoom,
    required VoidCallback onTap,
    double? chevronTop,
  }) {
    Widget line(HelpCardLine l) => HelpText.line(c, l.text, right: l.right, top: l.top, boxWidth: l.width, room: textRoom, style: l.style);
    return [
      c.box(left: card.left, top: card.top, width: card.width, height: card.height, color: HelpColors.cardFill, radius: 10, hasShadow: true),
      c.image(icon, left: iconBox.left, top: iconBox.top, width: iconBox.width, height: iconBox.height, color: HelpColors.green),
      line(title),
      line(subtitle),
      // "Back Icon" 18×18: خطه 8.5×17 بسماكة 2 (حبره 10.5×19) بيأشّر لقدّام (يسار بالعربي)
      if (chevronTop != null)
        c.rect(
          left: 35.5,
          top: chevronTop,
          width: 8.5,
          height: 17,
          child: IgnorePointer(
            child: Center(
              child: FigmaChevron(width: c.s.x(8.5), height: c.s.x(17), stroke: c.s.x(2), color: HelpColors.green, pointsToEnd: true),
            ),
          ),
        ),
      c.tapArea(left: card.left, top: card.top, width: card.width, height: card.height, onTap: onTap),
    ];
  }
}
