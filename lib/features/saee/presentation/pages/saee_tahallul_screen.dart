import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_lines.dart';
import '../../../tawaf/presentation/widgets/tawaf_page.dart';
import '../../../tawaf/presentation/widgets/tawaf_parts.dart';
import '../../../tawaf/presentation/widgets/tawaf_step_spec.dart';
import '../l10n/saee_steps_text.dart';

// -------------------------------------------------------------
// "أتمم تحللك من العمرة" — مطابقة لـ Figma 256:6421 (393×852)
//   subtitle: TawafTextBox(28, 117, 350) سطرين
//   كرت للرجل: 16,193 — 360×116 | العنوان طرفه x360 (y209) — "للرجل:" أعرض | النص 83..360 (y241) سطرين
//   كرت للمرأة: 16,334 — 360×116 | العنوان (y349) | النص (y381)
//   ملاحظة: 100,481 — 188×22 بالنص | زر: 16,535 — 361×50
// -------------------------------------------------------------
class SaeeTahallulScreen extends StatelessWidget {
  final VoidCallback onNext;

  const SaeeTahallulScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return TawafPage(
      title: SaeeStepsText.tahallulTitle(),
      body: (c) => [
        TawafParts.subtitle(c, SaeeStepsText.tahallulSubtitle(), const TawafTextBox(28, 117, 350)),
        ..._card(c, 193, SaeeStepsText.tahallulMenHeader(), SaeeStepsText.tahallulMenBody()),
        ..._card(c, 334, SaeeStepsText.tahallulWomenHeader(), SaeeStepsText.tahallulWomenBody()),
        TawafParts.centered(c, SaeeStepsText.tahallulNote(), const TawafTextBox(100, 481, 188), c.style(14, FigmaWeight.semiBold, TawafColors.accent)),
        TawafParts.button(c, const Rect.fromLTWH(16, 535, 361, 50), SaeeStepsText.tahallulButton(), onNext),
      ],
    );
  }

  // كرت 360×116: العنوان ("**للرجل:**" أعرض) طرفه x360، وتحته النص سطرين (19 لكل سطر)
  static List<Widget> _card(FigmaCanvas c, double top, String header, String body) {
    final green = TawafColors.green;
    return [
      TawafParts.card(c, Rect.fromLTWH(16, top, 360, 116)),
      FigmaLines.build(c, header, left: 120, top: top + 16, width: 240, lineHeight: 24, style: c.style(18, FigmaWeight.sfRegular, green, lineHeight: 24), boldStyle: c.style(20, FigmaWeight.sfBold, green, lineHeight: 24)),
      FigmaLines.build(c, body, left: 83, top: top + 48, width: 277, lineHeight: 19, style: c.style(15, FigmaWeight.sfRegular, green, lineHeight: 19)),
    ];
  }
}
