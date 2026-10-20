import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../domain/entities/company_group.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_groups_text.dart';
import '../widgets/company_colors.dart';
import '../widgets/company_search_field.dart';

// -------------------------------------------------------------
// "الأعضاء" — Figma (393×~700) → FigmaPage
// بحث + قائمة أعضاء (صف كل 53px) + زر "إضافة عضو"
// البيانات: placeholder (لا يوجد backend بعد)
// -------------------------------------------------------------
class CompanyMembersScreen extends StatelessWidget {
  final CompanyGroup group;

  const CompanyMembersScreen({super.key, required this.group});

  static const _firstRowTop = 153.0;

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: CompanyGroupsText.membersTitle(),
      titleRight: 349,
      chevronLeft: 367,
      body: (c) => [
        // حقل البحث
        c.rect(left: 24, top: 110, width: 345, height: 36, child: CompanySearchField(s: c.s, hint: CompanyGroupsText.searchMembers(), onChanged: (_) {})),

        // حالة فارغة — البيانات من الـ backend لسا ما انبنت
        c.text(
          CompanyGroupsText.empty(),
          left: 16,
          top: _firstRowTop + 8,
          width: 361,
          height: 22,
          align: TextAlign.center,
          style: c.style(14, FigmaWeight.sfRegular, const Color(0xFF717171), lineHeight: null, letterSpacing: 0),
        ),

        // زر إضافة عضو
        c.button(CompanyGroupsText.addMember(), left: 16, top: 680, figmaSpacing: true, onTap: () => CompanyController.comingSoon(context)),
      ],
    );
  }
}

// ── صف عضو واحد (للاستخدام مستقبلاً لما يتوفر الـ backend) ──
class CompanyMemberRow {
  static List<Widget> build(dynamic c, BuildContext context, {required String name, required String role, required double top, required VoidCallback onTap}) {
    return [
      // أفاتار (40×40)
      c.box(left: 24, top: top + 6.5, width: 40, height: 40, radius: 20, color: CompanyColors.cardInset),
      Positioned(
        top: c.s.y(top - 59 + 6.5 + 9),
        left: c.s.x(393 - 24 - 40 + 11),
        child: Icon(Icons.person_rounded, size: c.s.x(22), color: const Color(0xFF4C7A75)),
      ),
      // الاسم
      c.text(name, left: 76, top: top + 10, width: 240, height: 20, align: TextAlign.end, style: c.style(15, FigmaWeight.semiBold, CompanyColors.green, lineHeight: null, letterSpacing: 0)),
      // الدور
      c.text(role, left: 76, top: top + 33, width: 200, height: 18, align: TextAlign.end, style: c.style(12, FigmaWeight.sfRegular, CompanyColors.secondaryLabel, lineHeight: null, letterSpacing: 0)),
      c.tapArea(left: 16, top: top, width: 361, height: 53, onTap: onTap),
    ];
  }
}
