import 'package:flutter/material.dart';

import '../../../../core/theme/figma_spaced_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_line.dart';
import '../l10n/assistant_text.dart';
import 'assistant_colors.dart';

// -------------------------------------------------------------
// كرت الترحيب ("Rectangle 123" — 361×106 #EEF2F2 radius 10 بظل Figma):
// الروبوت (نفس أيقونة كرت المساعد بالرئيسية) — "أهلًا فيك!..." — وسطرين تعريف بالمساعد
// -------------------------------------------------------------
class AssistantWelcomeCard extends StatelessWidget {
  final FigmaCanvas c;

  const AssistantWelcomeCard({super.key, required this.c});

  static const _robot = 'assets/images/home/ic_assistant.png';

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.box(left: 16, top: 142, width: 361, height: 106, color: AssistantColors.cardFill, radius: 10, hasShadow: true),
        // Group 28×29.82 (الصورة 28×30 بنفس المركز)
        c.image(_robot, left: 333, top: 157.91, width: 28, height: 30),
        // SF Compact 556 14 #1F3B2E
        c.line(AssistantText.hello(), left: 125, top: 162, width: 200, height: 22, style: c.style(14, FigmaWeight.semiBold, AssistantColors.green)),
        // SF Compact 457 14 #1F3B2E — سطرين بعرض 350 زي Figma
        c.rect(
          left: 21.5,
          top: 195 + FigmaCanvas.baselineFix,
          width: 350,
          height: 44,
          child: IgnorePointer(
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: FigmaSpacedText(
                AssistantText.intro(),
                style: c.style(14, FigmaWeight.sfRegular, AssistantColors.green),
                letterSpacing: c.s.x(-0.408),
                width: c.s.x(350),
                maxLines: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
