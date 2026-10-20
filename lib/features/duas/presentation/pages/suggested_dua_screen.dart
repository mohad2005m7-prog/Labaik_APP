import 'package:flutter/material.dart';

import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../domain/entities/suggested_dua.dart';
import '../l10n/suggested_dua_text.dart';
import '../widgets/dua_text_card.dart';
import '../widgets/suggested_dua_layout.dart';

// -------------------------------------------------------------
// الدعاء الأول … العاشر — Figma "1" … "10" (174:3021 → 180:4716)
// كل نص بكرته بمكانه بالإطار بالظبط (suggested_dua_layout.dart)
// النصوص عربية باللغتين فالكروت دايماً من اليمين
// الإطارات 852 فالمحتوى بيوسع الشاشة — بيتمرر بس لو جهاز صغير ما وسعه
// -------------------------------------------------------------
class SuggestedDuaScreen extends StatelessWidget {
  final SuggestedDua dua;

  const SuggestedDuaScreen({super.key, required this.dua});

  // تحت الهيدر (Frame 38: y59 → 101)
  static const _contentTop = 101.0;

  @override
  Widget build(BuildContext context) {
    final layouts = dua.number <= suggestedDuaLayouts.length ? suggestedDuaLayouts[dua.number - 1] : const <DuaCardLayout>[];
    return FigmaPage(
      title: SuggestedDuaText.title(dua.number),
      body: (c) => [
        c.rect(
          left: 0,
          top: _contentTop,
          width: FigmaCanvas.frameWidth,
          height: 818 - _contentTop,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(bottom: c.s.y(16)),
              child: Column(children: _cards(c, layouts)),
            ),
          ),
        ),
      ],
    );
  }

  // كل كرت بمكانه: المسافة فوقه = من آخر الكرت اللي قبله لأوله بـ Figma
  // (نص زيادة عن Figma من الباك إند لاحقاً → بياخد مسافة 16 وارتفاع النص)
  List<Widget> _cards(FigmaCanvas c, List<DuaCardLayout> layouts) {
    final cards = <Widget>[];
    var bottom = _contentTop;
    for (final (i, text) in dua.texts.indexed) {
      final layout = i < layouts.length ? layouts[i] : DuaCardLayout(top: bottom + 16, height: 0, textTop: bottom + 26, textRight: 366);
      cards.add(
        Padding(
          padding: EdgeInsets.only(top: c.s.y(layout.top - bottom)),
          child: DuaTextCard(c: c, layout: layout, text: text),
        ),
      );
      bottom = layout.top + layout.height;
    }
    return cards;
  }
}
