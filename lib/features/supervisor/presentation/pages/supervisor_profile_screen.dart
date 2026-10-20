import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/tx.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../domain/repositories/supervisor_repository.dart';
import '../controllers/supervisor_controller.dart';
import '../cubits/supervisor_profile_cubit.dart';
import '../l10n/sup_profile_text.dart';
import '../widgets/photo_picker.dart';
import '../widgets/supervisor_colors.dart';
import '../widgets/supervisor_page.dart';
import '../widgets/supervisor_widgets.dart';

// -------------------------------------------------------------
// ملفي الشخصي — مطابقة لـ Figma "27.Profile" (251:4643)
// البيانات من حساب المشرف ومن اللي حفظه هو (ما في أرقام عشوائية — الهاتف الفاضي بيطلع "أضف رقم الهاتف")
// الترس → الإعدادات | القلم → تعديل الملف | الصورة → تكبيرها، أو إضافة صورة (كاميرا/معرض) لو ما في
// -------------------------------------------------------------
class SupervisorProfileScreen extends StatelessWidget {
  const SupervisorProfileScreen({super.key});

  static const _heroTag = 'supervisor-photo';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupervisorProfileCubit, SupervisorProfileState>(
      builder: (context, state) {
        final p = state.profile;
        final photo = p.photo;
        return SupervisorPage(
          inShell: true,
          builder: (c) => [
            c.image('$supAssets/ic_gear.png', left: 24.5, top: 58.5, width: 23, height: 25),
            c.tapArea(left: 12, top: 51, width: 48, height: 40, onTap: () => SupervisorController.openSettings(context)),
            c.text(SupProfileText.title(), left: 76, top: 65, width: 241, height: 29, align: TextAlign.center, style: supText(c, 24, FigmaWeight.semiBold, SupColors.green)),

            c.rect(left: 157, top: 122, width: 80, height: 80, child: SupPhoto(photo: photo, size: c.s.x(80), name: p.fullName, heroTag: _heroTag)),
            c.tapArea(left: 157, top: 122, width: 80, height: 80, onTap: () => photo == null ? _addPhoto(context) : SupervisorController.viewPhoto(context, photo: photo, heroTag: _heroTag, title: p.fullName)),
            c.box(left: 182, top: 182, width: 30, height: 30, color: SupColors.avatarPlaceholder, radius: 15),
            c.image('$supAssets/ic_pen.png', left: 188, top: 188, width: 17.5, height: 18.5),
            c.tapArea(left: 178, top: 178, width: 38, height: 38, onTap: () => SupervisorController.openEditProfile(context)),

            c.text(p.fullName.isEmpty ? '—' : p.fullName, left: 16, top: 219.5, width: 361, height: 24, align: TextAlign.center, style: supText(c, 20, FigmaWeight.semiBold, SupColors.green)),
            c.text(SupProfileText.role(), left: 16, top: 251, width: 361, height: 19, align: TextAlign.center, style: supText(c, 16, FigmaWeight.sfRegular, SupColors.green)),
            // شارة "حساب مشرف"
            c.box(left: 155, top: 279, width: 83, height: 21, color: SupColors.green, radius: 10.5),
            c.text(SupProfileText.supervisorAccount(), left: 155, top: 282.5, width: 83, height: 15, align: TextAlign.center, dy: 0, style: supText(c, 12, FigmaWeight.poppinsRegular, Colors.white)),

            // المعلومات الشخصية
            c.box(left: 16, top: 324, width: 361, height: 182, color: SupColors.cardFill, radius: 10, hasShadow: true),
            c.text(SupProfileText.personalInfo(), left: 150, top: 339, width: 210, height: 19, style: supText(c, 16, FigmaWeight.sfBold, SupColors.green)),
            c.box(left: 231, top: 367, width: 138, height: 1, color: SupColors.divider),
            ..._row(context, c, 374, SupProfileText.email, p.email, 'ic_mail', const Rect.fromLTWH(328, 387, 24, 22)),
            c.box(left: 23, top: 429, width: 345, height: 1, color: SupColors.divider),
            ..._row(context, c, 436, SupProfileText.phone, p.phone, 'ic_phone', const Rect.fromLTWH(329, 449, 22, 22), emptyHint: SupProfileText.addPhone),
          ],
        );
      },
    );
  }

  // العنوان SF Compact Regular 16 والقيمة (إيميل/رقم بخط النظام) — طرفهم x318.5 — والأيقونة يمين
  // القيمة الفاضية: [emptyHint] رمادي وبيفتح تعديل الملف
  List<Widget> _row(BuildContext context, FigmaCanvas c, double top, Tx label, String value, String icon, Rect iconRect, {Tx? emptyHint}) {
    final s = c.s;
    final empty = value.trim().isEmpty;
    final Widget text = empty
        ? Text(emptyHint == null ? '—' : emptyHint(), maxLines: 1, style: supText(c, 15, FigmaWeight.sfRegular, SupColors.grey))
        : Text(value, maxLines: 1, textDirection: TextDirection.ltr, style: TextStyle(fontSize: s.x(15.5), color: SupColors.green, letterSpacing: s.x(0.85), height: 1.2));
    return [
      c.text(label(), left: 100, top: top, width: 218, height: 19, style: supText(c, 16, FigmaWeight.sfRegular, SupColors.green)),
      c.rect(
        left: 40,
        top: top + 26.5,
        width: 280,
        height: 22,
        child: Align(alignment: AlignmentDirectional.centerStart, child: FittedBox(fit: BoxFit.scaleDown, child: text)),
      ),
      c.image('$supAssets/$icon.png', left: iconRect.left, top: iconRect.top, width: iconRect.width, height: iconRect.height),
      if (empty && emptyHint != null) c.tapArea(left: 23, top: top - 4, width: 345, height: 52, onTap: () => SupervisorController.openEditProfile(context)),
    ];
  }

  Future<void> _addPhoto(BuildContext context) async {
    final profile = context.read<SupervisorProfileCubit>();
    final repository = context.read<SupervisorRepository>();
    final path = await SupPhotoPicker.pick(context);
    if (path == null) return;
    final stored = await repository.storePhoto(path);
    await profile.save(profile.state.profile.copyWith(photo: stored));
  }
}
