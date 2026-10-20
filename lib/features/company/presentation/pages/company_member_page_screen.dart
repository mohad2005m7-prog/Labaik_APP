import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../domain/entities/company_member.dart';
import '../../domain/repositories/company_repository.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_forms_text.dart';
import '../l10n/company_groups_text.dart';
import '../widgets/company_colors.dart';

// -------------------------------------------------------------
// "بيانات العضو" — Figma صفحة احد الاعضاء (393×852) → FigmaPage
// بطاقة العضو من GET /company/groups/{groupId}/members/{userId}: الدور، الإيميل، الجنسية، الحضور، والملاحظات الصحية
// -------------------------------------------------------------
class CompanyMemberPageScreen extends StatefulWidget {
  final CompanyRepository repository;
  final String groupId;
  final String memberId;
  final String name;

  const CompanyMemberPageScreen({super.key, required this.repository, required this.groupId, required this.memberId, required this.name});

  @override
  State<CompanyMemberPageScreen> createState() => _CompanyMemberPageScreenState();
}

class _CompanyMemberPageScreenState extends State<CompanyMemberPageScreen> {
  static const _teal = Color(0xFF4C7A75);

  CompanyMember? _member;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final m = await widget.repository.member(widget.groupId, widget.memberId);
      if (mounted) setState(() => _member = m);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = _member;
    final rows = m == null
        ? const <(String, String)>[]
        : [
            (CompanyFormsText.email().replaceAll(':', '').trim(), m.email ?? '—'),
            (CompanyFormsText.nationality(), m.nationality ?? '—'),
            (CompanyFormsText.attendance(), m.present ? CompanyFormsText.present() : CompanyFormsText.absent()),
            (CompanyFormsText.healthNotes(), m.healthNotes ?? '—'),
            (CompanyFormsText.notes(), m.notes ?? '—'),
          ];
    return FigmaPage(
      title: CompanyGroupsText.memberTitle(),
      titleRight: 349,
      chevronLeft: 367,
      body: (c) => [
        c.box(left: 147, top: 130, width: 99, height: 99, radius: 49.5, color: CompanyColors.cardInset),
        c.rect(left: 147, top: 130, width: 99, height: 99, child: Icon(Icons.person_rounded, size: c.s.x(58), color: _teal)),
        c.text(m?.name ?? widget.name, left: 16, top: 249, width: 361, height: 30, align: TextAlign.center, dy: 0, style: c.style(20, FigmaWeight.sfBold, CompanyColors.green, lineHeight: null, letterSpacing: 0)),
        if (m != null)
          c.text(
            m.isSupervisor ? CompanyFormsText.supervisorRole() : (m.number == null ? CompanyFormsText.pilgrim() : CompanyFormsText.pilgrimNumber(m.number!)),
            left: 16,
            top: 281,
            width: 361,
            height: 20,
            align: TextAlign.center,
            dy: 0,
            style: c.style(13, FigmaWeight.sfRegular, CompanyColors.secondaryLabel, lineHeight: null, letterSpacing: 0),
          ),
        c.box(left: 16, top: 316, width: 361, height: 300, radius: 14, color: CompanyColors.card),
        if (m == null && !_failed) c.rect(left: 176, top: 446, width: 40, height: 40, child: const CircularProgressIndicator(strokeWidth: 2.4, color: CompanyColors.green)),
        if (_failed) ...[
          c.text(CompanyFormsText.loadFailed(), left: 16, top: 440, width: 361, height: 22, align: TextAlign.center, dy: 0, style: c.style(14, FigmaWeight.sfRegular, const Color(0xFF717171), lineHeight: null, letterSpacing: 0)),
          c.text(CompanyFormsText.retry(), left: 16, top: 468, width: 361, height: 22, align: TextAlign.center, dy: 0, style: c.style(14, FigmaWeight.semiBold, CompanyColors.green, lineHeight: null, letterSpacing: 0)),
          c.tapArea(left: 120, top: 462, width: 153, height: 34, onTap: _load),
        ],
        for (final (i, (label, value)) in rows.indexed) ..._row(c, label, value, top: 330 + i * 56.0),
        c.button(CompanyGroupsText.chat(), left: 16, top: 700, figmaSpacing: true, onTap: () => CompanyController.comingSoon(context)),
      ],
    );
  }

  List<Widget> _row(FigmaCanvas c, String label, String value, {required double top}) => [
        c.text(label, left: 32, top: top, width: 329, height: 18, align: TextAlign.start, dy: 0, style: c.style(12, FigmaWeight.sfRegular, CompanyColors.secondaryLabel, lineHeight: null, letterSpacing: 0)),
        c.text(value, left: 32, top: top + 20, width: 329, height: 22, align: TextAlign.start, dy: 0, style: c.style(14, FigmaWeight.semiBold, CompanyColors.green, lineHeight: null, letterSpacing: 0)),
      ];
}
