import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../tawaf/presentation/widgets/tawaf_page.dart';
import '../../../tawaf/presentation/widgets/tawaf_parts.dart';
import '../../../tawaf/presentation/widgets/tawaf_step_spec.dart';
import '../l10n/saee_steps_text.dart';

// -------------------------------------------------------------
// "الحمدلله، أتممت نسكك" — الشاشة الختامية للعمرة (Figma 256:6451 — 393×852)
//   subtitle: TawafTextBox(130, 117, 244)
//   headline "الحمدلله على تمام النعمة": 15,179 — 359×38 (بالنص)
//   sub-headline: 17,233 — 360×22 (بالنص)
//   الرسمة: 31,271 — 307×199 (assets/images/saee/complete.png — لحد ما تنضاف بتطلع أيقونة)
//   الدعاء: 17,494 — 360×110 (فقرة وحدة بالنص)
//   الزر: 17,636 — 361×50
// -------------------------------------------------------------
class SaeeCompleteScreen extends StatelessWidget {
  final VoidCallback onFinish;

  const SaeeCompleteScreen({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return TawafPage(
      title: SaeeStepsText.completeTitle(),
      body: (c) => [
        TawafParts.subtitle(c, SaeeStepsText.completeSubtitle(), const TawafTextBox(130, 117, 244)),

        c.text(
          SaeeStepsText.completeHeadline(),
          left: 15,
          top: 179,
          width: 359,
          height: 38,
          dy: 0,
          align: TextAlign.center,
          style: c.style(24, FigmaWeight.sfBold, TawafColors.green, lineHeight: null, letterSpacing: 0),
        ),

        c.text(
          SaeeStepsText.completeSubHeadline(),
          left: 17,
          top: 233,
          width: 360,
          height: 22,
          dy: 0,
          align: TextAlign.center,
          style: c.style(14, FigmaWeight.semiBold, TawafColors.accent, lineHeight: null, letterSpacing: 0),
        ),

        c.rect(
          left: 31,
          top: 271,
          width: 307,
          height: 199,
          child: Image.asset(
            'assets/images/saee/complete.png',
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Center(child: Icon(Icons.mosque_rounded, color: TawafColors.accent, size: c.s.x(72))),
          ),
        ),

        TawafParts.centered(
          c,
          SaeeStepsText.completeDua(),
          const TawafTextBox(17, 494, 360),
          c.style(13, FigmaWeight.sfRegular, TawafColors.green, lineHeight: 22, letterSpacing: 0),
          maxHeight: 130,
        ),

        TawafParts.button(c, const Rect.fromLTWH(17, 636, 361, 50), SaeeStepsText.completeButton(), onFinish),
      ],
    );
  }
}
