import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_page.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_groups_text.dart';
import '../widgets/company_colors.dart';

// -------------------------------------------------------------
// "بيانات العضو" — Figma صفحة احد الاعضاء (393×852) → FigmaPage
// placeholder — البيانات تجي من الـ backend لما يتوفر
// -------------------------------------------------------------
class CompanyMemberPageScreen extends StatelessWidget {
  final String memberId;
  final String name;

  const CompanyMemberPageScreen({super.key, required this.memberId, required this.name});

  static const _teal = Color(0xFF4C7A75);

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: CompanyGroupsText.memberTitle(),
      titleRight: 349,
      chevronLeft: 367,
      body: (c) => [
        // أفاتار كبير
        c.box(left: 147, top: 130, width: 99, height: 99, radius: 49.5, color: CompanyColors.cardInset),
        Positioned(
          top: c.s.y(130 - 59 + 20),
          left: c.s.x(393 - 147 - 99 + 25),
          child: Icon(Icons.person_rounded, size: c.s.x(58), color: _teal),
        ),

        // الاسم
        c.text(
          name,
          left: 16,
          top: 249,
          width: 361,
          height: 30,
          align: TextAlign.center,
          dy: 0,
          style: c.style(20, FigmaWeight.sfBold, CompanyColors.green, lineHeight: null, letterSpacing: 0),
        ),

        // placeholder بيانات إضافية
        c.box(left: 16, top: 310, width: 361, height: 200, radius: 14, color: CompanyColors.card),
        c.text(
          '',
          left: 16,
          top: 310,
          width: 361,
          height: 200,
          align: TextAlign.center,
          style: c.style(14, FigmaWeight.sfRegular, CompanyColors.secondaryLabel, lineHeight: null, letterSpacing: 0),
        ),

        c.button(CompanyGroupsText.chat(), left: 16, top: 700, figmaSpacing: true, onTap: () => CompanyController.comingSoon(context)),
      ],
    );
  }
}
