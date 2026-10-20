import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../tawaf/presentation/widgets/tawaf_page.dart';
import '../../../tawaf/presentation/widgets/tawaf_parts.dart';
import '../../../tawaf/presentation/widgets/tawaf_step_spec.dart';
import '../l10n/saee_steps_text.dart';

// -------------------------------------------------------------
// "الحمدلله، أتممت نسكك" — الشاشة الختامية للعمرة (Figma)
//   headline (244×22) + sub-headline (359×38) + illustration
//   + دعاء الختام (307×199) + زر "إنهاء الرحلة"
//
// مقاسات Figma (393×960 — أطول من العادة):
//   subtitle: TawafTextBox(21, 117, 353)
//   headline: left=16, top=171, 244×22 (semiBold green)
//   sub-headline: left=17, top=203, 359×38 (semiBold accent)
//   illustration: left=131, top=255, 130×130 — [GAP: assets/images/saee/complete.png]
//   دعاء: TawafTextBox(43, 399, 307), maxH=220
//   button: Rect.fromLTWH(17, 634, 361, 50)
// -------------------------------------------------------------
class SaeeCompleteScreen extends StatelessWidget {
  final VoidCallback onFinish;

  const SaeeCompleteScreen({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return TawafPage(
      title: SaeeStepsText.completeTitle(),
      frameHeight: 960,
      body: (c) => [
        TawafParts.subtitle(c, SaeeStepsText.completeSubtitle(), const TawafTextBox(21, 117, 353)),

        // headline
        c.text(
          SaeeStepsText.completeHeadline(),
          left: 16,
          top: 171,
          width: 244,
          height: 22,
          dy: 0,
          style: c.style(16, FigmaWeight.sfBold, TawafColors.green, lineHeight: null, letterSpacing: 0),
        ),

        // sub-headline
        c.text(
          SaeeStepsText.completeSubHeadline(),
          left: 17,
          top: 203,
          width: 359,
          height: 38,
          dy: 0,
          align: TextAlign.center,
          style: c.style(16, FigmaWeight.semiBold, TawafColors.accent, lineHeight: 1.5, letterSpacing: 0),
        ),

        // illustration — [GAP: assets/images/saee/complete.png]
        c.rect(
          left: 131,
          top: 255,
          width: 130,
          height: 130,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(c.s.x(12)),
            child: Image.asset(
              'assets/images/saee/complete.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: TawafColors.card,
                child: Center(child: Icon(Icons.mosque_rounded, color: TawafColors.accent, size: c.s.x(54))),
              ),
            ),
          ),
        ),

        // دعاء الختام
        TawafParts.centered(
          c,
          SaeeStepsText.completeDua(),
          const TawafTextBox(43, 399, 307),
          c.style(14, FigmaWeight.sfRegular, TawafColors.green, lineHeight: 1.6, letterSpacing: 0),
          maxHeight: 220,
        ),

        TawafParts.button(c, const Rect.fromLTWH(17, 634, 361, 50), SaeeStepsText.completeButton(), onFinish),
      ],
    );
  }
}
