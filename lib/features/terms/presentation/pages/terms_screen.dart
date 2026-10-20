import 'package:flutter/material.dart';

import '../../../../core/widgets/figma_page.dart';
import '../l10n/terms_text.dart';
import '../widgets/terms_card.dart';
import '../widgets/terms_sections.dart';
import '../widgets/terms_tabs.dart';

// -------------------------------------------------------------
// الشروط والأحكام والسياسات (Figma 112:3451 — إطار 948 فبتتمرر 96)
// التبويبات فوق (بتنسحب أفقياً): الشروط والأحكام / سياسة الخصوصية / سياسة الاسترجاع
// وتحتها كرت لكل قسم — كرت التبويب المختار حدّه أخضر كامل، والضغط على تبويب بيختاره وبيمرر لكرته
// -------------------------------------------------------------
class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  static const _frameHeight = 948.0;

  final _cardKeys = [for (final _ in TermsSection.all) GlobalKey()];
  var _selected = 0;

  void _select(int index) {
    setState(() => _selected = index);
    final card = _cardKeys[index].currentContext;
    if (card == null) return;
    // الكرت بيبين كله (لو آخره تحت الشاشة بيطلع، ولو مبين ما في حركة)
    Scrollable.ensureVisible(card, duration: const Duration(milliseconds: 300), curve: Curves.easeOut, alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd);
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: TermsText.title(),
      titleRight: 351,
      chevronLeft: 367.75,
      headerDy: 2,
      frameHeight: _frameHeight,
      body: (c) => [
        TermsTabs(c: c, labels: [for (final section in TermsSection.all) section.tab()], selected: _selected, onSelect: _select),
        for (final (i, section) in TermsSection.all.indexed) ...TermsCard.build(c, section, selected: i == _selected, cardKey: _cardKeys[i]),
      ],
    );
  }
}
