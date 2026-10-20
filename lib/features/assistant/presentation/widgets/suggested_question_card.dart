import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_chevron.dart';
import '../../../../core/widgets/figma_line.dart';
import 'assistant_colors.dart';
import 'chat_round_icon.dart';

// -------------------------------------------------------------
// سؤال مقترح (Rectangle 122/124/125/126 — 361×50 #EEF2F2 radius 10 بظل Figma) كل 74 من y302:
// فقاعة "Hicon" 24×24 — السؤال (SF Compact 457 14 #1F3B2E) — "chevron.left" 10×20 بآخر الكرت
// -------------------------------------------------------------
class SuggestedQuestionCard extends StatelessWidget {
  final FigmaCanvas c;
  final int index;
  final String question;
  final VoidCallback onTap;

  const SuggestedQuestionCard({super.key, required this.c, required this.index, required this.question, required this.onTap});

  static const _firstTop = 302.0;
  static const _gap = 74.0;

  @override
  Widget build(BuildContext context) {
    // كانفس الكرت: أرقام Figma للكرت الأول
    final k = c.at(c.originTop - _gap * index);
    final s = c.s;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        k.box(left: 16, top: _firstTop, width: 361, height: 50, color: AssistantColors.cardFill, radius: 10, hasShadow: true),
        k.rect(left: 347, top: 314, width: 24, height: 24, child: Center(child: ChatRoundIcon(size: s.x(24), color: AssistantColors.green))),
        k.line(question, left: 56, top: 316, width: 286, height: 22, style: k.style(14, FigmaWeight.sfRegular, AssistantColors.green)),
        // صندوق خط السهم (مركز الخط) 8.4×18.4 بخط 1.6 = صندوق Figma 10×20
        k.rect(
          left: 37,
          top: 317,
          width: 10,
          height: 20,
          child: Center(child: FigmaChevron(width: s.x(8.4), height: s.x(18.4), stroke: s.x(1.6), color: AssistantColors.green, pointsToEnd: true)),
        ),
        k.tapArea(left: 16, top: _firstTop, width: 361, height: 50, onTap: onTap),
      ],
    );
  }
}
