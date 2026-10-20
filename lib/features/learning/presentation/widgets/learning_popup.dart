import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_lines.dart';
import '../../../../core/widgets/top_popup.dart';
import 'learning_colors.dart';
import 'learning_popup_spec.dart';

// -------------------------------------------------------------
// نافذة مرحلة التعلم ("Success Screen" — 391 عرض #ECF4F1 radius 16) — بتنزل من فوق وبتثبت بالنص (TopPopup)
// العنوان SF Compact 790 20 (line height 28) بالنص — الفقرات 14 (أوزانها مقاسة بعرض سطور Figma) — النقاط "•" قبل كل فقرة بالقوائم — زر أخضر 183×39
// -------------------------------------------------------------
class LearningPopup extends StatelessWidget {
  final LearningPopupSpec spec;
  final VoidCallback onButton;

  const LearningPopup({super.key, required this.spec, required this.onButton});

  // الكرت من x1 بإطار الشاشة (393)
  static const _x = 1.0;

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    final c = FigmaCanvas(s, originTop: 0);
    final icon = spec.icon, iconBox = spec.iconBox;
    return TopPopup(
      height: spec.height,
      child: Stack(
        children: [
          c.box(left: _x, top: 0, width: 391, height: spec.height, color: LearningColors.popup, radius: 16),
          if (icon != null && iconBox != null) c.image(icon, left: _x + iconBox.left, top: iconBox.top, width: iconBox.width, height: iconBox.height, color: Colors.black),
          FigmaLines.build(
            c,
            spec.title(),
            left: _x + spec.titleLeft,
            top: spec.titleTop,
            width: 361,
            lineHeight: 28,
            align: TextAlign.center,
            style: c.style(20, 670, Colors.black),
          ),
          for (final (i, block) in spec.blocks.indexed) ..._block(c, block, bottom: i + 1 < spec.blocks.length ? spec.blocks[i + 1].top : spec.button.top),
          c.button(
            spec.buttonLabel(),
            left: _x + spec.button.left,
            top: spec.button.top,
            width: spec.button.width,
            height: spec.button.height,
            labelSize: 15.3,
            labelWeight: FigmaWeight.sfRegular,
            figmaSpacing: true,
            // نص الزر بـ Figma مزاح 3 لليمين عن نص الزر
            labelDx: 3,
            onTap: onButton,
          ),
        ],
      ),
    );
  }

  /// [bottom]: أول الفقرة اللي بعدها أو الزر — الإنجليزي بيلتف لحده
  List<Widget> _block(FigmaCanvas c, LearningPopupBlock block, {required double bottom}) {
    final style = c.style(14, block.weight, Colors.black);
    final bullet = block.bulletRight;
    return [
      if (bullet != null) FigmaLines.build(c, '•', left: _x + bullet - 12, top: block.top, width: 12, wrap: false, style: style),
      FigmaLines.build(
        c,
        block.text(),
        left: _x + block.left,
        top: block.top,
        width: block.width,
        maxHeight: bottom - 4 - block.top,
        align: block.center ? TextAlign.center : TextAlign.start,
        style: style,
      ),
    ];
  }
}
