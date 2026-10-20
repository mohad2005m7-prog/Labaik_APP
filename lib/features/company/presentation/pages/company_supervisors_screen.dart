import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_lines.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../domain/entities/company_member.dart';
import '../../domain/repositories/company_repository.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_profile_text.dart';
import '../widgets/company_colors.dart';
import '../../../supervisor/presentation/widgets/supervisor_colors.dart';
import '../widgets/company_search_field.dart';
import 'company_supervisor_screen.dart';

// -------------------------------------------------------------
// "إدارة المشرفين" — مطابقة لـ Figma 672:4107
// البحث ← "المشرفون" و"عرض الكل" ← صفوف (الاسم يمين و"مشرف مجموعة" يسار) كل 53 ← "إضافة مشرف"
// القائمة من GET /company/supervisors — بتطلع أول 3 لحد ما يضغط "عرض الكل"
// الضغط على مشرف → "بيانات المشرف" (كلمة مؤقتة / إيقاف وتفعيل / حذف)
// -------------------------------------------------------------
class CompanySupervisorsScreen extends StatefulWidget {
  final CompanyRepository repository;

  const CompanySupervisorsScreen({super.key, required this.repository});

  @override
  State<CompanySupervisorsScreen> createState() => _CompanySupervisorsScreenState();
}

class _CompanySupervisorsScreenState extends State<CompanySupervisorsScreen> {
  static const _rowsTop = 232.0;
  static const _rowHeight = 53.0;

  List<CompanySupervisor>? _all;
  bool _failed = false;
  bool _showAll = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final list = await widget.repository.supervisors();
      if (mounted) setState(() => _all = list);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _open(CompanySupervisor s) async {
    final changed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => CompanySupervisorScreen(supervisor: s, repository: widget.repository)));
    if (changed == true && mounted) _load();
  }

  Future<void> _add() async {
    final added = await CompanyController.openAddSupervisor(context, widget.repository);
    if (added != null && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final matches = [for (final s in _all ?? const <CompanySupervisor>[]) if (q.isEmpty || s.name.toLowerCase().contains(q) || s.email.toLowerCase().contains(q)) s];
    final rows = _showAll || q.isNotEmpty ? matches : matches.take(3).toList();
    final buttonTop = math.max(429.0, _rowsTop + rows.length * _rowHeight + 38);
    final green = CompanyColors.green;
    return FigmaPage(
      title: CompanyProfileText.supervisors(),
      titleRight: 349,
      chevronLeft: 367,
      frameHeight: math.max(852, buttonTop + 50 + 60),
      body: (c) => [
        c.box(left: 17, top: 108, width: 360, height: 1, color: const Color(0xFFE5E5EA)),
        c.rect(left: 13, top: 132, width: 365, height: 48, child: CompanySearchField(s: c.s, hint: CompanyProfileText.searchSupervisors(), onChanged: (v) => setState(() => _query = v))),
        FigmaLines.build(c, CompanyProfileText.supervisorsSection(), left: 226, top: 203, width: 150, style: c.style(16, FigmaWeight.semiBold, green), wrap: false),
        if (matches.length > 3 && q.isEmpty) ...[
          FigmaLines.build(c, _showAll ? '' : CompanyProfileText.showAll(), left: 11, top: 203, width: 100, align: TextAlign.left, style: c.style(14, FigmaWeight.sfRegular, const Color(0xFF4C7A75)), wrap: false),
          c.tapArea(left: 5, top: 198, width: 100, height: 32, onTap: () => setState(() => _showAll = true)),
        ],
        if (_all == null && !_failed) c.rect(left: 176, top: _rowsTop + 10, width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 2.4, color: green)),
        if (_failed) ...[
          c.text(CompanyProfileText.loadFailed(), left: 16, top: _rowsTop + 8, width: 361, height: 44, align: TextAlign.center, dy: 0, style: c.style(13, FigmaWeight.sfRegular, CompanyColors.secondaryLabel, lineHeight: null, letterSpacing: 0)),
          c.tapArea(left: 16, top: _rowsTop, width: 361, height: 60, onTap: _load),
        ],
        if (_all != null && rows.isEmpty)
          c.text(CompanyProfileText.noSupervisors(), left: 16, top: _rowsTop + 8, width: 361, height: 22, align: TextAlign.center, dy: 0, style: c.style(14, FigmaWeight.sfRegular, const Color(0xFF717171), lineHeight: null, letterSpacing: 0)),
        for (final (i, s) in rows.indexed) ...[
          // الصف كله بيفتح "بيانات المشرف" (التحكم: كلمة مؤقتة / إيقاف / حذف)
          c.tapArea(left: 11, top: _rowsTop + i * _rowHeight, width: 365, height: _rowHeight, onTap: () => _open(s)),
          if (s.suspended) FigmaLines.build(c, CompanyProfileText.suspendedBadge(), left: 18, top: _rowsTop + i * _rowHeight + 33, width: 130, align: TextAlign.left, style: c.style(10, FigmaWeight.sfRegular, SupColors.red), wrap: false),
          FigmaLines.build(c, s.name, left: 150, top: _rowsTop + i * _rowHeight + 16, width: 211, style: c.style(15, FigmaWeight.semiBold, green), wrap: false),
          FigmaLines.build(c, s.groupsCount == 0 ? CompanyProfileText.noGroup() : CompanyProfileText.groupsCount(s.groupsCount), left: 18, top: _rowsTop + i * _rowHeight + 16, width: 130, align: TextAlign.left, style: c.style(13, FigmaWeight.sfRegular, CompanyColors.secondaryLabel), wrap: false),
          c.box(left: 11, top: _rowsTop + (i + 1) * _rowHeight - 1, width: 365, height: 1, color: const Color(0xFFEDEDED)),
        ],
        c.button(CompanyProfileText.addSupervisor(), left: 11, top: buttonTop, width: 365, figmaSpacing: true, onTap: _add),
      ],
    );
  }
}
