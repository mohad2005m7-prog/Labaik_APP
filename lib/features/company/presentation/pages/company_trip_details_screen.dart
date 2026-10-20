import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_lines.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../domain/entities/company_group.dart';
import '../../domain/entities/company_member.dart';
import '../../domain/entities/company_trip.dart';
import '../../domain/repositories/company_repository.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_forms_text.dart';
import '../l10n/company_groups_text.dart';
import '../l10n/company_trips_text.dart';
import '../widgets/company_box.dart';
import '../widgets/company_colors.dart';
import '../widgets/company_group_card.dart';
import 'company_create_group_screen.dart';
import 'company_group_detail_screen.dart';
import 'company_supervisors_screen.dart';

// -------------------------------------------------------------
// "تفاصيل الرحلة" — مطابقة لـ Figma 738:4590 (إطار 1039 بيتمرر)
// كرت الرحلة (الاسم، الوجهات، الشارة، والتاريخ تحت الخط) ← 3 أرقام (مجموعات / معتمر / المشرفين)
// (الضغط على "معتمر" بيفتح حجاجها/معتمريها، وعلى "المشرفين" إدارة المشرفين)
// ← "توزيع المجموعة" وكروت مجموعات الرحلة (كل 174) ← "إنشاء مجموعة" لهالرحلة
// بترجع true للي فتحها لو انعملت مجموعة أو تغيّرت وحدة
// -------------------------------------------------------------
class CompanyTripDetailsScreen extends StatefulWidget {
  final CompanyTrip trip;
  final CompanyRepository repository;

  const CompanyTripDetailsScreen({super.key, required this.trip, required this.repository});

  @override
  State<CompanyTripDetailsScreen> createState() => _CompanyTripDetailsScreenState();
}

class _CompanyTripDetailsScreenState extends State<CompanyTripDetailsScreen> {
  static const _groupsTop = 443.0;

  List<CompanyGroup>? _groups;
  bool _failed = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final all = await widget.repository.groups();
      if (mounted) setState(() => _groups = [for (final g in all) if (g.tripId == widget.trip.id) g]);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _openGroup(CompanyGroup g) async {
    final changed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => CompanyGroupDetailScreen(group: g, repository: widget.repository, trip: widget.trip)));
    if (changed == true && mounted) {
      _changed = true;
      _load();
    }
  }

  Future<void> _createGroup() async {
    final roster = await widget.repository.supervisors().catchError((_) => <CompanySupervisor>[]);
    if (!mounted) return;
    final created = await Navigator.push<CompanyGroup>(context, MaterialPageRoute(builder: (_) => CompanyCreateGroupScreen(repository: widget.repository, trips: [widget.trip], supervisors: roster)));
    if (created != null && mounted) {
      _changed = true;
      _load();
    }
  }

  Future<void> _openPilgrims() async {
    if (await CompanyController.openPilgrims(context, widget.repository, trip: widget.trip) && mounted) {
      _changed = true;
      _load();
    }
  }

  Future<void> _openSupervisors() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => CompanySupervisorsScreen(repository: widget.repository)));
    if (!mounted) return;
    // ممكن انوقف أو انحذف مشرف — منحدّث المجموعات والأرقام
    _changed = true;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final groups = _groups ?? const <CompanyGroup>[];
    final pilgrims = groups.fold<int>(0, (n, g) => n + g.memberCount);
    final supervisors = {for (final g in groups) ?g.supervisorName}.length;
    final listBottom = _groupsTop + groups.length * CompanyGroupCard.pitch;
    final buttonTop = math.max(listBottom + 8, _groupsTop + 60);
    final green = CompanyColors.green;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: FigmaPage(
        title: CompanyTripsText.detailsTitle(),
        titleRight: 349,
        chevronLeft: 367,
        frameHeight: math.max(852, buttonTop + 50 + 40),
        body: (c) => [
          // كرت الرحلة
          companyBox(c, left: 16, top: 117, width: 361, height: 158, radius: 12, color: CompanyColors.card, shadow: CompanyColors.shadow),
          companyBox(c, left: 316, top: 135, width: 45, height: 45, radius: 8, color: CompanyColors.cardInset, shadow: CompanyColors.shadow),
          c.image('$companyAssets/ic_pin.png', left: 327, top: 146, width: 24, height: 24, color: green),
          FigmaLines.build(c, trip.title, left: 60, top: 133, width: 248, style: c.style(14, FigmaWeight.semiBold, green), wrap: false),
          FigmaLines.build(c, trip.destinations, left: 60, top: 159, width: 248, style: c.style(12, FigmaWeight.sfRegular, green), wrap: false),
          companyBox(c, left: 225, top: 189, width: 83, height: 21, radius: 10.5, color: green),
          FigmaLines.build(c, trip.status == CompanyTripStatus.upcoming ? CompanyTripsText.statusUpcoming() : CompanyTripsText.statusDeparted(), left: 225, top: 189, width: 83, align: TextAlign.center, style: c.style(12, FigmaWeight.sfRegular, Colors.white, lineHeight: 21), lineHeight: 21, wrap: false),
          c.box(left: 24.5, top: 235, width: 344.5, height: 1, color: green.withValues(alpha: 0.57)),
          FigmaLines.build(c, trip.dates, left: 100, top: 243, width: 239, style: c.style(12, FigmaWeight.sfRegular, green), wrap: false),

          // الأرقام
          // "معتمر" → حجاج/معتمرين هالرحلة، "المشرفين" → إدارة المشرفين
          ..._stat(c, left: 277, value: groups.length, label: CompanyTripsText.groupsStat()),
          ..._stat(c, left: 149, value: pilgrims, label: CompanyTripsText.pilgrimsStat(hajj: trip.isHajj), onTap: _openPilgrims),
          ..._stat(c, left: 22, value: supervisors, label: CompanyTripsText.supervisorsStat(), onTap: _openSupervisors),

          FigmaLines.build(c, CompanyTripsText.distribution(), left: 177, top: 395, width: 200, style: c.style(20, FigmaWeight.sfBold, green, lineHeight: 24), lineHeight: 24, wrap: false),
          if (_groups == null && !_failed) c.rect(left: 176, top: _groupsTop + 10, width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 2.4, color: green)),
          if (_failed) ...[
            c.text(CompanyFormsText.loadFailed(), left: 16, top: _groupsTop + 8, width: 361, height: 22, align: TextAlign.center, dy: 0, style: c.style(14, FigmaWeight.sfRegular, const Color(0xFF717171), lineHeight: null, letterSpacing: 0)),
            c.tapArea(left: 16, top: _groupsTop, width: 361, height: 40, onTap: _load),
          ],
          if (_groups != null && groups.isEmpty)
            c.text(CompanyGroupsText.empty(), left: 16, top: _groupsTop + 8, width: 361, height: 22, align: TextAlign.center, dy: 0, style: c.style(14, FigmaWeight.sfRegular, const Color(0xFF717171), lineHeight: null, letterSpacing: 0)),
          for (final (i, g) in groups.indexed) ...CompanyGroupCard.build(c, g, top: _groupsTop + i * CompanyGroupCard.pitch, onTap: () => _openGroup(g)),
          c.button(CompanyGroupsText.createGroup(), left: 16, top: buttonTop, figmaSpacing: true, onTap: _createGroup),
        ],
      ),
    );
  }

  // كرت رقم 100×80 (#4C7A75 10%): الرقم فوق (y307) والعنوان تحته (y339) بالنص
  List<Widget> _stat(FigmaCanvas c, {required double left, required int value, required String label, VoidCallback? onTap}) => [
        companyBox(c, left: left, top: 291, width: 100, height: 80, radius: 10, color: CompanyColors.card, shadow: CompanyColors.shadow),
        FigmaLines.build(c, '$value', left: left, top: 307, width: 100, align: TextAlign.center, style: c.style(20, FigmaWeight.sfBold, CompanyColors.green, lineHeight: 24), lineHeight: 24, wrap: false),
        FigmaLines.build(c, label, left: left, top: 339, width: 100, align: TextAlign.center, style: c.style(14, FigmaWeight.sfRegular, CompanyColors.green, lineHeight: 17), lineHeight: 17, wrap: false),
        if (onTap != null) c.tapArea(left: left, top: 291, width: 100, height: 80, onTap: onTap),
      ];
}
