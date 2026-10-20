import 'package:flutter/material.dart';

import '../../../../core/l10n/app_language.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../tawaf/presentation/widgets/tawaf_page.dart';
import '../../../tawaf/presentation/widgets/tawaf_parts.dart';
import '../../../tawaf/presentation/widgets/tawaf_step_spec.dart';
import '../l10n/saee_rounds_text.dart';
import '../widgets/saee_mountains.dart';

// -------------------------------------------------------------
// "أنت الآن في السعي" — شوط [round] من 7 (Figma):
// الجبلان (الصفا يمين، المروة يسار) + سهم الاتجاه + 7 دشز تقدم
//   ← رقم الشوط الكبير ← توجيه الشوط ← "الشوط n من ٧" ← تم الشوط
//
// مقاسات Figma (393×852):
//   subtitle: TawafTextBox(89, 114, 285)
//   الصفا: left=220, top=185, 120×120
//   المروة: left=51, top=183, 122×122
//   سهم: left≈187.5, top≈232, 18×24
//   تسمية الصفا: left=254, top=309, 53×24
//   تسمية المروة: left=88, top=309, 49×24
//   track: 7 دشات (38,39,40,37,40,38,38 px) × 4px — مركزة في 294px من left=49.5
//   رقم كبير: left=17, top=367, 359×76 (64pt)
//   توجيه الشوط: left=17, top=459, 359×22 (16pt)
//   counter: TawafTextBox(154, 491, 81) (عربي)
//   button: Rect.fromLTWH(17, 553, 361, 50)
// -------------------------------------------------------------
class SaeeRoundScreen extends StatelessWidget {
  final int round;
  final VoidCallback onDone;

  const SaeeRoundScreen({super.key, required this.round, required this.onDone});

  // عرض كل داشة من 7 (مجموع 270px + 6×4=24px فاصل = 294px مركزة)
  static const _trackWidths = [38.0, 39.0, 40.0, 37.0, 40.0, 38.0, 38.0];
  static const _trackLeft = 49.5;
  static const _trackTop = 341.0;
  static const _trackH = 4.0;
  static const _trackGap = 4.0;

  @override
  Widget build(BuildContext context) {
    final goingToMarwa = SaeeRoundsText.goingToMarwa(round);
    final counter = SaeeRoundsText.counter(round);
    return TawafPage(
      title: SaeeRoundsText.title(),
      high: true,
      body: (c) {
        final word = c.style(14, FigmaWeight.semiBold, TawafColors.accent);
        final digit = c.style(14, FigmaWeight.semiBold, TawafColors.green);
        return [
          TawafParts.subtitle(c, SaeeRoundsText.subtitle(), const TawafTextBox(89, 114, 285)),

          // الصفا (يمين — left كبير في FigmaCanvas = يمين في RTL)
          c.rect(
            left: 220,
            top: 185,
            width: 120,
            height: 120,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: SaeeMountainPainter(isSafa: true, color: TawafColors.green),
              ),
            ),
          ),

          // المروة (يسار — left صغير في FigmaCanvas = يسار في RTL)
          c.rect(
            left: 51,
            top: 183,
            width: 122,
            height: 122,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: SaeeMountainPainter(isSafa: false, color: TawafColors.green),
              ),
            ),
          ),

          // سهم الاتجاه — يتغير كل شوط (فردي ← المروة، زوجي ← الصفا)
          c.rect(
            left: 187.5,
            top: 232,
            width: 18,
            height: 24,
            child: IgnorePointer(
              child: Center(
                child: Icon(
                  goingToMarwa ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded,
                  color: TawafColors.accent,
                  size: c.s.x(16),
                ),
              ),
            ),
          ),

          // تسمية الصفا
          c.text(
            AppLanguage.isArabic ? 'الصفا' : 'Safa',
            left: 254,
            top: 309,
            width: 53,
            height: 24,
            align: TextAlign.center,
            style: c.style(14, FigmaWeight.semiBold, TawafColors.green, lineHeight: null, letterSpacing: 0),
          ),

          // تسمية المروة
          c.text(
            AppLanguage.isArabic ? 'المروة' : 'Marwa',
            left: 88,
            top: 309,
            width: 49,
            height: 24,
            align: TextAlign.center,
            style: c.style(14, FigmaWeight.semiBold, TawafColors.green, lineHeight: null, letterSpacing: 0),
          ),

          // شريط التقدم (7 دشز)
          c.rect(
            left: _trackLeft,
            top: _trackTop,
            width: _trackWidths.fold(0.0, (a, b) => a + b) + 6 * _trackGap,
            height: _trackH,
            child: IgnorePointer(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < 7; i++) ...[
                    if (i > 0) SizedBox(width: c.s.x(_trackGap)),
                    Container(
                      width: c.s.x(_trackWidths[i]),
                      height: c.s.x(_trackH),
                      decoration: BoxDecoration(
                        color: i < round ? TawafColors.green : const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(c.s.x(2)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // رقم الشوط الكبير
          c.text(
            SaeeRoundsText.roundNumber(round),
            left: 17,
            top: 367,
            width: 359,
            height: 76,
            dy: 0,
            align: TextAlign.center,
            style: c.style(64, FigmaWeight.sfBold, TawafColors.green, lineHeight: null, letterSpacing: 0),
          ),

          // كرت توجيه الشوط (كرت رمادي + نص داخله)
          TawafParts.card(c, const Rect.fromLTWH(17, 443, 359, 46)),
          c.text(
            (goingToMarwa ? SaeeRoundsText.instrToMarwa : SaeeRoundsText.instrToSafa)(),
            left: 17,
            top: 455,
            width: 359,
            height: 22,
            align: TextAlign.center,
            style: c.style(14, FigmaWeight.semiBold, TawafColors.accent, lineHeight: null, letterSpacing: 0),
          ),

          // "الشوط n من ٧"
          c.rect(
            left: AppLanguage.isArabic ? 154 : 100,
            top: 492,
            width: AppLanguage.isArabic ? 81 : 193,
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

          TawafParts.button(c, const Rect.fromLTWH(17, 553, 361, 50), (goingToMarwa ? SaeeRoundsText.buttonToMarwa : SaeeRoundsText.buttonToSafa)(), onDone),
        ];
      },
    );
  }
}
