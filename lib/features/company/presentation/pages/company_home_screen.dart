import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/widgets/figma_lines.dart';
import '../../domain/entities/company_overview.dart';
import '../../domain/entities/company_trip.dart';
import '../../domain/repositories/company_repository.dart';
import '../controllers/company_controller.dart';
import '../cubits/company_home_cubit.dart';
import '../cubits/company_trips_cubit.dart';
import '../l10n/company_home_text.dart';
import '../widgets/company_action_card.dart';
import '../widgets/company_colors.dart';
import '../widgets/company_page.dart';
import '../widgets/company_stat_card.dart';
import '../widgets/company_tab_bar.dart';
import '../widgets/company_trip_card.dart';

// -------------------------------------------------------------
// رئيسية الشركة — مطابقة لـ Figma "الشاشة الرئيسية للشركة" (455:2885)
// الجرس → الإشعارات | الترحيب باسم الشركة | الصورة | 4 أرقام (كل كرت بيفتح شاشته) | "الرحلات النشطة" | إنشاء رحلة / إنشاء المجموعات
// وتحتهم كروت الرحلات النشطة الحقيقية (لحد 3) — كل كرت بيفتح تفاصيل رحلته
// -------------------------------------------------------------
class CompanyHomeScreen extends StatelessWidget {
  const CompanyHomeScreen({super.key});

  static const heroAsset = '$companyAssets/home_hero.jpg';
  static int heroCacheWidth(BuildContext context) => (DesignScale.of(context).x(361) * MediaQuery.devicePixelRatioOf(context)).round();

  // الأرقام: (الكرت، دائرة الأيقونة، الأيقونة، أعلى العنوان وطرفه، أعلى الرقم وطرفه) — من Figma
  static const _activeTrips = (card: Rect.fromLTWH(205, 411, 170.5, 73), circle: Offset(329, 423), icon: Rect.fromLTWH(333, 428, 24, 24), labelTop: 428.0, labelRight: 327.0, numberTop: 454.0, numberRight: 288.0);
  static const _pilgrims = (card: Rect.fromLTWH(18, 411, 170.5, 73), circle: Offset(144, 422), icon: Rect.fromLTWH(148, 426, 24, 24), labelTop: 428.0, labelRight: 140.0, numberTop: 454.0, numberRight: 121.0);
  static const _supervisors = (card: Rect.fromLTWH(204.5, 500, 170.5, 73), circle: Offset(331, 512), icon: Rect.fromLTWH(335, 516, 24, 24), labelTop: 517.0, labelRight: 327.0, numberTop: 543.0, numberRight: 310.0);
  static const _groups = (card: Rect.fromLTWH(18, 500, 170.5, 73), circle: Offset(144, 512), icon: Rect.fromLTWH(148, 516, 24, 24), labelTop: 517.0, labelRight: 138.0, numberTop: 543.0, numberRight: 121.0);

  // كروت "الرحلات النشطة" (الرحلات اللي ما رجعت) تحت كروت الإجراءات — بنفس كرت تبويب الرحلات
  static const _tripsTop = 724.0;
  static const _maxTrips = 3;

  @override
  Widget build(BuildContext context) {
    final trips = context.select<CompanyTripsCubit, List<CompanyTrip>>((t) => t.state.trips);
    final today = DateTime.now();
    final active = [for (final t in trips) if (!t.endedOn(today)) t];
    final shown = active.take(_maxTrips).toList();
    // الصفحة بتتمرر لما في رحلات: آخر كرت بيوقف فوق شريط التنقل بنفس المسافة اللي بين الكروت
    final scrollHeight = shown.isEmpty ? 852.0 : _tripsTop + (shown.length - 1) * CompanyTripCard.pitch + CompanyTripCard.pitch + (852 - CompanyTabBar.top);
    return BlocBuilder<CompanyHomeCubit, CompanyOverview>(
      builder: (context, o) => CompanyPage(
        inShell: true,
        scrollHeight: scrollHeight,
        builder: (c) => [
          // الجرس (Hicon) 24 من (16,59)
          c.image('$companyAssets/ic_bell.png', left: 16, top: 59, width: 24, height: 24),
          c.tapArea(left: 8, top: 51, width: 40, height: 40, onTap: () => CompanyController.openNotifications(context)),
          // SF Compact 790 20 — طرفه x377: "السلام عليكم، <اسم الشركة>" (من /company/me — وإلا اسم صاحب الحساب)
          c.text(o.greetingName.isEmpty ? CompanyHomeText.greeting() : CompanyHomeText.greetingName(o.greetingName), left: 56, top: 59, width: 321, height: 24, style: c.style(20, FigmaWeight.sfBold, CompanyColors.green, lineHeight: null, letterSpacing: 0)),
          c.image(heroAsset, left: 15, top: 135, width: 361, height: 244, radius: 10, fit: BoxFit.cover, cacheWidth: heroCacheWidth(context)),
          // كل كرت رقم بيفتح شاشته
          ...CompanyStatCard.build(c, _activeTrips, icon: 'ic_active_trips', label: CompanyHomeText.activeTrips(), value: o.activeTrips, onTap: () => CompanyController.openTab(context, CompanyTab.trips)),
          ...CompanyStatCard.build(c, _pilgrims, icon: 'ic_pilgrims', label: CompanyHomeText.pilgrims(), value: o.pilgrims, onTap: () => _openPilgrims(context)),
          ...CompanyStatCard.build(c, _supervisors, icon: 'ic_supervisors', label: CompanyHomeText.supervisors(), value: o.supervisors, onTap: () => CompanyController.openSupervisors(context)),
          ...CompanyStatCard.build(c, _groups, icon: 'ic_groups', label: CompanyHomeText.groups(), value: o.groups, onTap: () => CompanyController.openTab(context, CompanyTab.groups)),
          // "الرحلات النشطة" — SF Compact 556 16 — طرفه x363 — بيفتح تبويب الرحلات، و"عرض الكل" لما في رحلات أكتر من المعروضة
          FigmaLines.build(c, CompanyHomeText.activeTripsSection(), left: 213, top: 597, width: 150, style: c.style(16, FigmaWeight.semiBold, CompanyColors.green), wrap: false),
          c.tapArea(left: 205, top: 590, width: 172, height: 34, onTap: () => CompanyController.openTab(context, CompanyTab.trips)),
          if (active.length > shown.length) ...[
            FigmaLines.build(c, CompanyHomeText.showAll(), left: 18, top: 599, width: 100, align: TextAlign.left, style: c.style(14, FigmaWeight.sfRegular, const Color(0xFF4C7A75)), wrap: false),
            c.tapArea(left: 10, top: 590, width: 110, height: 34, onTap: () => CompanyController.openTab(context, CompanyTab.trips)),
          ],
          ...CompanyActionCard.build(
            c,
            left: 205,
            iconLeft: 335,
            textRight: 327,
            icon: 'ic_create_trip',
            title: CompanyHomeText.createTrip(),
            hint: CompanyHomeText.createTripHint(),
            onTap: () => CompanyController.createTrip(context),
          ),
          ...CompanyActionCard.build(
            c,
            left: 18,
            iconLeft: 148,
            textRight: 138,
            icon: 'ic_create_groups',
            title: CompanyHomeText.createGroups(),
            hint: CompanyHomeText.createGroupsHint(),
            onTap: () => CompanyController.createGroups(context),
          ),
          for (final (i, trip) in shown.indexed) ...CompanyTripCard.build(c, trip, top: _tripsTop + i * CompanyTripCard.pitch, onDetails: () => CompanyController.openTrip(context, trip)),
        ],
      ),
    );
  }

  static Future<void> _openPilgrims(BuildContext context) async {
    final changed = await CompanyController.openPilgrims(context, context.read<CompanyRepository>());
    if (changed && context.mounted) CompanyController.refreshAll(context);
  }
}

