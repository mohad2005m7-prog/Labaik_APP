import 'package:flutter/material.dart';

import '../../../../core/l10n/app_language.dart';
import '../../../../core/theme/figma_text.dart';
import '../l10n/tawaf_rounds_text.dart';
import '../widgets/tawaf_page.dart';
import '../widgets/tawaf_parts.dart';
import '../widgets/tawaf_ring.dart';
import '../widgets/tawaf_step_spec.dart';

// -------------------------------------------------------------
// "أنت الآن في الطواف" — شوط [round] من 7 (Figma 268:5033 … 268:5119):
// الحلقة (286 من 53,176 — أول 4 أشواط أكبر شوي) والرقم بنصها ← كرت الدعاء (SF Compact 556 13.5 — السابع 14) ← "الشوط n من ٧" ← تم الشوط
// أماكن الكرت والزر والسطر بتختلف شوي بين الأشواط بـ Figma ([_layouts])
// -------------------------------------------------------------
class TawafRoundScreen extends StatelessWidget {
  final int round;
  final VoidCallback onDone;

  const TawafRoundScreen({super.key, required this.round, required this.onDone});

  // لكل شوط: (أعلى الكرت، طوله، أعلى صندوق الدعاء، أعلى "الشوط n من ٧" وصندوقه، أعلى الزر)
  static const _layouts = [
    (card: 499.0, cardH: 65.0, dua: 510.5, counter: TawafTextBox(155, 588, 78), button: 642.0),
    (card: 499.0, cardH: 65.0, dua: 514.5, counter: TawafTextBox(154, 588, 81), button: 642.0),
    (card: 504.0, cardH: 65.0, dua: 516.5, counter: TawafTextBox(155, 593, 82), button: 647.0),
    (card: 499.0, cardH: 65.0, dua: 510.5, counter: TawafTextBox(154, 589, 80), button: 643.0),
    (card: 499.0, cardH: 65.0, dua: 513.5, counter: TawafTextBox(154, 593, 81), button: 647.0),
    (card: 501.0, cardH: 65.0, dua: 514.5, counter: TawafTextBox(154, 593, 81), button: 647.0),
    (card: 501.0, cardH: 59.0, dua: 511.5, counter: TawafTextBox(153, 593, 82), button: 647.0),
  ];

  // الحلقة لكل شوط (مقاسة من Figma): الأشواط 1-4 أكبر شوي بخط 14، و5-7 286 بخط 15 (السادس أوطى بـ 8)
  static const _rings = [
    (rect: Rect.fromLTWH(47, 166.8, 300, 300), stroke: 14.0),
    (rect: Rect.fromLTWH(47, 166.8, 300, 300), stroke: 14.0),
    (rect: Rect.fromLTWH(47, 166.8, 300, 300), stroke: 14.0),
    (rect: Rect.fromLTWH(47, 166.8, 300, 300), stroke: 14.0),
    (rect: Rect.fromLTWH(53, 176, 286, 285), stroke: 15.0),
    (rect: Rect.fromLTWH(53, 184, 286, 285), stroke: 15.0),
    (rect: Rect.fromLTWH(53, 176, 286, 285), stroke: 15.0),
  ];

  // مكان الرقم عن نص الدائرة (196,318.5) — بـ Figma مش بالنص بالظبط وبيختلف من شوط لشوط
  static const _digitOffsets = [Offset(1.25, 1.5), Offset(-5.5, 1), Offset(-6.75, -0.5), Offset(9, 0), Offset(-3.75, 2.5), Offset(-6.25, 3.25), Offset(-8, 1)];

  @override
  Widget build(BuildContext context) {
    final l = _layouts[round - 1];
    final ring = _rings[round - 1];
    final digitOffset = _digitOffsets[round - 1];
    final counter = TawafRoundsText.counter(round);
    return TawafPage(
      title: TawafRoundsText.title(),
      high: true,
      body: (c) {
        final word = c.style(14, FigmaWeight.semiBold, TawafColors.accent);
        final digit = c.style(14, FigmaWeight.semiBold, TawafColors.green);
        return [
          TawafParts.subtitle(c, TawafRoundsText.subtitle(), const TawafTextBox(89, 114, 285)),
          // الحلقة: خطها بنص حدود الدائرة (Figma: الصندوق بدون الخط)
          c.rect(
            left: ring.rect.left,
            top: ring.rect.top,
            width: ring.rect.width,
            height: ring.rect.height,
            child: IgnorePointer(child: TawafRing(round: round, stroke: c.s.x(ring.stroke))),
          ),
          c.text(
            TawafRoundsText.ringNumber(round),
            left: 53 + digitOffset.dx,
            top: 318.5 - 40,
            width: 286,
            height: 80,
            dy: digitOffset.dy,
            align: TextAlign.center,
            style: c.style(64, FigmaWeight.sfBold, TawafColors.green, lineHeight: null, letterSpacing: 0),
          ),
          TawafParts.card(c, Rect.fromLTWH(17, l.card, 360, l.cardH)),
          TawafParts.centered(
            c,
            TawafRoundsText.duas[round - 1](),
            TawafTextBox(17, l.dua, 359),
            TawafParts.cardStyle(c, size: round == 7 ? 14 : 13.5),
            maxHeight: l.card + l.cardH - 3 - l.dua,
          ),
          c.rect(
            left: AppLanguage.isArabic ? l.counter.left : 100,
            top: l.counter.top + 1,
            width: AppLanguage.isArabic ? l.counter.width : 193,
            height: 22,
            child: IgnorePointer(
              child: Center(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: counter.word, style: word),
                    TextSpan(text: counter.number, style: digit),
                    TextSpan(text: counter.of, style: word),
                    TextSpan(text: counter.total, style: digit),
                  ]),
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
          ),
          TawafParts.button(c, Rect.fromLTWH(17, l.button, 361, 50), TawafRoundsText.roundDone(), onDone),
        ];
      },
    );
  }
}
