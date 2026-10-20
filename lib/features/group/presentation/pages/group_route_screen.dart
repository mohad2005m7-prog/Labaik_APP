import 'package:flutter/material.dart';

import '../../../../core/l10n/tx.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../../field_mode/presentation/controllers/route_navigation_controller.dart';
import '../../../field_mode/presentation/l10n/route_text.dart';
import '../../../field_mode/presentation/widgets/field_colors.dart';
import '../../../field_mode/presentation/widgets/map_theme.dart';
import '../../../field_mode/presentation/widgets/route_format.dart';
import '../../../field_mode/presentation/widgets/route_layout.dart';
import '../../../field_mode/presentation/widgets/route_map.dart';
import '../../domain/entities/group_info.dart';
import '../controllers/group_controller.dart';
import '../l10n/group_route_text.dart';
import '../widgets/group_meeting_place.dart';

// -------------------------------------------------------------
// "الطريق إلى نقطة التجمع" (Figma 111:6809 — نفس تصميم "الطريق إلى ..." بوضع الميدان بأرقامه):
// شريحتين (المسافة 206,114 والوقت 16,114 — radius 19) من موقعك الفعلي — الخريطة (16,174 361×389 بألوان صورة Figma)
// عليها دبوس "نقطة التجمع" ودبوس "موقعك الحالي" والمسار — صندوق الإرشاد (18,580 — radius 19)
// "تابع المسار الحالي باتجاه ..." — وصلت إلى نقطة التجمع (20,701) — انا ضائع (18,767 بحد أسود)
// -------------------------------------------------------------
class GroupRouteScreen extends StatefulWidget {
  final GroupMeetingPoint point;

  const GroupRouteScreen({super.key, required this.point});

  // النصوص الحية جاية من RouteLiveInfo (اسم نقطة التجمع من المشرف)
  static const _live = Tx('', '');

  static const spec = RouteSpec(
    title: GroupRouteText.title,
    distanceChip: Rect.fromLTWH(206, 114, 171, 44),
    timeChip: Rect.fromLTWH(16, 114, 173, 44),
    chipRadius: 19,

    distanceAsset: 'assets/images/group/ic_chip_pin.png',
    distanceIcon: Rect.fromLTWH(293, 119, 34, 34),
    timeAsset: 'assets/images/group/ic_chip_clock.png',
    timeIcon: Rect.fromLTWH(116, 122, 28, 28),
    distanceText: Rect.fromLTWH(245, 124, 47, 22),
    timeText: Rect.fromLTWH(44, 124, 66, 22),
    chipStyle: (size: 16, weight: FigmaWeight.semiBold, color: Colors.black),
    chipPoppins: true,
    map: Rect.fromLTWH(16, 174, 361, 389),
    stepBox: Rect.fromLTWH(18, 580, 361, 59),
    stepBoxRadius: 19,
    stepText: Rect.fromLTWH(18, 580, 354, 58),
    stepRuns: [(text: _live, weight: null)],
    hintLabel: _live,
    hint: Rect.fromLTWH(16, 659, 361, 22),
    hintStyle: (size: 16, weight: FigmaWeight.semiBold, color: FieldColors.grey),
    arrivedLabel: GroupRouteText.arrived,
    arrivedButton: Offset(20, 701),
    lostButton: Offset(18, 767),
    lostBorderColor: Colors.black,
  );

  @override
  State<GroupRouteScreen> createState() => _GroupRouteScreenState();
}

class _GroupRouteScreenState extends State<GroupRouteScreen> {
  late final _navigation = RouteNavigationController(groupMeetingPlace(widget.point))..start();

  @override
  void dispose() {
    _navigation.dispose();
    super.dispose();
  }

  RouteLiveInfo _live() {
    final meters = _navigation.remainingMeters, seconds = _navigation.remainingSeconds;
    return RouteLiveInfo(
      distance: RouteText.chipDistance(meters == null ? '--' : RouteFormat.distance(meters)),
      time: seconds == null ? '--' : RouteFormat.duration(seconds),
      step: GroupRouteText.step(widget.point.direction),
      hint: GroupRouteText.hint(widget.point.direction),
      near: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: GroupRouteText.title(),
      titleRight: 348.5,
      chevronLeft: 367,
      headerDy: 0,
      titleSize: 24,
      body: (c) => [
        Positioned.fill(
          child: ListenableBuilder(
            listenable: _navigation,
            builder: (context, _) => Stack(
              clipBehavior: Clip.none,
              children: RouteLayout.content(
                c,
                spec: GroupRouteScreen.spec,
                live: _live(),
                map: RouteMap(controller: _navigation, palette: MapPalette.route, userLabel: GroupRouteText.currentLocation(), controls: false),
                onArrived: () => GroupController.arrived(context),
                onLost: () => GroupController.lost(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
