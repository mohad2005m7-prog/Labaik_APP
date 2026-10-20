import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/l10n/app_language.dart';
import '../../../../core/l10n/common_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../supervisor/presentation/widgets/supervisor_colors.dart';
import '../../../supervisor/presentation/widgets/supervisor_page.dart';
import '../../../supervisor/presentation/widgets/supervisor_widgets.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_profile_text.dart';

// -------------------------------------------------------------
// الإعدادات — مطابقة لـ Figma "12.Settings" للشركة (685:4306، إطار 938) — نفس تصميم إعدادات المشرف
// الحساب: تعديل بيانات الشركة / تغيير كلمة المرور
// التفضيلات: إعدادات الإشعارات (مفتاح محفوظ) / لغة التطبيق (عربي - English)
// أخرى: الشروط والأحكام والسياسات / مركز المساعدة والدعم + تسجيل الخروج
// -------------------------------------------------------------
class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({super.key});

  static const notificationsKey = 'company_notifications_enabled';

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (mounted) setState(() => _notifications = p.getBool(CompanySettingsScreen.notificationsKey) ?? true);
    });
  }

  void _toggleNotifications() {
    setState(() => _notifications = !_notifications);
    SharedPreferences.getInstance().then((p) => p.setBool(CompanySettingsScreen.notificationsKey, _notifications));
  }

  Future<void> _pickLanguage() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (code, name) in [('ar', CommonText.arabic.ar), ('en', CommonText.english.en)])
              ListTile(
                title: Text(name, style: const TextStyle(fontFamily: 'NotoSansArabic', fontSize: 16, color: SupColors.green)),
                trailing: code == AppLanguage.code ? const Icon(Icons.check, color: SupColors.green) : null,
                onTap: () => Navigator.pop(context, code),
              ),
          ],
        ),
      ),
    );
    if (picked != null && picked != AppLanguage.code) {
      await AppLanguage.change(picked);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SupervisorPage(
      frameHeight: 938,
      builder: (c) => [
        c.image('$supAssets/logo.png', left: 144, top: 112, width: 106, height: 138),
        c.text(CompanyProfileText.settingsTitle(), left: 96, top: 257, width: 205, height: 29, align: TextAlign.center, style: supText(c, 24, FigmaWeight.sfBold, SupColors.green)),

        _section(c, CompanyProfileText.sectionAccount(), top: 301, right: 375),
        ..._row(c, const Rect.fromLTWH(17, 343, 359, 56), CompanyProfileText.editCompany(), textTop: 355.5, textRight: 333.5, icon: ('ic_set_user', const Rect.fromLTWH(342, 360, 18, 22)), arrowLeft: 30, onTap: () => CompanyController.openCompanyData(context)),
        ..._row(c, const Rect.fromLTWH(17, 399, 359, 56), CompanyProfileText.changePassword(), textTop: 412.5, textRight: 333.5, icon: ('ic_set_lock', const Rect.fromLTWH(343, 416, 19, 22)), arrowLeft: 29.5, onTap: () => CompanyController.changePassword(context)),

        _section(c, CompanyProfileText.sectionPreferences(), top: 470, right: 376),
        ..._row(c, const Rect.fromLTWH(16, 512, 361, 57), CompanyProfileText.notifications(), textTop: 529.5, textRight: 344, icon: ('ic_set_bell', const Rect.fromLTWH(349, 528.5, 20, 23)), onTap: _toggleNotifications),
        c.rect(left: 35, top: 528.5, width: 48, height: 24, child: _Switch(c: c, on: _notifications)),
        ..._row(c, const Rect.fromLTWH(16, 569, 361, 57), CompanyProfileText.appLanguage(), textTop: 587.5, textRight: 341, icon: ('ic_set_globe', const Rect.fromLTWH(346, 585.5, 24, 24)), onTap: _pickLanguage),
        c.text('${(AppLanguage.code == 'ar' ? CommonText.arabic : CommonText.english)()} ›', left: 30, top: 589, width: 42, height: 16, style: supText(c, 13, FigmaWeight.poppinsRegular, SupColors.languageValue)),

        _section(c, CompanyProfileText.sectionOther(), top: 641, right: 376),
        ..._row(c, const Rect.fromLTWH(16, 683, 361, 58), CompanyProfileText.terms(), textTop: 701.5, textRight: 341, icon: ('ic_set_clipboard', const Rect.fromLTWH(348.5, 701.5, 21, 21)), arrowLeft: 31, onTap: () => CompanyController.openTerms(context)),
        ..._row(c, const Rect.fromLTWH(16, 741, 361, 56), CompanyProfileText.helpCenter(), textTop: 758, textRight: 340, icon: ('ic_set_help', const Rect.fromLTWH(347, 758, 22, 22)), arrowLeft: 32, onTap: () => CompanyController.openHelp(context)),

        c.box(left: 19, top: 821, width: 358, height: 50, color: SupColors.redFill, radius: 14, borderColor: SupColors.red),
        c.text(CompanyProfileText.logout(), left: 19, top: 835.5, width: 358, height: 20, align: TextAlign.center, style: supText(c, 16.75, FigmaWeight.sfRegular, SupColors.red)),
        c.tapArea(left: 19, top: 821, width: 358, height: 50, onTap: () => CompanyController.logout(context)),

        ...supBackArrow(c, context, left: 358, top: 64, trailing: true, color: Colors.black),
      ],
    );
  }

  Widget _section(FigmaCanvas c, String title, {required double top, required double right}) =>
      c.text(title, left: 200, top: top, width: right - 200, height: 19, style: supText(c, 16, FigmaWeight.sfBold, SupColors.green));

  // صف: حد #1F3B2E — radius 14 — النص SF Compact Bold 16 رمادي — الأيقونة يمين والمثلث الصغير يسار
  List<Widget> _row(FigmaCanvas c, Rect r, String label, {required double textTop, required double textRight, required (String, Rect) icon, double? arrowLeft, required VoidCallback onTap}) {
    final (asset, iconRect) = icon;
    return [
      c.box(left: r.left, top: r.top, width: r.width, height: r.height, radius: 14, borderColor: SupColors.green),
      c.image('$supAssets/$asset.png', left: iconRect.left, top: iconRect.top, width: iconRect.width, height: iconRect.height),
      c.text(label, left: 100, top: textTop, width: textRight - 100, height: 19, style: supText(c, 16, FigmaWeight.sfBold, SupColors.grey)),
      if (arrowLeft != null) c.rect(left: arrowLeft, top: r.top + r.height / 2 - 4, width: 4, height: 8, child: const _Triangle()),
      c.tapArea(left: r.left, top: r.top, width: r.width, height: r.height, onTap: onTap),
    ];
  }
}

class _Triangle extends StatelessWidget {
  const _Triangle();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _TrianglePainter(pointLeft: Directionality.of(context) == TextDirection.rtl));
}

class _TrianglePainter extends CustomPainter {
  final bool pointLeft;

  const _TrianglePainter({required this.pointLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final path = pointLeft
        ? (Path()..moveTo(size.width, 0)..lineTo(0, size.height / 2)..lineTo(size.width, size.height)..close())
        : (Path()..moveTo(0, 0)..lineTo(size.width, size.height / 2)..lineTo(0, size.height)..close());
    canvas.drawPath(path, Paint()..color = SupColors.green..isAntiAlias = true);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.pointLeft != pointLeft;
}

/// مفتاح الإشعارات 48×24 — مفعّل: أخضر والدائرة البيضا لجهة النهاية
class _Switch extends StatelessWidget {
  final FigmaCanvas c;
  final bool on;

  const _Switch({required this.c, required this.on});

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(color: on ? const Color(0xFF1E382C) : SupColors.avatarPlaceholder, borderRadius: BorderRadius.circular(s.x(12))),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        alignment: on ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: s.x(4)),
          child: Container(width: s.x(20), height: s.x(20), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        ),
      ),
    );
  }
}
