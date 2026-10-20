import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/api_error_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../pilgrim_tabs/presentation/controllers/pilgrim_tabs_controller.dart';
import '../../../pilgrim_tabs/presentation/widgets/pilgrim_tab_bar.dart';
import '../../domain/entities/family_member.dart';
import '../controllers/family_controller.dart';
import '../cubits/family_members_cubit.dart';
import '../l10n/family_members_text.dart';
import '../widgets/family_colors.dart';
import '../widgets/family_member_card.dart';
import '../widgets/family_scroll_indicator.dart';
import '../widgets/family_search_field.dart';
import '../widgets/member_menu.dart';

// -------------------------------------------------------------
// "أفراد عائلتي" (Figma 111:5255) — تبويب "الأفراد":
// العنوان (SF Compact 790 24) — "عائلتك قريبة منك أثناء الرحلة 🤍" — البحث (21,143 345×36)
// الأفراد من السيرفر (أنا أول) من y203 كل 98 — شريط التمرير (372.5 من y172 لـ y597)
// عرض قائمة أفراد العائلة على الخريطة (17,611) — عرض نقطة التجمع (18,685) — شريط التنقل
// الاتصال والمواقع بيتحدّثوا كل 15 ثانية والشاشة مفتوحة
// -------------------------------------------------------------
class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  static const _listTop = 187.0;
  static const _listBottom = 597.0;

  final _metrics = ValueNotifier<ScrollMetrics?>(null);

  @override
  void dispose() {
    _metrics.dispose();
    super.dispose();
  }

  Future<void> _menu(FamilyMember member, Rect anchor) async {
    final state = context.read<FamilyMembersCubit>().state;
    final actions = member.isMe
        ? [MemberAction.location, member.sharesLocation ? MemberAction.stopSharing : MemberAction.startSharing]
        : [MemberAction.chat, MemberAction.location, if (state.circle?.isOwner == true) MemberAction.remove];
    FocusScope.of(context).unfocus();
    final action = await showMemberMenu(context, anchor: anchor, actions: actions);
    if (action == null || !mounted) return;
    switch (action) {
      case MemberAction.chat:
        FamilyController.startChat(context, member);
      case MemberAction.location:
        FamilyController.showMemberLocation(context, member);
      case MemberAction.remove:
        FamilyController.removeMember(context, member);
      case MemberAction.stopSharing:
        FamilyController.toggleSharing(context, enable: false);
      case MemberAction.startSharing:
        FamilyController.toggleSharing(context, enable: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    final c = FigmaCanvas(s);
    final cubit = context.read<FamilyMembersCubit>();
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
              height: s.y(DesignScale.designSafeHeight),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // "Frame 17": أفراد عائلتي
                  c.text(FamilyMembersText.title(), left: 41, top: 60.25, width: 336, height: 29, dy: 0, style: c.style(24, FigmaWeight.sfBold, FamilyColors.green, lineHeight: null, letterSpacing: 0)),
                  c.text(FamilyMembersText.subtitle(), left: 41, top: 108, width: 336, height: 20, dy: 0, style: c.style(12.5, FigmaWeight.semiBold, Colors.black, lineHeight: null, letterSpacing: 0)),
                  c.rect(left: 21, top: 143, width: 345, height: 36, child: FamilySearchField(s: s, hint: FamilyMembersText.search(), onChanged: cubit.search)),
                  c.rect(
                    left: 0,
                    top: _listTop,
                    width: FigmaCanvas.frameWidth,
                    height: _listBottom - _listTop,
                    child: BlocBuilder<FamilyMembersCubit, FamilyMembersState>(builder: (context, state) => _list(s, state)),
                  ),
                  c.rect(left: 372, top: 172, width: 5, height: 425, child: FamilyScrollIndicator(s: s, metrics: _metrics)),
                  c.button(FamilyMembersText.showOnMap(), left: 17, top: 611, figmaSpacing: true, onTap: () => FamilyController.openMap(context)),
                  c.button(FamilyMembersText.showMeetingPoint(), left: 18, top: 685, figmaSpacing: true, onTap: () => FamilyController.showMeetingPoint(context)),
                  Positioned.fill(
                    child: PilgrimTabBar(c: c, selected: PilgrimTab.people, onTab: (tab) => PilgrimTabsController.open(context, tab)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _list(DesignScale s, FamilyMembersState state) {
    final members = state.visible;
    if (members.isEmpty) {
      // لسا بيحمّل / خطأ السيرفر / ما في نتائج للبحث / فاضية
      final error = state.error;
      final text = state.loading
          ? null
          : error != null && state.members.isEmpty
          ? ApiErrorText.of(error)()
          : state.query.trim().isNotEmpty
          ? FamilyMembersText.noResults()
          : FamilyMembersText.empty();
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
        padding: EdgeInsets.only(top: s.y(203 - _listTop)),
        physics: const ClampingScrollPhysics(),
        itemCount: members.length,
        itemExtent: s.y(FamilyMemberCard.pitch),
        itemBuilder: (context, i) => FamilyMemberCard(c: row, member: members[i], onMenu: (anchor) => _menu(members[i], anchor)),
      ),
    );
  }
}
