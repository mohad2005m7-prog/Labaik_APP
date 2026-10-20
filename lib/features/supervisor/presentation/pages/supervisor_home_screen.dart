import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/tx.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../domain/entities/supervisor_group.dart';
import '../controllers/supervisor_controller.dart';
import '../cubits/supervisor_content_cubits.dart';
import '../cubits/supervisor_profile_cubit.dart';
import '../l10n/sup_home_text.dart';
import '../widgets/supervisor_colors.dart';
import '../widgets/supervisor_page.dart';
import '../widgets/supervisor_widgets.dart';

// -------------------------------------------------------------
// رئيسية المشرف — مطابقة لـ Figma "1. دخول المشرف" (234:2478)
// الجرس → الإشعارات | "المجموعة الأولى ‹" → تفاصيل المجموعة | "عرض البرنامج الكامل" → برنامج الرحلة
// الترحيب من اسم المشرف (SupervisorProfileCubit) والأرقام من أعضاء المجموعة (SupervisorGroupsCubit)
// -------------------------------------------------------------
class SupervisorHomeScreen extends StatelessWidget {
  const SupervisorHomeScreen({super.key});

  /// صورة الرئيسية بتنفك بعرضها بالشاشة بس — SupervisorShell بيفكها مسبقاً بنفس الحجم
  static const heroAsset = '$supAssets/home_hero.jpg';
  static int heroCacheWidth(BuildContext context) => (DesignScale.of(context).x(361) * MediaQuery.devicePixelRatioOf(context)).round();

  @override
  Widget build(BuildContext context) {
    return SupervisorPage(
      inShell: true,
      alwaysBounce: true,
      builder: (c) => [
        // الجرس (يسار) — Hicon/Notification 3
        c.image('$supAssets/ic_bell_outline.png', left: 16, top: 59, width: 24, height: 24),
        c.tapArea(left: 8, top: 51, width: 40, height: 40, onTap: () => SupervisorController.openNotifications(context)),
        // SF Compact Bold 20 — طرفه x377
        BlocSelector<SupervisorProfileCubit, SupervisorProfileState, String>(
          selector: (state) => state.profile.firstName,
          builder: (context, name) => c.text(
            name.isEmpty ? SupHomeText.greeting() : SupHomeText.greetingName(name),
            left: 56,
            top: 59,
            width: 321,
            height: 24,
            style: supText(c, 20, FigmaWeight.sfBold, SupColors.green),
          ),
        ),
        // Poppins Regular 15 — line height 22
        c.text(SupHomeText.role(), left: 280, top: 91, width: 97, height: 22, dy: 0, style: c.style(15, FigmaWeight.poppinsRegular, SupColors.green)),
        c.image(heroAsset, left: 16, top: 137, width: 361, height: 240, radius: 10, fit: BoxFit.cover, cacheWidth: heroCacheWidth(context)),
        BlocBuilder<SupervisorGroupsCubit, ListState<SupervisorGroup>>(
          builder: (context, state) {
            final group = state.items.isEmpty ? null : state.items.first;
            if (group == null) return const SizedBox.shrink();
            return Positioned.fill(child: Stack(clipBehavior: Clip.none, children: _groupSection(context, c, group)));
          },
        ),
      ],
    );
  }

  List<Widget> _groupSection(BuildContext context, FigmaCanvas c, SupervisorGroup group) {
    return [
      // "المجموعة الأولى ‹" → تفاصيل المجموعة
      c.text(group.name, left: 56, top: 401, width: 321, height: 24, style: supText(c, 20, FigmaWeight.sfBold, SupColors.green)),
      c.image('$supAssets/ic_chevron16.png', left: 16, top: 405, width: 16, height: 16, flipInLtr: true),
      c.tapArea(left: 8, top: 396, width: 377, height: 34, onTap: () => SupervisorController.openGroup(context, group)),

      // كروت الأرقام: #4C7A75 10% — radius 10 — ظل — النصوص SF Compact Bold بالنص
      ..._stat(c, left: 289, width: 80, value: group.absentCount, label: SupHomeText.absent),
      ..._stat(c, left: 177, width: 80, value: group.presentCount, label: SupHomeText.present),
      ..._stat(c, left: 20, width: 125, value: group.totalPilgrims, label: SupHomeText.totalPilgrims),
      c.tapArea(left: 20, top: 449, width: 349, height: 80, onTap: () => SupervisorController.openMembers(context, group)),

      // الرحلة القادمة
      c.box(left: 16, top: 553, width: 361, height: 175, color: SupColors.cardFill, radius: 10, hasShadow: true),
      c.text(SupHomeText.nextTrip(), left: 40, top: 569, width: 321, height: 17, dy: 0, style: supText(c, 14, FigmaWeight.sfBold, SupColors.green)),
      c.text(group.nextTripTitle, left: 40, top: 594, width: 313, height: 19, dy: 0, style: supText(c, 16, FigmaWeight.sfBold, SupColors.green)),
      c.text(group.nextTripDetails, left: 40, top: 621, width: 313, height: 14, dy: 0, style: supText(c, 12, FigmaWeight.sfLight, SupColors.green)),
      // زر 258×45 — radius 14 — SF Compact Medium 17 أبيض
      c.box(left: 68, top: 667, width: 258, height: 45, color: SupColors.green, radius: 14),
      c.text(SupHomeText.viewFullProgram(), left: 68, top: 678.5, width: 258, height: 22, align: TextAlign.center, style: c.style(17, FigmaWeight.semiBold, Colors.white)),
      c.tapArea(left: 68, top: 667, width: 258, height: 45, onTap: () => SupervisorController.openProgram(context, group)),
    ];
  }

  List<Widget> _stat(FigmaCanvas c, {required double left, required double width, required int value, required Tx label}) {
    return [
      c.box(left: left, top: 449, width: width, height: 80, color: SupColors.cardFill, radius: 10, hasShadow: true),
      c.text('$value', left: left, top: 465, width: width, height: 24, align: TextAlign.center, dy: 1.75, style: supText(c, 20, FigmaWeight.sfBold, SupColors.green)),
      c.text(label(), left: left, top: 497, width: width, height: 17, align: TextAlign.center, dy: 0, style: supText(c, 14, FigmaWeight.sfBold, SupColors.green)),
    ];
  }
}
