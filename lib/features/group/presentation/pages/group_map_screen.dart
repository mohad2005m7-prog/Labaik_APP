import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../../family/domain/entities/family_circle.dart';
import '../../../family/domain/entities/family_member.dart';
import '../../../family/presentation/l10n/family_map_text.dart';
import '../../../family/presentation/l10n/family_messages_text.dart';
import '../../../family/presentation/widgets/family_map_legend.dart';
import '../../../family/presentation/widgets/family_map_view.dart';
import '../../../help_center/presentation/widgets/help_text.dart';
import '../controllers/group_controller.dart';
import '../cubits/group_members_cubit.dart';
import '../l10n/group_map_text.dart';
import '../l10n/group_members_text.dart';

// -------------------------------------------------------------
// "أفراد مجموعتي على الخريطة" (Figma 111:6611):
// الخريطة (16,146 361×389 بألوان صورة Figma) — زر موقعي (316,156) — المفتاح (4 كروت من y563)
// "8  أفراد يشاركون مواقعهم" (العدد الفعلي) — عرض نقطة التجمع (16,704) → وجهتك القادمة
// الضغط على دبوس فرد: بدء محادثة / عرض الموقع (الخريطة بتقرّب عليه)
// -------------------------------------------------------------
class GroupMapScreen extends StatefulWidget {
  final FamilyMapFocus? focus;

  const GroupMapScreen({super.key, this.focus});

  @override
  State<GroupMapScreen> createState() => _GroupMapScreenState();
}

class _GroupMapScreenState extends State<GroupMapScreen> {
  late FamilyMapFocus? _focus = widget.focus;

  void _focusOn(FamilyMember member) => setState(() => _focus = FamilyMapFocus.member(member.userId, version: (_focus?.version ?? 0) + 1));

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: GroupMapText.title(),
      titleRight: 348.5,
      chevronLeft: 367,
      headerDy: 0,
      titleSize: 24,
      body: (c) => [
        HelpText.paragraph(c, GroupMapText.description(), left: 16, top: 109, width: 361, lines: 1, style: c.style(14, FigmaWeight.semiBold, Colors.black)),
        c.rect(
          left: 16,
          top: 146,
          width: 361,
          height: 389,
          child: ClipRect(
            child: BlocBuilder<GroupMembersCubit, GroupMembersState>(
              builder: (context, state) {
                final point = state.group?.meetingPoint;
                return FamilyMapView(
                  s: c.s,
                  members: state.members,
                  meetingPoint: point == null ? null : MeetingPoint(name: point.title, location: point.location),
                  focus: _focus,
                  locateButton: const Offset(26, 10),
                  onNoLocation: () => GroupController.showMessage(context, FamilyMessagesText.locationOff),
                  onMemberTap: (member, anchor) => GroupController.memberMenu(context, member, anchor, onShowLocation: _focusOn),
                );
              },
            ),
          ),
        ),
        ...familyMapLegend(c, dy: -7),
        Positioned.fill(
          child: BlocBuilder<GroupMembersCubit, GroupMembersState>(
            buildWhen: (a, b) => a.members != b.members,
            builder: (context, state) => Stack(
              children: [
                c.text(
                  FamilyMapText.sharing(state.members.where((m) => !m.isMe && m.sharesLocation && m.location != null).length),
                  left: 16,
                  top: 668,
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
        c.button(GroupMembersText.showMeetingPoint(), left: 16, top: 704, figmaSpacing: true, onTap: () => GroupController.openDestination(context)),
      ],
    );
  }
}
