import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../tawaf/presentation/widgets/tawaf_page.dart';
import '../../../tawaf/presentation/widgets/tawaf_parts.dart';
import '../../../tawaf/presentation/widgets/tawaf_step_spec.dart';
import '../l10n/saee_rounds_text.dart';

// -------------------------------------------------------------
// "أتممت السعي" (Figma — مشابه لـ TawafDoneScreen مع إضافة "الخطوة التالية"):
//   headline (266×38) ← ✓ (90×90) ← سطرين body ← "الخطوة التالية" ← متابعة
//
// مقاسات Figma (393×852):
//   subtitle: TawafTextBox(21, 117, 353)
//   headline: left=16, top=171, 266×38
//   checkmark: left=160, top=241, 90×90
//   body: TawafTextBox(17, 351, 360), maxH=72
//   nextStep: left=17, top=435, 360×44
//   button: Rect.fromLTWH(17, 491, 361, 50)
// -------------------------------------------------------------
class SaeeDoneScreen extends StatelessWidget {
  final VoidCallback onNext;

  const SaeeDoneScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return TawafPage(
      title: SaeeRoundsText.doneTitle(),
      high: true,
      body: (c) => [
        TawafParts.subtitle(c, SaeeRoundsText.doneSubtitle(), const TawafTextBox(21, 117, 353)),
        c.text(
          SaeeRoundsText.doneHeadline(),
          left: 16,
          top: 171,
          width: 266,
          height: 38,
          dy: 0,
          style: c.style(32, FigmaWeight.sfBold, TawafColors.green, lineHeight: null, letterSpacing: 0),
        ),
        c.image('assets/images/tawaf/ic_done.png', left: 160, top: 241, width: 90, height: 90),
        TawafParts.centered(c, SaeeRoundsText.doneBody(), const TawafTextBox(17, 351, 360), c.style(16, FigmaWeight.semiBold, TawafColors.accent), maxHeight: 72),
        // "الخطوة التالية: التحلل" — عنصر إضافي غير موجود في شاشة الطواف
        c.text(
          SaeeRoundsText.doneNextStep(),
          left: 17,
          top: 435,
          width: 360,
          height: 44,
          align: TextAlign.center,
          style: c.style(15, FigmaWeight.semiBold, TawafColors.green, lineHeight: 1.5, letterSpacing: 0),
        ),
        TawafParts.button(c, const Rect.fromLTWH(17, 491, 361, 50), SaeeRoundsText.doneButton(), onNext),
      ],
    );
  }
}
