import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_page.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_profile_text.dart';
import '../widgets/company_colors.dart';

// -------------------------------------------------------------
// "الإعدادات" — Figma 12.Settings (393×938) → FigmaPage frameHeight:938
// مخطط: أيقونة/صورة مسجد (placeholder) → عنصران مستقلان → كرتان من عنصرين → زر تسجيل الخروج
// -------------------------------------------------------------
class CompanySettingsScreen extends StatelessWidget {
  const CompanySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: CompanyProfileText.settingsTitle(),
      titleRight: 349,
      chevronLeft: 367,
      frameHeight: 938,
      body: (c) => [
        // ── placeholder الرسم (مسجد/كعبة) — y113–300 ──
        c.box(left: 87, top: 113, width: 219, height: 167, radius: 16, color: CompanyColors.cardInset),
        Positioned(
          top: c.s.y(113 - 59 + 40),
          left: c.s.x(393 - 87 - 219 + 70),
          child: Icon(Icons.mosque_rounded, size: c.s.x(80), color: const Color(0xFF4C7A75)),
        ),

        // ── عناصر مستقلة ──
        _item(c, context, top: 343.5, label: CompanyProfileText.changePassword(), onTap: () => CompanyController.comingSoon(context)),
        _item(c, context, top: 399.5, label: CompanyProfileText.notifications(), onTap: () => CompanyController.comingSoon(context)),

        // ── كرت 1 (x=16, y=512, 361×114 rx=12) ──
        c.box(left: 16, top: 512, width: 361, height: 114, radius: 12, color: Colors.white, hasShadow: true),
        _itemInCard(c, context, top: 512.5, label: CompanyProfileText.language(), onTap: () => CompanyController.comingSoon(context)),
        _itemInCard(c, context, top: 569.5, label: CompanyProfileText.about(), onTap: () => CompanyController.comingSoon(context)),

        // ── كرت 2 (x=16, y=683, 361×114 rx=12) ──
        c.box(left: 16, top: 683, width: 361, height: 114, radius: 12, color: Colors.white, hasShadow: true),
        _itemInCard(c, context, top: 683.5, label: CompanyProfileText.privacyPolicy(), onTap: () => CompanyController.comingSoon(context)),
        _itemInCard(c, context, top: 741.5, label: CompanyProfileText.termsOfUse(), onTap: () => CompanyController.comingSoon(context)),

        // ── زر تسجيل الخروج (خلفية حمراء فاتحة) ──
        c.box(left: 19.5, top: 821.5, width: 357, height: 49, radius: 13.5, color: const Color(0xFFFEECEB)),
        c.text(
          CompanyProfileText.logout(),
          left: 19.5,
          top: 821.5,
          width: 357,
          height: 49,
          align: TextAlign.center,
          dy: 0,
          style: c.style(17, FigmaWeight.semiBold, const Color(0xFFD32F2F), lineHeight: null, letterSpacing: 0),
        ),
        c.tapArea(left: 19.5, top: 821.5, width: 357, height: 49, onTap: () => CompanyController.logout(context)),
      ],
    );
  }

  // عنصر مستقل (بدون بطاقة)
  Widget _item(dynamic c, BuildContext context, {required double top, required String label, required VoidCallback onTap}) {
    return Stack(
      children: [
        c.box(left: 17.5, top: top, width: 358, height: 55, radius: 9.5, color: Colors.white, hasShadow: true),
        c.text(label, left: 17.5, top: top, width: 316, height: 55, align: TextAlign.end, dy: 0, style: c.style(15, FigmaWeight.sfRegular, CompanyColors.green, lineHeight: null, letterSpacing: 0)),
        Positioned(
          top: c.s.y(top - 59 + 16),
          left: c.s.x(393 - 17.5 - 358 + 14),
          child: Icon(Icons.chevron_left_rounded, size: c.s.x(22), color: CompanyColors.green),
        ),
        c.tapArea(left: 17.5, top: top, width: 358, height: 55, onTap: onTap),
      ],
    );
  }

  // عنصر داخل بطاقة
  Widget _itemInCard(dynamic c, BuildContext context, {required double top, required String label, required VoidCallback onTap}) {
    return Stack(
      children: [
        c.text(label, left: 30, top: top, width: 300, height: 56, align: TextAlign.end, dy: 0, style: c.style(15, FigmaWeight.sfRegular, CompanyColors.green, lineHeight: null, letterSpacing: 0)),
        Positioned(
          top: c.s.y(top - 59 + 17),
          left: c.s.x(393 - 30 - 300 - 20),
          child: Icon(Icons.chevron_left_rounded, size: c.s.x(22), color: CompanyColors.green),
        ),
        c.tapArea(left: 16, top: top, width: 361, height: 56, onTap: onTap),
      ],
    );
  }
}
