import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../domain/entities/group_preview.dart';
import '../controllers/group_controller.dart';
import '../l10n/group_join_text.dart';

// -------------------------------------------------------------
// "تأكد من مجموعتك" (Figma):
//   وصف (15,106) — كرت 360×187 (15,149) #4C7A75 10% بظل
//   شارة اسم الحملة 132×36 (236.5,166) #4C7A75 78% — 3 أسطر يمين x359.5 (225 / 262 / 300)
//   الانضمام إلى المجموعة (17,377)
// -------------------------------------------------------------
class GroupConfirmScreen extends StatelessWidget {
  final GroupPreview group;

  const GroupConfirmScreen({super.key, required this.group});

  static const _accent = Color(0xFF4C7A75);

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: GroupJoinText.confirmTitle(),
      titleRight: 348.5,
      chevronLeft: 367,
      headerDy: 2,
      titleSize: 24,
      body: (c) {
        final line = c.style(16, FigmaWeight.semiBold, Colors.black, lineHeight: null, letterSpacing: 0);
        return [
          c.text(GroupJoinText.confirmDescription(), left: 15, top: 106, width: 363, height: 22, style: c.style(14, FigmaWeight.sfRegular, Colors.black)),
          // اللون شفاف 10% فوق الأبيض — بنحسبه معتم عشان الظل ما يبيّن من تحته ويغمّق الكرت
          c.box(left: 16, top: 149, width: 360, height: 187, color: Color.alphaBlend(_accent.withValues(alpha: 0.10), Colors.white), radius: 10, hasShadow: true),
          c.box(left: 236.5, top: 166, width: 132, height: 36, color: _accent.withValues(alpha: 0.78), radius: 8),
          c.text(group.name, left: 236.5, top: 173, width: 132, height: 22, align: TextAlign.center, style: c.style(16, FigmaWeight.semiBold, Colors.white, lineHeight: null, letterSpacing: 0)),
          c.text(group.supervisor == null ? GroupJoinText.noSupervisor() : GroupJoinText.supervisor(group.supervisor!), left: 30, top: 225, width: 329.5, height: 24, style: line),
          c.text(GroupJoinText.members(group.memberCount), left: 30, top: 262, width: 329.5, height: 24, style: line),
          // تاريخ الرحلة (سطر 300) — من tripDate بالرد (مجموعة بلا رحلة: ما بيطلع)
          if (group.tripDate != null) c.text(GroupJoinText.tripDate(group.tripDate!), left: 30, top: 300, width: 329.5, height: 24, style: line),
          c.button(GroupJoinText.join(), left: 17, top: 377, figmaSpacing: true, onTap: () => GroupController.joinGroup(context, group)),
        ];
      },
    );
  }
}
