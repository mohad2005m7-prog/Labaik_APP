import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../domain/entities/supervisor_group.dart';
import '../controllers/supervisor_controller.dart';
import '../cubits/supervisor_content_cubits.dart';
import '../l10n/sup_groups_text.dart';
import '../widgets/sup_list_status.dart';
import '../widgets/supervisor_colors.dart';
import '../widgets/supervisor_page.dart';
import '../widgets/supervisor_widgets.dart';

// -------------------------------------------------------------
// المجموعات — مطابقة لـ Figma "المجموعات" (234:2523)
// كروت 368×76 كل 84 (#4C7A75 10% — radius 10 — ظل) واسم المجموعة SF Compact Bold 20 بالنص
// الكرت → تفاصيل المجموعة | البحث بيفلتر بالاسم
// -------------------------------------------------------------
class SupervisorGroupsScreen extends StatelessWidget {
  const SupervisorGroupsScreen({super.key});

  static const _listTop = 164.0;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SupervisorGroupsCubit>();
    return SupervisorPage(
      inShell: true,
      builder: (c) => [
        c.text(SupGroupsText.title(), left: 96, top: 59, width: 201, height: 29, align: TextAlign.center, style: supText(c, 24, FigmaWeight.semiBold, SupColors.green)),
        c.rect(left: 24, top: 104, width: 345, height: 36, child: SupSearchField(s: c.s, hint: SupGroupsText.search(), onChanged: cubit.search)),
        c.rect(
          left: 0,
          top: _listTop,
          width: 393,
          height: 769 - _listTop,
          child: BlocBuilder<SupervisorGroupsCubit, ListState<SupervisorGroup>>(
            builder: (context, state) {
              final groups = state.visible;
              if (groups.isEmpty) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: SupListStatus(loaded: state.loaded, failed: state.failed, isEmpty: true, empty: SupListStatusText.noGroups, onRetry: context.read<SupervisorGroupsCubit>().load),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.zero,
                physics: supScrollPhysics,
                // ظل الكرت بيطلع شوي تحته
                clipBehavior: Clip.none,
                itemCount: groups.length,
                itemExtent: c.s.y(84),
                itemBuilder: (context, i) => Stack(clipBehavior: Clip.none, children: _card(context, c.at(_listTop), groups[i])),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _card(BuildContext context, FigmaCanvas c, SupervisorGroup g) {
    const top = _listTop;
    return [
      c.box(left: 13, top: top, width: 368, height: 76, color: SupColors.cardFill, radius: 10, hasShadow: true),
      c.text(g.name, left: 13, top: top + 26, width: 368, height: 24, align: TextAlign.center, style: supText(c, 20, FigmaWeight.sfBold, SupColors.green)),
      c.tapArea(left: 13, top: top, width: 368, height: 76, onTap: () => SupervisorController.openGroup(context, g)),
    ];
  }
}
