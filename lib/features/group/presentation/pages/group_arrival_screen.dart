import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../../family/presentation/widgets/family_button.dart';
import '../../../family/presentation/widgets/family_colors.dart';
import '../../../help_center/presentation/widgets/help_text.dart';
import '../controllers/group_controller.dart';
import '../l10n/group_arrival_text.dart';

// -------------------------------------------------------------
// "أكّد وصولك" (Figma 165:5962): الأيقونة (شخص بعلامة سؤال 118×118 من 138,122)
// "هل وصلت نقطة التجمع" + الشرح (15,273 362×72) — نعم، وصلت (15,406) — العودة إلى الملاحة (15,477 بحد أسود)
// -------------------------------------------------------------
class GroupArrivalScreen extends StatefulWidget {
  const GroupArrivalScreen({super.key});

  @override
  State<GroupArrivalScreen> createState() => _GroupArrivalScreenState();
}

class _GroupArrivalScreenState extends State<GroupArrivalScreen> {
  bool _sending = false;

  Future<void> _confirm() async {
    if (_sending) return;
    setState(() => _sending = true);
    await GroupController.confirmArrival(context);
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: GroupArrivalText.title(),
      titleRight: 348.5,
      chevronLeft: 367,
      headerDy: 0,
      titleSize: 24,
      body: (c) => [
        // الأيقونة مقصوصة من Figma بهامش 2 من كل جهة (136,120 122×122)
        c.image('assets/images/group/ic_confirm_person.png', left: 136, top: 120, width: 122, height: 122, color: Colors.black),
        c.text(GroupArrivalText.question(), left: 15, top: 270, width: 362, height: 36, dy: 0, align: TextAlign.center, style: c.style(24, FigmaWeight.sfBold, FamilyColors.green, lineHeight: null, letterSpacing: 0)),
        HelpText.paragraph(c, GroupArrivalText.body(), left: 15, top: 323, width: 362, lines: 1, align: TextAlign.center, style: c.style(16.4, FigmaWeight.sfRegular, Colors.black)),
        familyButton(c, GroupArrivalText.yes(), left: 15, top: 406, width: 362, busy: _sending, onTap: _confirm),
        familyButton(c, GroupArrivalText.backToNavigation(), left: 15, top: 477, width: 362, outlined: true, borderColor: Colors.black, onTap: () => GroupController.backToNavigation(context)),
      ],
    );
  }
}
