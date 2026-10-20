import 'package:flutter/material.dart';

import '../../../../core/theme/figma_spaced_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import 'duas_colors.dart';

// -------------------------------------------------------------
// زر دعاء مقترح بالقائمة: 360×49 — #EEF2F2 — ظل Figma — الاسم (#1F3B2E) بيبدأ عند x239
// -------------------------------------------------------------
class SuggestedDuaTile extends StatelessWidget {
  final FigmaCanvas c;
  final String title;
  final VoidCallback onTap;

  const SuggestedDuaTile({super.key, required this.c, required this.title, required this.onTap});

  // من طرف الزر (x376) لبداية الاسم (x239)
  static const _titleStart = 376.0 - 239.0;
  static const _titleWidth = 239.0 - 32.0;

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: s.y(49),
        // الاسم بـ Figma أوطى بـ 1.5 من نص الزر (مقاس)
        padding: EdgeInsetsDirectional.only(start: s.x(_titleStart), top: s.y(3)),
        alignment: AlignmentDirectional.centerStart,
        decoration: BoxDecoration(color: DuasColors.cardFill, borderRadius: BorderRadius.circular(s.x(10)), boxShadow: [c.shadow]),
        child: FigmaSpacedText(
          title,
          style: c.style(16, FigmaWeight.semiBold, DuasColors.green, lineHeight: null),
          letterSpacing: s.x(-0.408),
          width: s.x(_titleWidth),
          maxLines: 1,
        ),
      ),
    );
  }
}
