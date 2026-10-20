import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../l10n/tawaf_rounds_text.dart';
import '../widgets/tawaf_page.dart';
import '../widgets/tawaf_parts.dart';
import '../widgets/tawaf_step_spec.dart';

// -------------------------------------------------------------
// "أتممت الطواف" (Figma 256:5837): "لقد أكملت 7 أشواط" (SF Compact 790 32) ← ✓ (90×90) ← سطرين ← متابعة
// -------------------------------------------------------------
class TawafDoneScreen extends StatelessWidget {
  final VoidCallback onNext;

  const TawafDoneScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return TawafPage(
      title: TawafRoundsText.doneTitle(),
      high: true,
      body: (c) => [
        TawafParts.subtitle(c, TawafRoundsText.doneSubtitle(), const TawafTextBox(21, 117, 353)),
        // صندوق Figma 266×38 (Auto width) طرفه اليمين عند x338
        c.text(
          TawafRoundsText.doneHeadline(),
          left: 16,
          top: 171,
          width: 322,
          height: 38,
          dy: 0,
          style: c.style(32, FigmaWeight.sfBold, TawafColors.green, lineHeight: null, letterSpacing: 0),
        ),
        c.image('assets/images/tawaf/ic_done.png', left: 160, top: 241, width: 90, height: 90),
        TawafParts.centered(c, TawafRoundsText.doneBody(), const TawafTextBox(17, 351, 360), c.style(16, FigmaWeight.semiBold, TawafColors.accent), maxHeight: 72),
        TawafParts.button(c, const Rect.fromLTWH(17, 429, 361, 50), TawafRoundsText.doneButton(), onNext),
      ],
    );
  }
}
