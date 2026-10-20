import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../../help_center/presentation/widgets/help_text.dart';
import '../../domain/entities/family_member.dart';
import '../controllers/family_controller.dart';
import '../cubits/family_members_cubit.dart';
import '../l10n/family_map_text.dart';
import '../l10n/family_members_text.dart';
import '../l10n/family_messages_text.dart';
import '../widgets/family_map_legend.dart';
import '../widgets/family_map_view.dart';
import '../widgets/member_menu.dart';

export '../widgets/family_map_view.dart' show FamilyMapFocus;

// -------------------------------------------------------------
// "أفراد عائلتي على الخريطة" (Figma 111:6522):
// الخريطة (16,157 361×389) — المفتاح (4 كروت من y570) — "8  أفراد يشاركون مواقعهم" (العدد الفعلي) — عرض نقطة التجمع (16,723)
// نفس بيانات القائمة (FamilyMembersCubit) فبتتحدّث معها كل 15 ثانية
// -------------------------------------------------------------
class FamilyMapScreen extends StatefulWidget {
  final FamilyMapFocus? focus;

  const FamilyMapScreen({super.key, this.focus});

  @override
  State<FamilyMapScreen> createState() => _FamilyMapScreenState();
}

class _FamilyMapScreenState extends State<FamilyMapScreen> {
  late FamilyMapFocus? _focus = widget.focus;

  /// الضغط على دبوس فرد: بدء محادثة / عرض الموقع (الخريطة بتقرّب عليه)
  Future<void> _memberMenu(FamilyMember member, Rect anchor) async {
    final action = await showMemberMenu(context, anchor: anchor, actions: const [MemberAction.chat, MemberAction.location]);
    if (action == null || !mounted) return;
    if (action == MemberAction.chat) {
      await FamilyController.startChat(context, member);
    } else if (action == MemberAction.location) {
      setState(() => _focus = FamilyMapFocus.member(member.userId, version: (_focus?.version ?? 0) + 1));
    }
  }

  /// "عرض نقطة التجمع": الخريطة بتروح عليها (كل ضغطة) — أو رسالة لو مش محددة
  void _showMeetingPoint() {
    if (context.read<FamilyMembersCubit>().state.circle?.meetingPoint == null) {
      FamilyController.showMessage(context, FamilyMessagesText.noMeetingPoint);
      return;
    }
    setState(() => _focus = FamilyMapFocus.meetingPoint(version: (_focus?.version ?? 0) + 1));
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: FamilyMapText.title(),
      titleRight: 348.5,
      chevronLeft: 365.5,
      headerDy: 2,
      titleSize: 24,
      body: (c) => [
        HelpText.paragraph(c, FamilyMapText.description(), left: 88, top: 119, width: 289, lines: 1, style: c.style(14, FigmaWeight.semiBold, Colors.black)),
        c.rect(
          left: 16,
          top: 157,
          width: 361,
          height: 389,
          child: ClipRect(
            child: BlocBuilder<FamilyMembersCubit, FamilyMembersState>(
              builder: (context, state) => FamilyMapView(
                s: c.s,
                members: state.members,
                meetingPoint: state.circle?.meetingPoint,
                focus: _focus,
                onNoLocation: () => FamilyController.showMessage(context, FamilyMessagesText.locationOff),
                onMemberTap: _memberMenu,
              ),
            ),
          ),
        ),
        ...familyMapLegend(c),
        Positioned.fill(
          child: BlocBuilder<FamilyMembersCubit, FamilyMembersState>(
            buildWhen: (a, b) => a.members != b.members,
            builder: (context, state) => Stack(
              children: [
                c.text(
                  FamilyMapText.sharing(state.members.where((m) => !m.isMe && m.sharesLocation && m.location != null).length),
                  left: 16,
                  top: 669,
                  width: 361,
                  height: 22,
                  dy: 0,
                  align: TextAlign.center,
                  style: c.style(15, FigmaWeight.semiBold, Colors.black, lineHeight: null, letterSpacing: 0),
                ),
              ],
            ),
          ),
        ),
        c.button(FamilyMembersText.showMeetingPoint(), left: 16, top: 723, width: 360, figmaSpacing: true, onTap: _showMeetingPoint),
      ],
    );
  }
}
