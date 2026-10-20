import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import 'terms_paragraph_view.dart';
import 'terms_sections.dart';

// -------------------------------------------------------------
// كرت قسم (Figma "Frame 2147227397"): أبيض 359 — radius 16 — ظل أزرق خفيف (0,2 blur 5.4)
// حدّه #1F3B2E: كامل لكرت التبويب المختار، و25% للباقي
// -------------------------------------------------------------
abstract final class TermsCard {
  static const left = 17.0;
  static const width = 359.0;
  static const _radius = 16.0;
  static const _faded = Color(0x401F3B2E);
  // الظل مقاس من رندر Figma (أزرق شفاف تحت الكرت أكتر من فوقه)
  static const _shadowColor = Color(0x3A60A5FA);

  /// [cardKey]: للتمرير لعند الكرت لما ينختار تبويبه
  static List<Widget> build(FigmaCanvas c, TermsSection section, {required bool selected, Key? cardKey}) {
    final s = c.s;
    final paragraphs = section.paragraphs;
    return [
      c.rect(
        left: left,
        top: section.top,
        width: width,
        height: section.height,
        child: IgnorePointer(
          child: AnimatedContainer(
            key: cardKey,
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(s.x(_radius)),
              border: Border.all(color: selected ? FigmaCanvas.green : _faded, width: s.x(1)),
              boxShadow: [BoxShadow(color: _shadowColor, offset: Offset(0, s.y(2)), blurRadius: s.x(3.8))],
            ),
          ),
        ),
      ),
      for (final (i, p) in paragraphs.indexed)
        TermsParagraphView.build(
          c,
          label: p.label(),
          body: p.body(),
          baseline: p.baseline,
          bottom: i + 1 < paragraphs.length ? paragraphs[i + 1].baseline - section.lineHeight : section.top + section.height - 8,
          lineHeight: section.lineHeight,
          labelStyle: c.style(16, FigmaWeight.sfBold, FigmaCanvas.green),
          // النص Regular 400 (Noto Sans Arabic)
          bodyStyle: c.style(16, FigmaWeight.poppinsRegular, Colors.black),
        ),
    ];
  }
}
