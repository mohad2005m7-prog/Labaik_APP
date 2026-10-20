import 'package:flutter/material.dart';

import '../../../../core/l10n/tx.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../field_mode/presentation/widgets/back_title_header.dart';
import '../../domain/entities/supervisor_group.dart';
import '../controllers/supervisor_controller.dart';
import '../l10n/group_details_text.dart';
import '../widgets/supervisor_colors.dart';
import '../widgets/supervisor_page.dart';
import '../widgets/supervisor_widgets.dart';

// -------------------------------------------------------------
// تفاصيل المجموعة — مطابقة لـ Figma "تفاصيل المجموعة" (234:2565) + هيدرها "المجموعة الأولى" (234:3609)
// كرتين 368×76: قائمة الأعضاء → أعضاء المجموعة | برنامج الرحلة → برنامج الرحلة
// -------------------------------------------------------------
class GroupDetailsScreen extends StatelessWidget {
  final SupervisorGroup group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return SupervisorPage(
      builder: (c) => [
        ..._card(c, top: 117, icon: 'tab_group', iconRect: const Rect.fromLTWH(341, 143, 24, 24), title: GroupDetailsText.membersList, subtitle: GroupDetailsText.membersListDescription, onTap: () => SupervisorController.openMembers(context, group)),
        ..._card(c, top: 201, icon: 'ic_calendar_grid', iconRect: const Rect.fromLTWH(340, 226, 26, 26), title: GroupDetailsText.tripProgram, subtitle: GroupDetailsText.tripProgramDescription, onTap: () => SupervisorController.openProgram(context, group)),
        // الهيدر (Group 38): سهم الرجوع واسم المجموعة — SF Compact Bold 20 طرفه x380
        PositionedDirectional(start: 0, end: 0, top: 0, child: BackTitleHeader(scale: c.s, title: group.name)),
      ],
    );
  }

  List<Widget> _card(FigmaCanvas c, {required double top, required String icon, required Rect iconRect, required Tx title, required Tx subtitle, required VoidCallback onTap}) {
    return [
      c.box(left: 13, top: top, width: 368, height: 76, color: SupColors.cardFill, radius: 10, hasShadow: true),
      c.image('$supAssets/$icon.png', left: iconRect.left, top: iconRect.top, width: iconRect.width, height: iconRect.height),
      // SF Compact Bold 16 / Regular 14 — طرفهم x333
      c.text(title(), left: 150, top: top + 15, width: 183, height: 19, style: supText(c, 16, FigmaWeight.sfBold, SupColors.green)),
      c.text(subtitle(), left: 120, top: top + 42, width: 213, height: 17, style: supText(c, 14, FigmaWeight.sfRegular, SupColors.green)),
      ...supChevron(c, left: 29, top: top + 26),
      c.tapArea(left: 13, top: top, width: 368, height: 76, onTap: onTap),
    ];
  }
}
