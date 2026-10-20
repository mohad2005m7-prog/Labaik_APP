import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../domain/entities/company_group.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_groups_text.dart';
import '../widgets/company_colors.dart';

// -------------------------------------------------------------
// "تفاصيل المجموعة" — Figma تفاصيل المجموعة (393×852) → FigmaPage
// كرت بيانات المجموعة (تيل) + شريط الإجراءات (أعضاء / محادثة / تعديل)
// -------------------------------------------------------------
class CompanyGroupDetailScreen extends StatelessWidget {
  final CompanyGroup group;

  const CompanyGroupDetailScreen({super.key, required this.group});

  static const _teal = Color(0xFF4C7A75);

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: CompanyGroupsText.groupDetail(),
      titleRight: 349,
      chevronLeft: 367,
      body: (c) => [
        // ── كرت بيانات المجموعة (تيل) ──
        c.box(left: 16, top: 113, width: 361, height: 188, radius: 16, color: _teal),
        // صورة مصغّرة (70×70) — مركز أفقي (393-70)/2 = 161.5
        c.box(left: 161.5, top: 133, width: 70, height: 70, radius: 12, color: CompanyColors.cardInset),
        Positioned(
          top: c.s.y(133 - 59 + 16),
          left: c.s.x(393 - 161.5 - 70 + 20),
          child: Icon(Icons.group_rounded, size: c.s.x(38), color: _teal),
        ),
        // اسم المجموعة
        c.text(
          group.name,
          left: 16,
          top: 219,
          width: 361,
          height: 26,
          align: TextAlign.center,
          dy: 0,
          style: c.style(18, FigmaWeight.sfBold, Colors.white, lineHeight: null, letterSpacing: 0),
        ),
        // اسم الرحلة
        c.text(
          group.tripName,
          left: 16,
          top: 251,
          width: 361,
          height: 22,
          align: TextAlign.center,
          dy: 0,
          style: c.style(14, FigmaWeight.sfRegular, Colors.white.withValues(alpha: 0.8), lineHeight: null, letterSpacing: 0),
        ),
        // عدد الأعضاء
        c.text(
          '${group.memberCount} ${CompanyGroupsText.memberCount()}',
          left: 16,
          top: 278,
          width: 361,
          height: 22,
          align: TextAlign.center,
          dy: 0,
          style: c.style(13, FigmaWeight.sfRegular, Colors.white.withValues(alpha: 0.8), lineHeight: null, letterSpacing: 0),
        ),

        // ── شريط الإجراءات ──
        // زر الأعضاء
        _actionBtn(c, context, icon: Icons.people_rounded, label: CompanyGroupsText.members(), left: 22, top: 330, onTap: () => CompanyController.openMembers(context, group)),
        // زر المحادثة
        _actionBtn(c, context, icon: Icons.chat_bubble_outline_rounded, label: CompanyGroupsText.chat(), left: 156, top: 330, onTap: () => CompanyController.comingSoon(context)),
        // زر تعديل
        _actionBtn(c, context, icon: Icons.edit_outlined, label: CompanyGroupsText.editGroup(), left: 288, top: 330, onTap: () => CompanyController.comingSoon(context)),
      ],
    );
  }

  Widget _actionBtn(dynamic c, BuildContext context, {required IconData icon, required String label, required double left, required double top, required VoidCallback onTap}) {
    return Stack(children: [
      c.box(left: left, top: top, width: 83, height: 83, radius: 14, color: CompanyColors.card),
      Positioned(
        top: c.s.y(top - 59 + 14),
        left: c.s.x(393 - left - 83 + 26),
        child: Icon(icon, size: c.s.x(30), color: _teal),
      ),
      c.text(label, left: left, top: top + 50, width: 83, height: 30, align: TextAlign.center, dy: 0, style: c.style(12, FigmaWeight.sfRegular, CompanyColors.green, lineHeight: null, letterSpacing: 0)),
      c.tapArea(left: left, top: top, width: 83, height: 83, onTap: onTap),
    ]);
  }
}
