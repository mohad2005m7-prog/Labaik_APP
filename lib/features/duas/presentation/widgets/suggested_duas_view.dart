import 'package:flutter/material.dart';

import '../../../../core/utils/figma_canvas.dart';
import '../../domain/entities/suggested_dua.dart';
import '../l10n/suggested_dua_text.dart';
import 'suggested_dua_tile.dart';

// -------------------------------------------------------------
// تبويب "أدعية مقترحة" (إطار 174:2863 — 901 طول): 10 أزرار 360×49 من y237 وبينهم 16
// القائمة أطول من الشاشة فبتتمرر (التبويبات والعنوان ثابتين فوقها)
// -------------------------------------------------------------
class SuggestedDuasView extends StatelessWidget {
  /// كانفس بيبدأ عند y206 بإطار Figma
  final FigmaCanvas c;
  final List<SuggestedDua> duas;
  final ValueChanged<SuggestedDua> onOpen;

  const SuggestedDuasView({super.key, required this.c, required this.duas, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    return ListView.separated(
      physics: const ClampingScrollPhysics(),
      // الزر من x16 لـ x376
      padding: EdgeInsetsDirectional.only(start: s.x(FigmaCanvas.frameWidth - 376), end: s.x(16), top: s.y(237 - c.originTop), bottom: s.y(16)),
      itemCount: duas.length,
      separatorBuilder: (_, _) => SizedBox(height: s.y(16)),
      itemBuilder: (_, i) => SuggestedDuaTile(c: c, title: SuggestedDuaText.title(duas[i].number), onTap: () => onOpen(duas[i])),
    );
  }
}
