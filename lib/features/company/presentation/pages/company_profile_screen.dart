import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_profile_text.dart';
import '../widgets/company_colors.dart';
import '../widgets/company_page.dart';

// -------------------------------------------------------------
// تبويب "الملف الشخصي" — Figma 27.Profile (393×852)
// دائرة الأفاتار → شارة الاسم → قسم "بيانات الحساب": (بيانات الشركة / معلومات التواصل)
//                              → قسم "إعدادات الحساب": (الإعدادات)
// -------------------------------------------------------------
class CompanyProfileScreen extends StatelessWidget {
  const CompanyProfileScreen({super.key});

  static const _teal = Color(0xFF4C7A75);

  @override
  Widget build(BuildContext context) {
    return CompanyPage(
      inShell: true,
      builder: (c) => [
        // ── أفاتار الشركة (دائرة فارغة) ──
        c.box(left: 157.5, top: 122.5, width: 79, height: 79, radius: 39.5, color: CompanyColors.cardInset),
        // أيقونة Building placeholder داخل الدائرة
        Positioned(
          top: c.s.y(122.5 - 59 + 17),
          left: c.s.x(393 - 157.5 - 79 + 17),
          child: Icon(Icons.business_rounded, size: c.s.x(45), color: _teal),
        ),

        // ── شارة الاسم (placeholder — لا يوجد اسم شركة بعد) ──
        c.box(left: 146, top: 279, width: 101, height: 21, radius: 10, color: CompanyColors.green),
        c.text(
          '',
          left: 146,
          top: 279,
          width: 101,
          height: 21,
          align: TextAlign.center,
          dy: 0,
          style: c.style(11, FigmaWeight.sfBold, Colors.white, lineHeight: null, letterSpacing: 0),
        ),

        // ── قسم "بيانات الحساب" ──
        c.box(left: 22, top: 320, width: 348, height: 32, radius: 10, color: _teal),
        c.text(
          CompanyProfileText.accountData(),
          left: 22,
          top: 320,
          width: 348,
          height: 32,
          align: TextAlign.center,
          dy: 0,
          style: c.style(14, FigmaWeight.sfBold, Colors.white, lineHeight: null, letterSpacing: 0),
        ),

        // بيانات الشركة (item 1)
        c.box(left: 24, top: 361, width: 340, height: 48, radius: 10, color: _teal),
        c.text(
          CompanyProfileText.companyData(),
          left: 24,
          top: 361,
          width: 280,
          height: 48,
          align: TextAlign.end,
          dy: 0,
          style: c.style(15, FigmaWeight.sfRegular, Colors.white, lineHeight: null, letterSpacing: 0),
        ),
        Positioned(
          top: c.s.y(361 - 59 + 13),
          left: c.s.x(393 - 24 - 340 + 12),
          child: Icon(Icons.chevron_left_rounded, size: c.s.x(22), color: Colors.white),
        ),
        c.tapArea(left: 24, top: 361, width: 340, height: 48, onTap: () => CompanyController.openCompanyData(context)),

        // معلومات التواصل (item 2)
        c.box(left: 24, top: 416, width: 340, height: 48, radius: 10, color: _teal),
        c.text(
          CompanyProfileText.contactInfo(),
          left: 24,
          top: 416,
          width: 280,
          height: 48,
          align: TextAlign.end,
          dy: 0,
          style: c.style(15, FigmaWeight.sfRegular, Colors.white, lineHeight: null, letterSpacing: 0),
        ),
        Positioned(
          top: c.s.y(416 - 59 + 13),
          left: c.s.x(393 - 24 - 340 + 12),
          child: Icon(Icons.chevron_left_rounded, size: c.s.x(22), color: Colors.white),
        ),
        c.tapArea(left: 24, top: 416, width: 340, height: 48, onTap: () => CompanyController.openContact(context)),

        // ── قسم "إعدادات الحساب" ──
        c.box(left: 21, top: 487, width: 348, height: 32, radius: 10, color: _teal),
        c.text(
          CompanyProfileText.accountSettings(),
          left: 21,
          top: 487,
          width: 348,
          height: 32,
          align: TextAlign.center,
          dy: 0,
          style: c.style(14, FigmaWeight.sfBold, Colors.white, lineHeight: null, letterSpacing: 0),
        ),

        // الإعدادات (item 3)
        c.box(left: 24, top: 529, width: 340, height: 48, radius: 10, color: _teal),
        c.text(
          CompanyProfileText.settings(),
          left: 24,
          top: 529,
          width: 280,
          height: 48,
          align: TextAlign.end,
          dy: 0,
          style: c.style(15, FigmaWeight.sfRegular, Colors.white, lineHeight: null, letterSpacing: 0),
        ),
        Positioned(
          top: c.s.y(529 - 59 + 13),
          left: c.s.x(393 - 24 - 340 + 12),
          child: Icon(Icons.chevron_left_rounded, size: c.s.x(22), color: Colors.white),
        ),
        c.tapArea(left: 24, top: 529, width: 340, height: 48, onTap: () => CompanyController.openSettings(context)),

        // الإعدادات (item 4 — 2nd from section bar 2, y=593)
        c.box(left: 24, top: 593, width: 340, height: 48, radius: 10, color: _teal),
        c.text(
          CompanyProfileText.changePassword(),
          left: 24,
          top: 593,
          width: 280,
          height: 48,
          align: TextAlign.end,
          dy: 0,
          style: c.style(15, FigmaWeight.sfRegular, Colors.white, lineHeight: null, letterSpacing: 0),
        ),
        Positioned(
          top: c.s.y(593 - 59 + 13),
          left: c.s.x(393 - 24 - 340 + 12),
          child: Icon(Icons.chevron_left_rounded, size: c.s.x(22), color: Colors.white),
        ),
        c.tapArea(left: 24, top: 593, width: 340, height: 48, onTap: () => CompanyController.comingSoon(context)),

        // تسجيل الخروج (item 5 — y=657)
        c.box(left: 24, top: 657, width: 340, height: 48, radius: 10, color: _teal),
        c.text(
          CompanyProfileText.logout(),
          left: 24,
          top: 657,
          width: 280,
          height: 48,
          align: TextAlign.end,
          dy: 0,
          style: c.style(15, FigmaWeight.sfRegular, Colors.white, lineHeight: null, letterSpacing: 0),
        ),
        Positioned(
          top: c.s.y(657 - 59 + 13),
          left: c.s.x(393 - 24 - 340 + 12),
          child: Icon(Icons.chevron_left_rounded, size: c.s.x(22), color: Colors.white),
        ),
        c.tapArea(left: 24, top: 657, width: 340, height: 48, onTap: () => CompanyController.logout(context)),
      ],
    );
  }
}
