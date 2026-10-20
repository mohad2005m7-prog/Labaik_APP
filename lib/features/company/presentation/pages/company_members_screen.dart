import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../domain/entities/company_group.dart';
import '../../domain/entities/company_member.dart';
import '../../domain/repositories/company_repository.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_forms_text.dart';
import '../l10n/company_groups_text.dart';
import '../widgets/company_colors.dart';
import '../widgets/company_form_sheet.dart';
import '../widgets/company_search_field.dart';

// -------------------------------------------------------------
// "الأعضاء" — Figma (393×~700) → FigmaPage
// بحث + قائمة الأعضاء (GET /company/groups/{id}/members — المشرف أول) صف كل 53px
// + زر "إضافة عضو" (POST .../members بالإيميل) — بترجع true لو انضاف عضو
// -------------------------------------------------------------
class CompanyMembersScreen extends StatefulWidget {
  final CompanyGroup group;
  final CompanyRepository repository;

  const CompanyMembersScreen({super.key, required this.group, required this.repository});

  @override
  State<CompanyMembersScreen> createState() => _CompanyMembersScreenState();
}

class _CompanyMembersScreenState extends State<CompanyMembersScreen> {
  static const _firstRowTop = 153.0;
  static const _rowPitch = 60.0;
  static const _buttonTop = 680.0;

  List<CompanyMember>? _members;
  bool _failed = false;
  bool _added = false;
  String _query = '';

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
    _added = true;
    CompanyController.showMessage(context, CompanyFormsText.memberAdded());
    _load();
  }

  List<CompanyMember> get _visible {
    final q = _query.trim().toLowerCase();
    final all = _members ?? const [];
    return q.isEmpty ? all : [for (final m in all) if (m.name.toLowerCase().contains(q) || (m.email?.toLowerCase().contains(q) ?? false)) m];
  }

  @override
  Widget build(BuildContext context) {
    final members = _visible;
    // القائمة الطويلة بتطوّل الصفحة والزر بينزل تحت آخر صف
    final listBottom = _firstRowTop + members.length * _rowPitch;
    final buttonTop = listBottom + 20 > _buttonTop ? listBottom + 20 : _buttonTop;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_added);
      },
      child: FigmaPage(
        title: CompanyGroupsText.membersTitle(),
        titleRight: 349,
        chevronLeft: 367,
        frameHeight: buttonTop + 50 + 60 > 852 ? buttonTop + 50 + 60 : 852,
        body: (c) => [
          c.rect(left: 24, top: 110, width: 345, height: 36, child: CompanySearchField(s: c.s, hint: CompanyGroupsText.searchMembers(), onChanged: (q) => setState(() => _query = q))),
          if (_members == null && !_failed) c.rect(left: 176, top: _firstRowTop + 20, width: 40, height: 40, child: const CircularProgressIndicator(strokeWidth: 2.4, color: CompanyColors.green)),
          if (_failed) ...[
            _note(c, CompanyFormsText.loadFailed()),
            c.text(CompanyFormsText.retry(), left: 16, top: _firstRowTop + 36, width: 361, height: 22, align: TextAlign.center, dy: 0, style: c.style(14, FigmaWeight.semiBold, CompanyColors.green, lineHeight: null, letterSpacing: 0)),
            c.tapArea(left: 120, top: _firstRowTop + 30, width: 153, height: 34, onTap: _load),
          ],
          if (_members != null && members.isEmpty) _note(c, CompanyFormsText.noMembers()),
          for (final (i, m) in members.indexed)
            ...CompanyMemberRow.build(
              c,
              name: m.name,
              role: m.isSupervisor ? CompanyFormsText.supervisorRole() : (m.number == null ? CompanyFormsText.pilgrim() : CompanyFormsText.pilgrimNumber(m.number!)),
              top: _firstRowTop + i * _rowPitch,
              onTap: () => CompanyController.openMemberPage(context, widget.repository, groupId: widget.group.id, memberId: m.userId, name: m.name),
            ),
          c.button(CompanyGroupsText.addMember(), left: 16, top: buttonTop, figmaSpacing: true, onTap: _add),
        ],
      ),
    );
  }

  Widget _note(FigmaCanvas c, String text) => c.text(text, left: 16, top: _firstRowTop + 8, width: 361, height: 22, align: TextAlign.center, style: c.style(14, FigmaWeight.sfRegular, const Color(0xFF717171), lineHeight: null, letterSpacing: 0));
}

// ── صف عضو واحد: أفاتار، الاسم، ودوره (مشرف المجموعة / معتمر رقم 15) ──
abstract final class CompanyMemberRow {
  static List<Widget> build(FigmaCanvas c, {required String name, required String role, required double top, required VoidCallback onTap}) => [
        c.box(left: 16, top: top, width: 361, height: 53, radius: 12, color: CompanyColors.card),
        c.box(left: 329, top: top + 6.5, width: 40, height: 40, radius: 20, color: CompanyColors.cardInset),
        c.rect(left: 329, top: top + 6.5, width: 40, height: 40, child: Icon(Icons.person_rounded, size: c.s.x(22), color: const Color(0xFF4C7A75))),
        c.text(name, left: 40, top: top + 7, width: 280, height: 20, align: TextAlign.start, dy: 0, style: c.style(15, FigmaWeight.semiBold, CompanyColors.green, lineHeight: null, letterSpacing: 0)),
        c.text(role, left: 40, top: top + 29, width: 280, height: 18, align: TextAlign.start, dy: 0, style: c.style(12, FigmaWeight.sfRegular, CompanyColors.secondaryLabel, lineHeight: null, letterSpacing: 0)),
        c.tapArea(left: 16, top: top, width: 361, height: 53, onTap: onTap),
      ];
}
