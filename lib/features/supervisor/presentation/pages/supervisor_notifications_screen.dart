import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../domain/entities/supervisor_inbox.dart';
import '../cubits/supervisor_content_cubits.dart';
import '../l10n/sup_notifications_text.dart';
import '../widgets/sup_list_status.dart';
import '../widgets/supervisor_colors.dart';
import '../widgets/supervisor_page.dart';
import '../widgets/supervisor_widgets.dart';

// -------------------------------------------------------------
// إشعارات المشرف — مطابقة لـ Figma "الاشعارات" (234:3491)
// عنوان وقت لكل مجموعة (اليوم، الأمس 9:40) وتحته كروت 345×85 كل 93
// الإشعار المهم: #4C7A75 25% مع ظل ونص وجرس أسود — الباقي 10% بدون ظل وأخضر
// -------------------------------------------------------------
class SupervisorNotificationsScreen extends StatelessWidget {
  const SupervisorNotificationsScreen({super.key});

  static const _listTop = 101.0;

  @override
  Widget build(BuildContext context) {
    return SupervisorPage(
      builder: (c) => [
        // Poppins SemiBold 24 — بالنص
        c.text(SupNotificationsText.title(), left: 96, top: 59, width: 201, height: 36, align: TextAlign.center, style: c.style(24, FigmaWeight.semiBold, SupColors.green, lineHeight: null, letterSpacing: 0)),
        c.rect(
          left: 0,
          top: _listTop,
          width: 393,
          height: 818 - _listTop,
          child: BlocBuilder<SupervisorNotificationsCubit, ListState<NotificationSection>>(
            builder: (context, state) {
              if (state.items.isEmpty) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: SupListStatus(loaded: state.loaded, failed: state.failed, isEmpty: true, empty: SupListStatusText.noNotifications, onRetry: context.read<SupervisorNotificationsCubit>().load),
                );
              }
              final items = <Widget>[];
              var y = 110.0;
              for (final section in state.items) {
                items.add(_sectionLabel(c.at(_listTop), section.label, y, first: y == 110));
                y += 25;
                for (final n in section.items) {
                  items.addAll(_card(c.at(_listTop), n, y));
                  y += 93;
                }
                y += 4;
              }
              return SingleChildScrollView(
                physics: supScrollPhysics,
                child: SizedBox(height: c.s.y(y - _listTop), child: Stack(clipBehavior: Clip.none, children: items)),
              );
            },
          ),
        ),
        ...supBackArrow(c, context, left: 10, top: 68),
      ],
    );
  }

  // SF Compact 11 — line height 13 — رمادي iOS — بالنص ("اليوم" Regular و "الأمس 9:40" Medium)
  Widget _sectionLabel(FigmaCanvas c, String label, double top, {required bool first}) {
    return c.text(label, left: 63, top: top, width: 267, height: 13, align: TextAlign.center, dy: 0, style: c.style(11, first ? FigmaWeight.sfRegular : FigmaWeight.semiBold, SupColors.secondaryLabel, lineHeight: 13, letterSpacing: 0.06));
  }

  List<Widget> _card(FigmaCanvas c, SupervisorNotification n, double top) {
    final color = n.important ? Colors.black : SupColors.green;
    return [
      c.box(left: 24, top: top, width: 345, height: 85, color: n.important ? SupColors.cardFillStrong : SupColors.cardFill, radius: 10, hasShadow: n.important),
      c.image('$supAssets/${n.important ? 'ic_bell_black' : 'ic_bell_green'}.png', left: 334, top: top + 8, width: 24, height: 24),
      // SF Compact Semibold 16 — طرفه x326
      c.text(n.title, left: 40, top: top + 11, width: 286, height: 19, dy: 0, style: supText(c, 16, FigmaWeight.sfSemibold, color)),
      // SF Compact Regular 14 — طرفه x353
      c.text(n.body, left: 40, top: top + 40, width: 313, height: 17, dy: 0, style: supText(c, 14, FigmaWeight.sfRegular, color)),
    ];
  }
}
