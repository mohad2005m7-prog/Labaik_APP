import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_page.dart';
import '../controllers/learning_controller.dart';
import '../l10n/learning_common_text.dart';
import '../widgets/learning_card_view.dart';
import '../widgets/learning_stages.dart';

// -------------------------------------------------------------
// شاشة مرحلة تعلم ("تعلم احرام" بـ Figma — المراحل الأربعة نفس التصميم، LearningStages فيه أرقام كل وحدة)
// الهيدر (العنوان + سهم الرجوع) ← العنوان الفرعي ← الشريحة وتحتها سطر ← الكروت ← الأزرار الذهبية (نوافذ)
// ← "التالي" (المرحلة اللي بعدها) أو "تمت العمرة" ← "الرئيسية"
// الإطارات أطول من 852 فالشاشة بتتمرر بمقدار الفرق
// -------------------------------------------------------------
class LearningStageScreen extends StatelessWidget {
  final int index;

  const LearningStageScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final spec = LearningStages.all[index];
    final home = spec.home;
    return FigmaPage(
      title: spec.title(),
      frameHeight: spec.frameHeight,
      body: (c) => [
        LearningCardView.line(c, spec.subtitle, strong: true),
        ...LearningCardView.chip(c, spec.topChip),
        LearningCardView.line(c, spec.note, strong: false),
        for (final card in spec.cards) ...LearningCardView.card(c, card),
        for (final link in spec.links) ...LearningCardView.link(c, link, () => LearningController.showPopup(context, link.popup)),
        c.button(spec.nextLabel(), left: spec.next.left, top: spec.next.top, width: spec.next.width, height: spec.next.height, figmaSpacing: true, onTap: () => LearningController.next(context, index)),
        if (home != null)
          c.button(
            LearningCommonText.home(),
            left: home.left,
            top: home.top,
            width: home.width,
            height: home.height,
            outlined: true,
            borderColor: Colors.black,
            labelWeight: FigmaWeight.semiBold,
            figmaSpacing: true,
            onTap: () => LearningController.home(context),
          ),
      ],
    );
  }
}
