import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../domain/entities/company_group.dart';
import '../../domain/repositories/company_repository.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_forms_text.dart';
import '../l10n/company_groups_text.dart';
import '../widgets/company_colors.dart';

// -------------------------------------------------------------
// "تفاصيل المجموعة" — Figma تفاصيل المجموعة (393×852) → FigmaPage
// كرت بيانات المجموعة (تيل) + رمز الانضمام (المعتمر بيدخله أو بيمسحه حتى ينضم — اضغط للنسخ)
// + المشرف + شريط الإجراءات (أعضاء / محادثة / المشرف)
// بترجع true للي فتحها لو تغيّر إشي (عضو أو مشرف) حتى يحدّث القوائم
// -------------------------------------------------------------
class CompanyGroupDetailScreen extends StatefulWidget {
  final CompanyGroup group;
  final CompanyRepository repository;

  const CompanyGroupDetailScreen({super.key, required this.group, required this.repository});

  @override
  State<CompanyGroupDetailScreen> createState() => _CompanyGroupDetailScreenState();
}

class _CompanyGroupDetailScreenState extends State<CompanyGroupDetailScreen> {
  static const _teal = Color(0xFF4C7A75);

  late CompanyGroup _group = widget.group;
  bool _changed = false;

  Future<void> _members() async {
    final added = await CompanyController.openMembers(context, widget.repository, _group);
    if (added) _changed = true;
  }

  Future<void> _supervisor() async {
    final updated = await CompanyController.assignSupervisor(context, widget.repository, _group);
    if (updated != null && mounted) {
      setState(() {
        _group = updated.tripName.isEmpty ? _group.copyWith(supervisorName: updated.supervisorName, memberCount: updated.memberCount) : updated;
        _changed = true;
      });
    }
  }

  void _copyCode() {
    if (_group.joinCode.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _group.joinCode));
    CompanyController.showMessage(context, CompanyFormsText.codeCopied());
  }

  @override
  Widget build(BuildContext context) {
    final group = _group;
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
          // ── كرت بيانات المجموعة (تيل) ──
          c.box(left: 16, top: 113, width: 361, height: 188, radius: 16, color: _teal),
          c.box(left: 161.5, top: 133, width: 70, height: 70, radius: 12, color: CompanyColors.cardInset),
          c.rect(left: 161.5, top: 133, width: 70, height: 70, child: Icon(Icons.group_rounded, size: c.s.x(38), color: _teal)),
          c.text(group.name, left: 16, top: 219, width: 361, height: 26, align: TextAlign.center, dy: 0, style: c.style(18, FigmaWeight.sfBold, Colors.white, lineHeight: null, letterSpacing: 0)),
          c.text(group.tripName, left: 16, top: 251, width: 361, height: 22, align: TextAlign.center, dy: 0, style: c.style(14, FigmaWeight.sfRegular, Colors.white.withValues(alpha: 0.8), lineHeight: null, letterSpacing: 0)),
          c.text('${group.memberCount} ${CompanyGroupsText.memberCount()}', left: 16, top: 278, width: 361, height: 22, align: TextAlign.center, dy: 0, style: c.style(13, FigmaWeight.sfRegular, Colors.white.withValues(alpha: 0.8), lineHeight: null, letterSpacing: 0)),

          // ── رمز الانضمام (اضغط للنسخ) ──
          c.box(left: 16, top: 317, width: 361, height: 64, radius: 14, color: CompanyColors.card),
          c.text(CompanyFormsText.joinCode(), left: 120, top: 327, width: 241, height: 20, align: TextAlign.start, dy: 0, style: c.style(13, FigmaWeight.sfRegular, CompanyColors.secondaryLabel, lineHeight: null, letterSpacing: 0)),
          c.text(group.joinCode, left: 120, top: 348, width: 241, height: 26, align: TextAlign.start, dy: 0, style: c.style(20, FigmaWeight.sfBold, CompanyColors.green, lineHeight: null, letterSpacing: 2)),
          c.rect(left: 32, top: 329, width: 40, height: 40, child: Icon(Icons.copy_rounded, size: c.s.x(22), color: _teal)),
          c.tapArea(left: 16, top: 317, width: 361, height: 64, onTap: _copyCode),

          // ── المشرف ──
          c.text(
            group.supervisorName == null ? CompanyFormsText.noSupervisor() : CompanyFormsText.supervisorLine(group.supervisorName!),
            left: 16,
            top: 393,
            width: 361,
            height: 22,
            align: TextAlign.start,
            dy: 0,
            style: c.style(14, FigmaWeight.semiBold, group.supervisorName == null ? const Color(0xFFD32F2F) : CompanyColors.green, lineHeight: null, letterSpacing: 0),
          ),

          // ── شريط الإجراءات ──
          ..._actionBtn(c, icon: Icons.people_rounded, label: CompanyGroupsText.members(), left: 288, top: 430, onTap: _members),
          ..._actionBtn(c, icon: Icons.chat_bubble_outline_rounded, label: CompanyGroupsText.chat(), left: 155, top: 430, onTap: () => CompanyController.comingSoon(context)),
          ..._actionBtn(c, icon: Icons.manage_accounts_outlined, label: CompanyFormsText.supervisorAction(), left: 22, top: 430, onTap: _supervisor),
        ],
      ),
    );
  }

  List<Widget> _actionBtn(FigmaCanvas c, {required IconData icon, required String label, required double left, required double top, required VoidCallback onTap}) => [
        c.box(left: left, top: top, width: 83, height: 83, radius: 14, color: CompanyColors.card),
        c.rect(left: left, top: top + 12, width: 83, height: 32, child: Icon(icon, size: c.s.x(30), color: _teal)),
        c.text(label, left: left, top: top + 50, width: 83, height: 30, align: TextAlign.center, dy: 0, style: c.style(12, FigmaWeight.sfRegular, CompanyColors.green, lineHeight: null, letterSpacing: 0)),
        c.tapArea(left: left, top: top, width: 83, height: 83, onTap: onTap),
      ];
}
