import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/api_error_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../family/presentation/widgets/family_colors.dart';
import '../../../family/presentation/widgets/family_member_card.dart';
import '../../../family/presentation/widgets/family_scroll_indicator.dart';
import '../../../family/presentation/widgets/family_search_field.dart';
import '../../../pilgrim_tabs/presentation/controllers/pilgrim_tabs_controller.dart';
import '../../../pilgrim_tabs/presentation/widgets/pilgrim_tab_bar.dart';
import '../controllers/group_controller.dart';
import '../cubits/group_members_cubit.dart';
import '../l10n/group_members_text.dart';

// -------------------------------------------------------------
// "أفراد مجموعتي" (Figma 111:5507 — إطار 393×884 فبيتوسّع الشاشة كله بنفس نسبه) — تبويب "الأفراد":
// العنوان (SF Compact 790 24) — "ابقَ على تواصل مع أفراد مجموعتك أثناء الرحلة." — البحث (19,149 345×48)
// الأفراد (المشرف أول) من y220 كل 103.3 — شريط التمرير (371.5 من y167 لـ y621)
// رؤية المجموعة على الخريطة (16,650) — عرض نقطة التجمع (17,706) — شريط التنقل من y784
// -------------------------------------------------------------
class GroupMembersScreen extends StatefulWidget {
  const GroupMembersScreen({super.key});

  static const frameHeight = 884.0;

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  static const _listTop = 205.0;
  static const _listBottom = 621.0;
  static const _firstCard = 220.0;
  static const _pitch = 103.3;

  final _metrics = ValueNotifier<ScrollMetrics?>(null);

  @override
  void dispose() {
    _metrics.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.forFrame(context, frameHeight: GroupMembersScreen.frameHeight);
    final c = FigmaCanvas(s);
    final cubit = context.read<GroupMembersCubit>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              height: s.y(GroupMembersScreen.frameHeight - 93),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // "Frame 48": أفراد مجموعتي
                  c.text(GroupMembersText.title(), left: 41, top: 59.75, width: 336, height: 29, dy: 0, style: c.style(24, FigmaWeight.sfBold, FamilyColors.green, lineHeight: null, letterSpacing: 0)),
                  c.text(GroupMembersText.subtitle(), left: 16, top: 117, width: 361, height: 22, dy: 0, style: c.style(13, FigmaWeight.semiBold, Colors.black, lineHeight: null, letterSpacing: 0)),
                  c.rect(left: 19, top: 149, width: 345, height: 48, child: FamilySearchField(s: s, hint: GroupMembersText.search(), onChanged: cubit.search, startPad: 4)),
                  c.rect(
                    left: 0,
                    top: _listTop,
                    width: FigmaCanvas.frameWidth,
                    height: _listBottom - _listTop,
                    child: BlocBuilder<GroupMembersCubit, GroupMembersState>(builder: (context, state) => _list(s, state)),
                  ),
                  c.rect(left: 371.5, top: 167, width: 5, height: 454, child: FamilyScrollIndicator(s: s, metrics: _metrics)),
                  c.button(GroupMembersText.showOnMap(), left: 16, top: 650, figmaSpacing: true, onTap: () => GroupController.openMap(context)),
                  c.button(GroupMembersText.showMeetingPoint(), left: 17, top: 706, figmaSpacing: true, onTap: () => GroupController.openDestination(context)),
                  Positioned.fill(
                    child: PilgrimTabBar(c: c, selected: PilgrimTab.people, barTop: 784, onTab: (tab) => PilgrimTabsController.open(context, tab)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _list(DesignScale s, GroupMembersState state) {
    final members = state.visible;
    if (members.isEmpty) {
      // لسا بيحمّل / خطأ / مش مربوط بمجموعة / ما في نتائج للبحث
      final error = state.error;
      final text = state.loading
          ? null
          : error != null
          ? ApiErrorText.of(error)()
          : state.group == null
          ? GroupMembersText.notLinked()
          : state.query.trim().isNotEmpty
          ? GroupMembersText.noResults()
          : GroupMembersText.empty();
      return Padding(
        padding: EdgeInsets.only(top: s.y(40)),
        child: Align(
          alignment: Alignment.topCenter,
          child: text == null
              ? SizedBox.square(dimension: s.x(24), child: const CircularProgressIndicator(strokeWidth: 2.5, color: FamilyColors.green))
              : Text(text, textAlign: TextAlign.center, style: figmaText(s, size: 14, weight: FigmaWeight.sfRegular, color: FamilyColors.grey, lineHeight: null, letterSpacing: 0)),
        ),
      );
    }
    final row = FigmaCanvas(s, originTop: 0);
    return FamilyScrollIndicator.track(
      _metrics,
      ListView.builder(
        padding: EdgeInsets.only(top: s.y(_firstCard - _listTop)),
        physics: const ClampingScrollPhysics(),
        itemCount: members.length,
        itemExtent: s.y(_pitch),
        itemBuilder: (context, i) {
          final member = members[i];
          return FamilyMemberCard(
            c: row,
            member: member,
            layout: MemberCardLayout.group,
            title: member.isSupervisor ? GroupMembersText.supervisor() : null,
            onMenu: (anchor) => GroupController.memberMenu(context, member, anchor),
          );
        },
      ),
    );
  }
}
