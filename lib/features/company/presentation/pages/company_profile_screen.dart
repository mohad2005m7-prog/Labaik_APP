import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_lines.dart';
import '../../../supervisor/presentation/widgets/supervisor_widgets.dart';
import '../controllers/company_controller.dart';
import '../cubits/company_profile_cubit.dart';
import '../../../../core/l10n/countries.dart';
import '../l10n/company_profile_text.dart';
import '../widgets/company_box.dart';
import '../widgets/company_colors.dart';
import '../widgets/company_page.dart';

// -------------------------------------------------------------
// تبويب "الملف الشخصي" — مطابقة لـ Figma 27.Profile (618:3451)
// الترس (24,68) → الإعدادات | "ملفي الشخصي" | الشعار 80 | اسم الشركة والبريد | شارة "الحساب مفعّل"
// شريط "بيانات الشركة" (القلم → تعديل) + رقم الترخيص / الدولة / المدينة
// "إدارة الحساب": معلومات التواصل / إدارة المشرفين / المساعدة والدعم
// البيانات من GET /company/me
// -------------------------------------------------------------
class CompanyProfileScreen extends StatelessWidget {
  const CompanyProfileScreen({super.key});

  static const _teal = Color(0xFF4C7A75);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyProfileCubit, CompanyProfileState>(
      builder: (context, state) {
        final p = state.profile;
        return CompanyPage(
          inShell: true,
          builder: (c) => [
            // الترس → الإعدادات
            c.image('assets/images/supervisor/ic_gear.png', left: 24, top: 68, width: 24, height: 24, color: CompanyColors.green),
            c.tapArea(left: 16, top: 60, width: 40, height: 40, onTap: () => CompanyController.openSettings(context)),
            c.text(CompanyProfileText.title(), left: 96, top: 62, width: 201, height: 36, align: TextAlign.center, dy: 0, style: c.style(24, FigmaWeight.sfBold, CompanyColors.green, lineHeight: null, letterSpacing: 0)),

            // الشعار (دائرة 80 بحد خفيف) — بلا شعار: أيقونة مبنى
            companyBox(c, left: 157, top: 122, width: 80, height: 80, color: CompanyColors.cardInset, circle: true, borderColor: const Color(0xFFE5E5EA)),
            if (p?.logoUrl != null)
              c.rect(left: 158, top: 123, width: 78, height: 78, child: ClipOval(child: Image.network(p!.logoUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink())))
            else
              c.rect(left: 157, top: 122, width: 80, height: 80, child: Icon(Icons.apartment_rounded, size: c.s.x(42), color: _teal)),

            if (p == null && state.failed) ...[
              c.text(CompanyProfileText.loadFailed(), left: 16, top: 220, width: 361, height: 44, align: TextAlign.center, dy: 0, style: c.style(13, FigmaWeight.sfRegular, CompanyColors.secondaryLabel, lineHeight: null, letterSpacing: 0)),
              c.tapArea(left: 16, top: 215, width: 361, height: 54, onTap: () => context.read<CompanyProfileCubit>().load()),
            ],
            if (p != null) ...[
              c.text(p.name, left: 16, top: 220, width: 361, height: 24, align: TextAlign.center, dy: 0, style: c.style(18, FigmaWeight.sfBold, CompanyColors.green, lineHeight: null, letterSpacing: 0)),
              if (p.email != null) c.text(p.email!, left: 16, top: 252, width: 361, height: 19, align: TextAlign.center, dy: 0, style: c.style(14, FigmaWeight.poppinsRegular, CompanyColors.green, lineHeight: null, letterSpacing: 0.4)),
            ],

            // شارة "الحساب مفعّل" ✓
            companyBox(c, left: 146, top: 279, width: 101, height: 21, radius: 10.5, color: CompanyColors.green),
            FigmaLines.build(c, CompanyProfileText.active(), left: 150, top: 279, width: 74, align: TextAlign.center, style: c.style(11, FigmaWeight.sfRegular, Colors.white, lineHeight: 21), lineHeight: 21, wrap: false),
            c.rect(left: 226, top: 283, width: 14, height: 14, child: Icon(Icons.check_circle_outline_rounded, size: c.s.x(13.5), color: Colors.white)),

            // شريط "بيانات الشركة" + القلم → تعديل
            companyBox(c, left: 22, top: 320, width: 348, height: 32, radius: 8, color: _teal),
            FigmaLines.build(c, CompanyProfileText.companyData(), left: 200, top: 325, width: 163, style: c.style(14, FigmaWeight.semiBold, Colors.white, lineHeight: 22), wrap: false),
            c.image('assets/images/supervisor/ic_pen.png', left: 32, top: 324, width: 24, height: 24, color: Colors.white),
            c.tapArea(left: 22, top: 316, width: 348, height: 40, onTap: () => CompanyController.openCompanyData(context)),

            ..._info(c, CompanyProfileText.licenseNumber(), p?.licenseNumber, top: 368),
            ..._info(c, CompanyProfileText.country(), CompanyCountries.label(p?.country), top: 402),
            ..._info(c, CompanyProfileText.city(), p?.city, top: 441),

            // "إدارة الحساب"
            companyBox(c, left: 21, top: 487, width: 348, height: 32, radius: 8, color: _teal),
            FigmaLines.build(c, CompanyProfileText.accountManagement(), left: 200, top: 492, width: 163, style: c.style(14, FigmaWeight.semiBold, Colors.white, lineHeight: 22), wrap: false),
            ..._row(c, CompanyProfileText.contactInfo(), top: 529, onTap: () => CompanyController.openContact(context)),
            ..._row(c, CompanyProfileText.supervisors(), top: 593, onTap: () => CompanyController.openSupervisors(context)),
            ..._row(c, CompanyProfileText.help(), top: 657, onTap: () => CompanyController.openHelp(context)),
          ],
        );
      },
    );
  }

  // "رقم الترخيص:   LAB-2026-014" — العنوان طرفه x368 والقيمة طرفها x255
  static List<Widget> _info(FigmaCanvas c, String label, String? value, {required double top}) => [
        FigmaLines.build(c, label, left: 255, top: top, width: 113, style: c.style(14, FigmaWeight.semiBold, CompanyColors.green), wrap: false),
        FigmaLines.build(c, value ?? '—', left: 100, top: top + 1, width: 155, style: c.style(13, FigmaWeight.sfRegular, CompanyColors.green), wrap: false),
      ];

  // صف 340×48 أبيض بظل — النص طرفه x356 والسهم ‹ يسار (x36)
  static List<Widget> _row(FigmaCanvas c, String label, {required double top, required VoidCallback onTap}) => [
        companyBox(c, left: 24, top: top, width: 340, height: 48, radius: 10, color: Colors.white, shadow: CompanyColors.shadow),
        FigmaLines.build(c, label, left: 80, top: top + 14, width: 276, style: c.style(15, FigmaWeight.sfRegular, CompanyColors.green), wrap: false),
        ...supChevron(c, left: 36, top: top + 12, color: CompanyColors.green),
        c.tapArea(left: 24, top: top, width: 340, height: 48, onTap: onTap),
      ];
}
