import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../../supervisor/presentation/widgets/supervisor_colors.dart';
import '../../../supervisor/presentation/widgets/supervisor_widgets.dart';
import '../../domain/entities/company_group.dart';
import '../../domain/entities/company_member.dart';
import '../../domain/entities/company_trip.dart';
import '../../domain/repositories/company_repository.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_forms_text.dart';
import '../l10n/company_groups_text.dart';
import '../widgets/company_colors.dart';
import '../widgets/company_search_field.dart';

/// معتمر بمجموعته (الضغط بيفتح صفحته من مجموعته)
typedef CompanyPilgrimRow = ({CompanyGroup group, CompanyMember member});

// -------------------------------------------------------------
// "الحجاج والمعتمرون" — كرت "حجاج / معتمرين" بالرئيسية (أو "معتمر" بتفاصيل الرحلة لرحلة وحدة)
// كل أعضاء مجموعات الشركة (بلا المشرفين) — بستايل "أعضاء المجموعة" (755:4070):
// البحث والعدد ← صفوف كل 53: الصورة 45 يمين، الاسم وتحته مجموعته، والسهم ‹ يسار
// الضغط → صفحة العضو (نفس صفحة المشرف) — من GET /company/pilgrims بطلب واحد
// (سيرفر أقدم: أعضاء كل مجموعة — ومجموعة ما وصلت أعضاءها بتنتجاهل إلا لو فشلوا كلهم)
// -------------------------------------------------------------
class CompanyPilgrimsScreen extends StatefulWidget {
  final CompanyRepository repository;
  final CompanyTrip? trip;

  const CompanyPilgrimsScreen({super.key, required this.repository, this.trip});

  @override
  State<CompanyPilgrimsScreen> createState() => _CompanyPilgrimsScreenState();
}

class _CompanyPilgrimsScreenState extends State<CompanyPilgrimsScreen> {
  static const _firstRowTop = 197.0;
  static const _rowPitch = 53.0;

  List<CompanyPilgrimRow>? _rows;
  bool _failed = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final trip = widget.trip;
      final groups = [for (final g in await widget.repository.groups()) if (trip == null || g.tripId == trip.id) g];
      // GET /company/pilgrims: كل المعتمرين بطلب واحد (كل معتمر مرة وحدة مع أول مجموعة إله من هالقائمة)
      try {
        final byId = {for (final g in groups) g.id: g};
        final rows = <CompanyPilgrimRow>[
          for (final p in await widget.repository.pilgrims())
            if (p.groupIds.map((id) => byId[id]).nonNulls.firstOrNull case final g?) (group: g, member: CompanyMember(userId: p.userId, name: p.name, email: p.email)),
        ]..sort((a, b) => a.member.name.compareTo(b.member.name));
        if (mounted) setState(() => _rows = rows);
        return;
      } on ApiException catch (e) {
        if (!e.isMissingOnServer) rethrow;
      }
      // سيرفر أقدم: أعضاء كل مجموعة لحالها
      var failures = 0;
      final lists = await Future.wait(groups.map((g) => widget.repository.members(g.id).catchError((Object _) {
            failures++;
            return const <CompanyMember>[];
          })));
      if (groups.isNotEmpty && failures == groups.length) throw StateError('members');
      final rows = <CompanyPilgrimRow>[
        for (final (i, g) in groups.indexed)
          for (final m in lists[i])
            if (!m.isSupervisor) (group: g, member: m),
      ]..sort((a, b) => a.member.name.compareTo(b.member.name));
      if (mounted) setState(() => _rows = rows);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  List<CompanyPilgrimRow> get _visible {
    final q = _query.trim().toLowerCase();
    final all = _rows ?? const <CompanyPilgrimRow>[];
    if (q.isEmpty) return all;
    return [for (final r in all) if (r.member.name.toLowerCase().contains(q) || (r.member.email?.toLowerCase().contains(q) ?? false) || r.group.name.toLowerCase().contains(q)) r];
  }

  @override
  Widget build(BuildContext context) {
    final rows = _visible;
    final trip = widget.trip;
    final green = CompanyColors.green;
    return FigmaPage(
      title: trip == null ? CompanyFormsText.pilgrimsTitle() : CompanyGroupsText.pilgrims(hajj: trip.isHajj),
      titleRight: 349,
      chevronLeft: 367,
      frameHeight: math.max(852, _firstRowTop + rows.length * _rowPitch + 60),
      body: (c) => [
        c.rect(left: 24, top: 117, width: 345, height: 36, child: CompanySearchField(s: c.s, hint: CompanyFormsText.searchPilgrims(), onChanged: (q) => setState(() => _query = q))),
        if (_rows != null) c.text(CompanyFormsText.pilgrimsCount(_rows!.length), left: 24, top: 165, width: 345, height: 18, dy: 0, style: c.style(13, FigmaWeight.sfRegular, CompanyColors.secondaryLabel, lineHeight: null, letterSpacing: 0)),
        if (_rows == null && !_failed) c.rect(left: 176, top: _firstRowTop + 10, width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 2.4, color: green)),
        if (_failed) ...[
          _note(c, CompanyFormsText.loadFailed()),
          c.text(CompanyFormsText.retry(), left: 16, top: _firstRowTop + 36, width: 361, height: 22, align: TextAlign.center, dy: 0, style: c.style(14, FigmaWeight.semiBold, green, lineHeight: null, letterSpacing: 0)),
          c.tapArea(left: 120, top: _firstRowTop + 30, width: 153, height: 34, onTap: _load),
        ],
        if (_rows != null && rows.isEmpty) _note(c, _query.trim().isEmpty ? CompanyFormsText.noPilgrims() : CompanyGroupsText.noResults()),
        for (final (i, r) in rows.indexed) ..._row(c, r, top: _firstRowTop + i * _rowPitch),
      ],
    );
  }

  List<Widget> _row(FigmaCanvas c, CompanyPilgrimRow r, {required double top}) => [
        c.tapArea(left: 0, top: top, width: 393, height: _rowPitch, onTap: () => CompanyController.openMemberPage(context, widget.repository, groupId: r.group.id, member: r.member)),
        c.rect(left: 324, top: top, width: 45, height: 45, child: IgnorePointer(child: SupPhoto(photo: r.member.photoUrl, size: c.s.x(45), name: r.member.name))),
        c.text(r.member.name, left: 60, top: top + 6, width: 256, height: 19, style: supText(c, 16, FigmaWeight.sfBold, SupColors.grey)),
        c.text(r.group.name, left: 60, top: top + 28, width: 256, height: 14, style: supText(c, 11, FigmaWeight.sfRegular, CompanyColors.secondaryLabel)),
        ...supChevron(c, left: 21, top: top + 12, color: SupColors.grey),
      ];

  Widget _note(FigmaCanvas c, String text) => c.text(text, left: 16, top: _firstRowTop + 8, width: 361, height: 22, align: TextAlign.center, style: c.style(14, FigmaWeight.sfRegular, const Color(0xFF717171), lineHeight: null, letterSpacing: 0));
}
