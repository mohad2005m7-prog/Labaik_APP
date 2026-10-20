import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_lines.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../../supervisor/presentation/widgets/supervisor_colors.dart';
import '../../../supervisor/presentation/widgets/supervisor_widgets.dart';
import '../../domain/entities/company_group.dart';
import '../../domain/entities/company_member.dart';
import '../../domain/repositories/company_repository.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_forms_text.dart';
import '../l10n/company_groups_text.dart';
import '../widgets/company_box.dart';
import '../widgets/company_colors.dart';
import '../widgets/company_form_sheet.dart';
import '../widgets/company_search_field.dart';

// -------------------------------------------------------------
// "أعضاء المجموعة" — مطابقة لـ Figma 755:4070 (والحذف) / 630:3841 (زر الإضافة تحت)
// البحث ← صفوف كل 53 من y177: الصورة 45 يمين، الاسم (SF Compact Bold 16 #717171 طرفه x316)، والسهم ‹ يسار
// الضغط → صفحة العضو | الضغط المطوّل على معتمر → "حذف من المجموعة" (DELETE .../members/{id})
// "إضافة عضو" → بالإيميل (POST .../members) — بترجع عدد المعتمرين الجديد لو تغيّر
// -------------------------------------------------------------
class CompanyMembersScreen extends StatefulWidget {
  final CompanyGroup group;
  final CompanyRepository repository;

  const CompanyMembersScreen({super.key, required this.group, required this.repository});

  @override
  State<CompanyMembersScreen> createState() => _CompanyMembersScreenState();
}

class _CompanyMembersScreenState extends State<CompanyMembersScreen> {
  static const _firstRowTop = 177.0;
  static const _rowPitch = 53.0;

  List<CompanyMember>? _members;
  bool _failed = false;
  bool _changed = false;
  String _query = '';

  /// المعتمر اللي فاتح عليه "حذف من المجموعة"
  String? _removing;

  int get _pilgrims => (_members ?? const []).where((m) => !m.isSupervisor).length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final members = await widget.repository.members(widget.group.id);
      if (mounted) setState(() => _members = members);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _add() async {
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
        onSubmit: () => widget.repository.addMember(widget.group.id, email: email.value, fullName: name.value, phone: phone.value),
      ),
    );
    if (!done || !mounted) return;
    _changed = true;
    CompanyController.showMessage(context, CompanyFormsText.memberAdded());
    _load();
  }

  Future<void> _remove(CompanyMember m) async {
    setState(() => _removing = null);
    try {
      await widget.repository.removeMember(widget.group.id, m.userId);
      if (!mounted) return;
      _changed = true;
      setState(() => _members = [for (final x in _members ?? const <CompanyMember>[]) if (x.userId != m.userId) x]);
      CompanyController.showMessage(context, CompanyGroupsText.removed());
    } catch (e) {
      if (mounted) CompanyController.showError(context, e);
    }
  }

  List<CompanyMember> get _visible {
    final q = _query.trim().toLowerCase();
    final all = _members ?? const [];
    return q.isEmpty ? all : [for (final m in all) if (m.name.toLowerCase().contains(q) || (m.email?.toLowerCase().contains(q) ?? false)) m];
  }

  @override
  Widget build(BuildContext context) {
    final members = _visible;
    final buttonTop = math.max(760.0, _firstRowTop + members.length * _rowPitch + 24);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed ? _pilgrims : null);
      },
      child: FigmaPage(
        title: CompanyGroupsText.membersTitle(),
        titleRight: 349,
        chevronLeft: 367,
        frameHeight: math.max(852, buttonTop + 50 + 42),
        body: (c) => [
          c.rect(left: 24, top: 117, width: 345, height: 36, child: CompanySearchField(s: c.s, hint: CompanyGroupsText.searchMembers(), onChanged: (q) => setState(() => _query = q))),
          if (_members == null && !_failed) c.rect(left: 176, top: _firstRowTop + 10, width: 40, height: 40, child: const CircularProgressIndicator(strokeWidth: 2.4, color: CompanyColors.green)),
          if (_failed) ...[
            _note(c, CompanyFormsText.loadFailed()),
            c.text(CompanyFormsText.retry(), left: 16, top: _firstRowTop + 36, width: 361, height: 22, align: TextAlign.center, dy: 0, style: c.style(14, FigmaWeight.semiBold, CompanyColors.green, lineHeight: null, letterSpacing: 0)),
            c.tapArea(left: 120, top: _firstRowTop + 30, width: 153, height: 34, onTap: _load),
          ],
          if (_members != null && members.isEmpty) _note(c, CompanyGroupsText.noMembers()),
          for (final (i, m) in members.indexed) ..._row(c, m, top: _firstRowTop + i * _rowPitch),
          // "حذف من المجموعة" (172×36 فوق الصف — Group 82)
          for (final (i, m) in members.indexed)
            if (m.userId == _removing) ...[
              c.tapArea(left: 0, top: 59, width: 393, height: 1200, onTap: () => setState(() => _removing = null)),
              companyBox(c, left: 48, top: _firstRowTop + i * _rowPitch + 4, width: 172, height: 36, radius: 8, color: Colors.white, shadow: CompanyColors.shadow),
              FigmaLines.build(c, CompanyGroupsText.removeMember(), left: 92, top: _firstRowTop + i * _rowPitch + 11, width: 120, style: c.style(14, FigmaWeight.sfRegular, SupColors.red), wrap: false),
              c.rect(left: 66, top: _firstRowTop + i * _rowPitch + 10, width: 21, height: 24, child: Icon(Icons.delete_outline_rounded, size: c.s.x(22), color: SupColors.red)),
              c.tapArea(left: 48, top: _firstRowTop + i * _rowPitch + 4, width: 172, height: 36, onTap: () => _remove(m)),
            ],
          c.button(CompanyGroupsText.addMember(), left: 18, top: buttonTop, figmaSpacing: true, onTap: _add),
        ],
      ),
    );
  }

  List<Widget> _row(FigmaCanvas c, CompanyMember m, {required double top}) => [
        c.rect(
          left: 0,
          top: top,
          width: 393,
          height: _rowPitch,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => CompanyController.openMemberPage(context, widget.repository, groupId: widget.group.id, member: m),
            onLongPress: m.isSupervisor ? null : () => setState(() => _removing = m.userId),
          ),
        ),
        c.rect(left: 324, top: top, width: 45, height: 45, child: IgnorePointer(child: SupPhoto(photo: m.photoUrl, size: c.s.x(45), name: m.name))),
        c.text(m.name, left: 60, top: top + 13, width: 256, height: 19, style: supText(c, 16, FigmaWeight.sfBold, SupColors.grey)),
        if (m.isSupervisor) c.text(CompanyFormsText.supervisorRole(), left: 60, top: top + 33, width: 256, height: 14, style: supText(c, 11, FigmaWeight.sfRegular, CompanyColors.secondaryLabel)),
        ...supChevron(c, left: 21, top: top + 12, color: SupColors.grey),
      ];

  Widget _note(FigmaCanvas c, String text) => c.text(text, left: 16, top: _firstRowTop + 8, width: 361, height: 22, align: TextAlign.center, style: c.style(14, FigmaWeight.sfRegular, const Color(0xFF717171), lineHeight: null, letterSpacing: 0));
}
