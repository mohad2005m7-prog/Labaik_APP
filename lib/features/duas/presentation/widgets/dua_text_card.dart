import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/figma_spaced_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import 'duas_colors.dart';
import 'suggested_dua_layout.dart';

// -------------------------------------------------------------
// كرت نص دعاء (شاشة الدعاء الأول … العاشر): #EEF2F2 — radius 10 — ظل Figma
// النص (SF Compact 556 14 lh22 أسود) بمكانه بـ Figma بالظبط (طرفه اليمين وأعلى سطره)
// والكرت بارتفاعه بـ Figma، وبيطول بس لو النص احتاج أكتر (ما بيطلع برا الكرت)
// -------------------------------------------------------------
class DuaTextCard extends StatelessWidget {
  final FigmaCanvas c;
  final DuaCardLayout layout;
  final String text;

  const DuaTextCard({super.key, required this.c, required this.layout, required this.text});

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    final right = layout.left + DuaCardLayout.width;
    return Padding(
      padding: EdgeInsetsDirectional.only(start: s.x(FigmaCanvas.frameWidth - right)),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          width: s.x(DuaCardLayout.width),
          constraints: BoxConstraints(minHeight: s.y(layout.height)),
          alignment: AlignmentDirectional.topStart,
          padding: EdgeInsetsDirectional.only(
            start: s.x(right - layout.textRight),
            top: s.y(math.max(0, layout.textTop - layout.top)),
            // كرت مش مصمم بـ Figma (ارتفاعه 0): هامش تحت النص زي فوقه
            bottom: s.y(layout.height == 0 ? layout.textTop - layout.top : 0),
          ),
          decoration: BoxDecoration(
            color: DuasColors.cardFill,
            borderRadius: BorderRadius.circular(s.x(10)),
            boxShadow: layout.shadow ? [c.shadow] : null,
          ),
          child: FigmaSpacedText(text, style: c.style(14, FigmaWeight.semiBold, Colors.black), letterSpacing: s.x(-0.408), width: s.x(DuaCardLayout.textWidth), direction: TextDirection.rtl),
        ),
      ),
    );
  }
}
