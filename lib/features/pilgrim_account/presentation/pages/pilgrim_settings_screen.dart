import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/common_text.dart';
import '../../../../core/l10n/tx.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../help_center/presentation/controllers/help_center_controller.dart';
import '../../../terms/presentation/controllers/terms_controller.dart';
import '../../domain/repositories/pilgrim_account_repository.dart';
import '../controllers/pilgrim_account_controller.dart';
import '../cubits/pilgrim_settings_cubit.dart';
import '../l10n/pilgrim_settings_text.dart';
import '../widgets/pilgrim_page.dart';

// -------------------------------------------------------------
// إعدادات المعتمر — مطابقة لـ Figma "12.Settings" (96:1044، إطار 938 فبتتمرر 86)
// منفصلة عن إعدادات المشرف: بياناتها وإشعاراتها لحساب المعتمر، وروابطها لشاشاته هو
// الحساب: تعديل البيانات الشخصية / تغيير كلمة المرور — التفضيلات: الإشعارات / اللغة
// أخرى: الشروط والأحكام والسياسات / مركز المساعدة (تبويب مركز المساعدة) — تسجيل الخروج
// -------------------------------------------------------------
class PilgrimSettingsScreen extends StatelessWidget {
  final PilgrimAccountRepository repository;

  const PilgrimSettingsScreen({super.key, required this.repository});

  static const _green = Color(0xFF1F3B2E);
  static const _grey = Color(0xFF717171);
  static const _languageValue = Color(0xFF6E6B6B);
  static const _red = Color(0xFFF44336);
  static const _redFill = Color(0xFFFEECEB);
  // ملفات الأيقونات والشعار نفسها المستخدمة بإعدادات المشرف (نفس التصميم)
  static const _assets = 'assets/images/supervisor';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PilgrimSettingsCubit(repository)..load(),
      child: BlocBuilder<PilgrimSettingsCubit, PilgrimSettingsState>(
        builder: (context, state) {
          final cubit = context.read<PilgrimSettingsCubit>();
          return PilgrimPage(
            frameHeight: 938,
            builder: (c) => [
              c.image('$_assets/logo.png', left: 144, top: 112, width: 106, height: 138),
              c.text(PilgrimSettingsText.title(), left: 96, top: 257, width: 205, height: 29, align: TextAlign.center, style: _text(c, 24, FigmaWeight.sfBold, _green)),

              _section(c, PilgrimSettingsText.sectionAccount, top: 301, right: 375),
              ..._row(c, const Rect.fromLTWH(17, 343, 359, 56), PilgrimSettingsText.editPersonalData, textTop: 355.5, textRight: 333.5, icon: ('ic_set_user', const Rect.fromLTWH(342, 360, 18, 22)), arrowLeft: 30, onTap: () => PilgrimAccountController.openEditProfile(context)),
              ..._row(c, const Rect.fromLTWH(17, 399, 359, 56), PilgrimSettingsText.changePassword, textTop: 412.5, textRight: 333.5, icon: ('ic_set_lock', const Rect.fromLTWH(343, 416, 19, 22)), arrowLeft: 29.5, onTap: () => PilgrimAccountController.changePassword(context)),

              _section(c, PilgrimSettingsText.sectionPreferences, top: 470, right: 376),
              ..._row(c, const Rect.fromLTWH(16, 512, 361, 57), PilgrimSettingsText.notifications, textTop: 529.5, textRight: 344, icon: ('ic_set_bell', const Rect.fromLTWH(349, 528.5, 20, 23)), onTap: cubit.toggleNotifications),
              c.rect(left: 35, top: 528.5, width: 48, height: 24, child: IgnorePointer(child: _Switch(c: c, on: state.notifications))),
              ..._row(c, const Rect.fromLTWH(16, 569, 361, 57), PilgrimSettingsText.appLanguage, textTop: 587.5, textRight: 341, icon: ('ic_set_globe', const Rect.fromLTWH(346, 585.5, 24, 24)), onTap: () => _pickLanguage(context, cubit)),
              // "العربية ‹" — #6E6B6B
              c.text('${(state.language == 'ar' ? CommonText.arabic : CommonText.english)()} ›', left: 30, top: 589, width: 42, height: 16, style: _text(c, 13, FigmaWeight.poppinsRegular, _languageValue)),

              _section(c, PilgrimSettingsText.sectionOther, top: 641, right: 376),
              ..._row(c, const Rect.fromLTWH(16, 683, 361, 58), PilgrimSettingsText.terms, textTop: 701.5, textRight: 341, icon: ('ic_set_clipboard', const Rect.fromLTWH(348.5, 701.5, 21, 21)), arrowLeft: 31, onTap: () => TermsController.open(context)),
              ..._row(c, const Rect.fromLTWH(16, 741, 361, 56), PilgrimSettingsText.helpCenter, textTop: 758, textRight: 340, icon: ('ic_set_help', const Rect.fromLTWH(347, 758, 22, 22)), arrowLeft: 32, onTap: () => HelpCenterController.open(context)),

              // تسجيل الخروج: #FEECEB — حد #F44336 — radius 14 — نص أحمر بالنص
              c.box(left: 19, top: 821, width: 358, height: 50, color: _redFill, radius: 14, borderColor: _red),
              c.text(PilgrimSettingsText.logout(), left: 19, top: 835.5, width: 358, height: 20, align: TextAlign.center, style: _text(c, 16.75, FigmaWeight.sfRegular, _red)),
              c.tapArea(left: 19, top: 821, width: 358, height: 50, onTap: () => PilgrimAccountController.logout(context)),

              ..._back(c, context),
            ],
          );
        },
      ),
    );
  }

  TextStyle _text(FigmaCanvas c, double size, double weight, Color color) => c.style(size, weight, color, lineHeight: null, letterSpacing: 0);

  // سهم الرجوع (Group 2 بـ Figma): يمين الشاشة ">" بالعربي، وبالإنجليزي بينعكس يسار "<"
  List<Widget> _back(FigmaCanvas c, BuildContext context) {
    final s = c.s;
    return [
      PositionedDirectional(
        start: s.x(393 - 358 - 18),
        top: s.y(64 - c.originTop + 12) - s.x(12),
        child: IgnorePointer(
          child: Transform.flip(
            flipX: Directionality.of(context) == TextDirection.rtl,
            child: Image.asset('assets/images/field_mode/ic_back.png', width: s.x(18), height: s.x(24), color: Colors.black, colorBlendMode: BlendMode.srcIn),
          ),
        ),
      ),
      PositionedDirectional(
        start: s.x(393 - 358 - 18 - 7),
        top: s.y(64 - 9 - c.originTop),
        width: s.x(32),
        height: s.y(42),
        child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.maybePop(context)),
      ),
    ];
  }

  // عنوان القسم — SF Compact Bold 16 — طرفه [right]
  Widget _section(FigmaCanvas c, Tx title, {required double top, required double right}) {
    return c.text(title(), left: 200, top: top, width: right - 200, height: 19, style: _text(c, 16, FigmaWeight.sfBold, _green));
  }

  // صف: حد #1F3B2E — radius 14 — النص SF Compact Bold 16 رمادي — الأيقونة يمين والمثلث الصغير يسار
  List<Widget> _row(FigmaCanvas c, Rect r, Tx label, {required double textTop, required double textRight, required (String, Rect) icon, double? arrowLeft, required VoidCallback onTap}) {
    final (asset, iconRect) = icon;
    return [
      c.box(left: r.left, top: r.top, width: r.width, height: r.height, radius: 14, borderColor: _green),
      c.image('$_assets/$asset.png', left: iconRect.left, top: iconRect.top, width: iconRect.width, height: iconRect.height),
      c.text(label(), left: 100, top: textTop, width: textRight - 100, height: 19, style: _text(c, 16, FigmaWeight.sfBold, _grey)),
      if (arrowLeft != null) c.rect(left: arrowLeft, top: r.top + r.height / 2 - 4, width: 4, height: 8, child: const _Triangle(color: _green)),
      c.tapArea(left: r.left, top: r.top, width: r.width, height: r.height, onTap: onTap),
    ];
  }

  Future<void> _pickLanguage(BuildContext context, PilgrimSettingsCubit cubit) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // كل لغة باسمها هي (العربية / English)
            for (final (code, name) in [('ar', CommonText.arabic.ar), ('en', CommonText.english.en)])
              ListTile(
                title: Text(name, style: const TextStyle(fontFamily: 'NotoSansArabic', fontSize: 16, color: _green)),
                trailing: code == cubit.state.language ? const Icon(Icons.check, color: _green) : null,
                onTap: () => Navigator.pop(sheet, code),
              ),
          ],
        ),
      ),
    );
    if (picked != null) await cubit.setLanguage(picked);
  }
}

// المثلث الصغير بنهاية الصف (بيأشر لبرا: يسار بالعربي)
class _Triangle extends StatelessWidget {
  final Color color;

  const _Triangle({required this.color});

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return CustomPaint(painter: _TrianglePainter(pointLeft: rtl, color: color));
  }
}

class _TrianglePainter extends CustomPainter {
  final bool pointLeft;
  final Color color;

  const _TrianglePainter({required this.pointLeft, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = pointLeft
        ? (Path()..moveTo(size.width, 0)..lineTo(0, size.height / 2)..lineTo(size.width, size.height)..close())
        : (Path()..moveTo(0, 0)..lineTo(size.width, size.height / 2)..lineTo(0, size.height)..close());
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.pointLeft != pointLeft || old.color != color;
}

/// مفتاح الإشعارات 48×24 — مفعّل: أخضر والدائرة البيضا (20) لجهة النهاية (يسار بالعربي)
class _Switch extends StatelessWidget {
  final FigmaCanvas c;
  final bool on;

  const _Switch({required this.c, required this.on});

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(color: on ? const Color(0xFF1E382C) : const Color(0xFFD9D9D9), borderRadius: BorderRadius.circular(s.x(12))),
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
