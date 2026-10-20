import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_lines.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../domain/entities/company_group.dart';
import '../../domain/entities/company_member.dart';
import '../../domain/entities/company_trip.dart';
import '../../domain/repositories/company_repository.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_groups_text.dart';
import '../widgets/company_box.dart';
import '../widgets/company_colors.dart';
import '../widgets/company_group_card.dart';

// -------------------------------------------------------------
// "تفاصيل المجموعة" — مطابقة لـ Figma 630:4039 (فيها مشرف) / 748:3815 (بلا مشرف ولا أعضاء)
// كرت المجموعة 120 ← "تاريخ الرحلة" و"المعتمرون" ← "عرض جميع الاعضاء" (أو "إضافة اعضاء مجموعة")
// (اسم المشرف بالكرت بيفتح صفحته)
// ← "رؤية الدردشة" و"تغيير المشرف" (السهم بيفتح قائمة مشرفي الشركة تحته — Group 82) ← "ملاحظات إضافية"
// تحتهم رمز الانضمام اللي بيدخله المعتمر (مش بـ Figma — اضغط للنسخ)
// بترجع true للي فتحها لو تغيّر إشي حتى يحدّث القوائم والأرقام
// -------------------------------------------------------------
class CompanyGroupDetailScreen extends StatefulWidget {
  final CompanyGroup group;
  final CompanyRepository repository;
  final CompanyTrip? trip;

  const CompanyGroupDetailScreen({super.key, required this.group, required this.repository, this.trip});

  @override
  State<CompanyGroupDetailScreen> createState() => _CompanyGroupDetailScreenState();
}

class _CompanyGroupDetailScreenState extends State<CompanyGroupDetailScreen> {
  late CompanyGroup _group = widget.group;
  bool _changed = false;

  /// قائمة المشرفين المفتوحة تحت كرت "تغيير المشرف" (null = مسكّرة)
  List<CompanySupervisor>? _menu;
  bool _assigning = false;

  Future<void> _members() async {
    final count = await CompanyController.openMembers(context, widget.repository, _group);
    if (count != null && mounted) {
      setState(() {
        _group = _group.copyWith(memberCount: count);
        _changed = true;
      });
    }
  }

  Future<void> _toggleMenu() async {
    if (_menu != null) return setState(() => _menu = null);
    try {
      final roster = await widget.repository.supervisors();
      if (!mounted) return;
      // الشركة لسا ما عندها مشرفين: مباشرة لصفحة "إضافة مشرف جديد"
      if (roster.isEmpty) return await _addNewSupervisor();
      setState(() => _menu = roster);
    } catch (e) {
      if (mounted) CompanyController.showError(context, e);
    }
  }

  Future<void> _assign(CompanySupervisor supervisor) async {
    setState(() {
      _menu = null;
      _assigning = true;
    });
    try {
      final updated = await widget.repository.assignSupervisor(_group.id, supervisor.email);
      if (!mounted) return;
      setState(() {
        _group = _group.copyWith(supervisorName: updated.supervisorName ?? supervisor.name, memberCount: updated.memberCount);
        _changed = true;
      });
    } catch (e) {
      if (mounted) CompanyController.showError(context, e);
    } finally {
      if (mounted) setState(() => _assigning = false);
    }
  }

  Future<void> _addNewSupervisor() async {
    setState(() => _menu = null);
    final added = await CompanyController.openAddSupervisor(context, widget.repository);
    if (added != null && mounted) await _assign(added);
  }

  Future<void> _openSupervisor() async {
    if (await CompanyController.openSupervisor(context, widget.repository, name: _group.supervisorName) && mounted) _changed = true;
  }

  void _copyCode() {
    if (_group.joinCode.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _group.joinCode));
    CompanyController.showMessage(context, CompanyGroupsText.codeCopied());
  }

  @override
  Widget build(BuildContext context) {
    final group = _group;
    final green = CompanyColors.green;
    final date = widget.trip?.departureDate;
    final hasSupervisor = group.supervisorName != null;
    final menu = _menu;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: FigmaPage(
        title: CompanyGroupsText.groupDetail(),
        titleRight: 349,
        chevronLeft: 367,
        body: (c) => [
          ...CompanyGroupCard.build(c, group, top: 125, withLink: false),
          // "مشرف المجموعة : ..." → صفحة المشرف (التحكم فيه)
          if (hasSupervisor) c.tapArea(left: 120, top: 125 + 62, width: 196, height: 30, onTap: _openSupervisor),

          // تاريخ الرحلة / المعتمرون
          ..._stat(c, left: 206, icon: 'ic_create_trip', iconLeft: 336, label: CompanyGroupsText.tripDate(), labelRight: 322, value: date == null ? '—' : '${date.day}/${date.month}/${date.year}', valueRight: 328),
          ..._stat(c, left: 19, icon: 'ic_groups', iconLeft: 149, label: CompanyGroupsText.pilgrims(hajj: group.hajj), labelRight: 141, value: '${group.memberCount}', valueRight: 122),

          // عرض جميع الاعضاء (أو إضافة لو فاضية)
          companyBox(c, left: 16, top: 350, width: 361, height: 53, radius: 10, color: CompanyColors.statCard, shadow: CompanyColors.greenShadow),
          c.rect(
            left: 16,
            top: 350,
            width: 361,
            height: 53,
            child: IgnorePointer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('$companyAssets/ic_groups.png', width: c.s.x(24), height: c.s.x(24), color: green),
                  SizedBox(width: c.s.x(8)),
                  Text(group.memberCount == 0 ? CompanyGroupsText.addMembers() : CompanyGroupsText.allMembers(), style: c.style(14, FigmaWeight.semiBold, green, lineHeight: null, letterSpacing: 0)),
                ],
              ),
            ),
          ),
          c.tapArea(left: 16, top: 350, width: 361, height: 53, onTap: _members),

          // رؤية الدردشة
          companyBox(c, left: 206, top: 419, width: 170.5, height: 73, color: CompanyColors.statCard, shadow: CompanyColors.greenShadow),
          c.image('assets/images/supervisor/ic_pen.png', left: 336, top: 444, width: 24, height: 24, color: green),
          FigmaLines.build(c, CompanyGroupsText.chat(), left: 208, top: 445, width: 120, style: c.style(14, FigmaWeight.semiBold, green), wrap: false),
          c.tapArea(left: 206, top: 419, width: 170.5, height: 73, onTap: () => CompanyController.comingSoon(context)),

          // تغيير المشرف / إضافة المشرف + السهم
          companyBox(c, left: 19, top: 419, width: 170.5, height: 73, color: CompanyColors.statCard, shadow: CompanyColors.greenShadow),
          c.image('$companyAssets/ic_supervisors.png', left: 149, top: 444, width: 24, height: 24, color: green),
          FigmaLines.build(c, hasSupervisor ? CompanyGroupsText.changeSupervisor() : CompanyGroupsText.addSupervisor(), left: 50, top: 445, width: 91, style: c.style(14, FigmaWeight.semiBold, green), wrap: false),
          c.rect(
            left: 30,
            top: 444,
            width: 24,
            height: 24,
            child: _assigning
                ? Padding(padding: EdgeInsets.all(c.s.x(3)), child: CircularProgressIndicator(strokeWidth: 2, color: green))
                : Icon(menu == null ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded, size: c.s.x(24), color: green),
          ),
          c.tapArea(left: 19, top: 419, width: 170.5, height: 73, onTap: _assigning ? () {} : _toggleMenu),

          // ملاحظات إضافية
          FigmaLines.build(c, CompanyGroupsText.notes(), left: 200, top: 516, width: 171, style: c.style(14, FigmaWeight.semiBold, green), wrap: false),
          companyBox(c, left: 16, top: 546, width: 361, height: 74, radius: 10, color: Colors.white, borderColor: const Color(0xFFE5E5EA)),
          FigmaLines.build(c, CompanyGroupsText.noNotes(), left: 32, top: 562, width: 329, style: c.style(13, FigmaWeight.sfRegular, CompanyColors.secondaryLabel), wrap: false),

          // رمز الانضمام
          if (group.joinCode.isNotEmpty) ...[
            companyBox(c, left: 16, top: 640, width: 361, height: 64, radius: 10, color: CompanyColors.card, shadow: CompanyColors.shadow),
            FigmaLines.build(c, CompanyGroupsText.joinCode(hajj: group.hajj), left: 120, top: 650, width: 241, style: c.style(12, FigmaWeight.sfRegular, CompanyColors.secondaryLabel), wrap: false),
            FigmaLines.build(c, group.joinCode, left: 120, top: 672, width: 241, style: c.style(18, FigmaWeight.sfBold, green, letterSpacing: 2), wrap: false),
            c.rect(left: 32, top: 660, width: 24, height: 24, child: Icon(Icons.copy_rounded, size: c.s.x(22), color: const Color(0xFF4C7A75))),
            c.tapArea(left: 16, top: 640, width: 361, height: 64, onTap: _copyCode),
          ],

          // قائمة المشرفين (Group 82: صفوف 145×36 تحت السهم) — فوق الملاحظات
          if (menu != null) ...[
            c.tapArea(left: 0, top: 59, width: 393, height: 800, onTap: () => setState(() => _menu = null)),
            for (final (i, s) in [...menu.map((s) => (s.name, () => _assign(s))), ('+ ${CompanyGroupsText.addSupervisor()}', _addNewSupervisor)].indexed) ...[
              companyBox(c, left: 30, top: 498 + i * 35.0, width: 145, height: 36, radius: 6, color: Colors.white, borderColor: green.withValues(alpha: 0.3), shadow: CompanyColors.shadow),
              FigmaLines.build(c, s.$1, left: 36, top: 505 + i * 35.0, width: 133, align: TextAlign.center, style: c.style(13, FigmaWeight.sfRegular, green), wrap: false),
              c.tapArea(left: 30, top: 498 + i * 35.0, width: 145, height: 36, onTap: s.$2),
            ],
          ],
        ],
      ),
    );
  }

  // كرت رقم (170.5×73 من y261): الأيقونة، العنوان (طرفه [labelRight] y278) والقيمة (طرفها [valueRight] y304)
  List<Widget> _stat(FigmaCanvas c, {required double left, required String icon, required double iconLeft, required String label, required double labelRight, required String value, required double valueRight}) {
    final green = CompanyColors.green;
    return [
      companyBox(c, left: left, top: 261, width: 170.5, height: 73, color: CompanyColors.statCard, shadow: CompanyColors.greenShadow),
      c.image('$companyAssets/$icon.png', left: iconLeft, top: 277, width: 24, height: 24, color: green),
      FigmaLines.build(c, label, left: labelRight - 120, top: 278, width: 120, style: c.style(14, FigmaWeight.semiBold, green), wrap: false),
      FigmaLines.build(c, value, left: valueRight - 120, top: 304, width: 120, style: c.style(16, FigmaWeight.semiBold, green), wrap: false),
    ];
  }
}
