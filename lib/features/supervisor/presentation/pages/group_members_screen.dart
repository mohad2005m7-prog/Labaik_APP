import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../company/presentation/l10n/company_forms_text.dart';
import '../../../company/presentation/widgets/company_form_sheet.dart';
import '../../../field_mode/presentation/widgets/back_title_header.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/supervisor_group.dart';
import '../../domain/repositories/supervisor_repository.dart';
import '../controllers/supervisor_controller.dart';
import '../cubits/supervisor_content_cubits.dart';
import '../l10n/group_members_text.dart';
import '../widgets/supervisor_colors.dart';
import '../widgets/supervisor_page.dart';
import '../widgets/supervisor_widgets.dart';

// -------------------------------------------------------------
// أعضاء المجموعة — مطابقة لـ Figma "قائمة الاعضاء" (234:2599 الكل / 234:2668 حاضر / 234:2737 غير حاضر)
// التبويبات صفحات بتنسحب يمين/يسار (والمؤشر بيمشي مع السحب)، وكل قائمة بتتمرر لفوق ولتحت
// البحث بالاسم أو رقم المعتمر | الصورة → تكبيرها (زي انستغرام) | الصف → صفحة العضو
// التحكم: "إضافة عضو" تحت (بالإيميل) | الضغط المطوّل على معتمر → إزالة من المجموعة (بتأكيد)
// -------------------------------------------------------------
class GroupMembersScreen extends StatelessWidget {
  final SupervisorGroup group;

  const GroupMembersScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupMembersCubit(context.read<SupervisorRepository>(), group.id)..load(),
      child: const _MembersView(),
    );
  }
}

class _MembersView extends StatefulWidget {
  const _MembersView();

  @override
  State<_MembersView> createState() => _MembersViewState();
}

class _MembersViewState extends State<_MembersView> {
  static const _listTop = 228.0;
  static const _buttonTop = 760.0;
  final _pages = PageController();

  Future<void> _add() async {
    final cubit = context.read<GroupMembersCubit>();
    final email = CompanySheetField(label: CompanyFormsText.email(), hint: CompanyFormsText.emailHint(), keyboard: TextInputType.emailAddress);
    final name = CompanySheetField(label: CompanyFormsText.fullName(), hint: CompanyFormsText.fullNameHint(), required: false);
    final phone = CompanySheetField(label: CompanyFormsText.phone(), hint: CompanyFormsText.phoneHint(), keyboard: TextInputType.phone, required: false);
    final done = await CompanyFormSheet.show(
      context,
      CompanyFormSheet(
        title: CompanyFormsText.addMemberTitle(),
        subtitle: CompanyFormsText.addMemberSubtitle(),
        fields: [email, name, phone],
        submitLabel: CompanyFormsText.add(),
        conflictMessage: CompanyFormsText.memberExists(),
        onSubmit: () => cubit.add(email: email.value, fullName: name.value, phone: phone.value),
      ),
    );
    if (done && mounted) SupervisorController.showMessage(context, CompanyFormsText.memberAdded);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SupervisorPage(
      builder: (c) => [
        c.rect(
          left: 25,
          top: 117,
          width: 343,
          height: 32,
          child: BlocBuilder<GroupMembersCubit, ListState<GroupMember>>(
            buildWhen: (a, b) => a.items != b.items,
            builder: (context, state) => SupSegmented(
              s: c.s,
              controller: _pages,
              labels: [
                GroupMembersText.tabAll(),
                GroupMembersText.tabPresent('${state.presentCount}'),
                GroupMembersText.tabAbsent('${state.absentCount}'),
              ],
              labelStyle: supText(c, 13, FigmaWeight.sfRegular, Colors.black),
            ),
          ),
        ),
        c.rect(left: 24, top: 173, width: 345, height: 36, child: SupSearchField(s: c.s, hint: GroupMembersText.search(), fontSize: 15, onChanged: context.read<GroupMembersCubit>().search)),
        c.rect(
          left: 0,
          top: _listTop,
          width: 393,
          height: _buttonTop - 12 - _listTop,
          child: PageView(
            controller: _pages,
            children: [for (final tab in MembersTab.values) SupKeepAlive(child: _MembersList(c: c.at(_listTop), tab: tab))],
          ),
        ),
        c.button(GroupMembersText.add(), left: 18, top: _buttonTop, figmaSpacing: true, onTap: _add),
        PositionedDirectional(start: 0, end: 0, top: 0, child: BackTitleHeader(scale: c.s, title: GroupMembersText.title())),
      ],
    );
  }
}

class _MembersList extends StatelessWidget {
  final FigmaCanvas c;
  final MembersTab tab;

  const _MembersList({required this.c, required this.tab});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupMembersCubit, ListState<GroupMember>>(
      builder: (context, state) {
        final members = state.visible(tab);
        return ListView.builder(
          padding: EdgeInsets.zero,
          physics: supScrollPhysics,
          itemCount: members.length,
          itemExtent: c.s.y(53),
          itemBuilder: (context, i) => Stack(children: _row(context, members[i])),
        );
      },
    );
  }

  List<Widget> _row(BuildContext context, GroupMember m) {
    final top = c.originTop;
    final heroTag = 'member-${tab.name}-${m.id}';
    final photo = m.photo;
    return [
      c.rect(
        left: 0,
        top: top,
        width: 393,
        height: 53,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => SupervisorController.openMember(context, m, groupId: context.read<GroupMembersCubit>().groupId),
          onLongPress: () => _confirmRemove(context, m),
        ),
      ),
      c.rect(left: 324, top: top + 5, width: 45, height: 45, child: SupPhoto(photo: photo, size: c.s.x(45), name: m.name, heroTag: heroTag)),
      if (photo != null) c.tapArea(left: 322, top: top + 3, width: 49, height: 49, onTap: () => SupervisorController.viewPhoto(context, photo: photo, heroTag: heroTag, title: m.name)),
      // SF Compact Bold 16 — #717171 — طرفه x315
      c.text(m.name, left: 60, top: top + 17, width: 255, height: 19, style: supText(c, 16, FigmaWeight.sfBold, SupColors.grey)),
      ...supChevron(c, left: 21, top: top + 16, color: SupColors.grey),
    ];
  }

  Future<void> _confirmRemove(BuildContext context, GroupMember m) async {
    final cubit = context.read<GroupMembersCubit>();
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            content: Text(GroupMembersText.removeConfirm(m.name), style: const TextStyle(fontFamily: 'NotoSansArabic', fontSize: 15)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(GroupMembersText.cancel())),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(GroupMembersText.remove(), style: const TextStyle(color: SupColors.red, fontWeight: FontWeight.bold))),
            ],
          ),
        ) ??
        false;
    if (!ok || !context.mounted) return;
    try {
      await cubit.remove(m);
      if (context.mounted) SupervisorController.showMessage(context, GroupMembersText.removed);
    } catch (_) {
      if (context.mounted) SupervisorController.showMessage(context, GroupMembersText.failed);
    }
  }
}
