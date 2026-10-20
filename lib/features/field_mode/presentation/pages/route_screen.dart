import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../data/models/field_destination.dart';
import '../../data/models/field_place.dart';
import '../../../help_center/presentation/controllers/help_center_controller.dart';
import '../controllers/field_mode_controller.dart';
import '../controllers/route_navigation_controller.dart';
import '../l10n/route_text.dart';
import '../widgets/field_colors.dart';
import '../widgets/route_format.dart';
import '../widgets/route_layout.dart';
import '../widgets/route_map.dart';

// -------------------------------------------------------------
// شاشة "الطريق إلى ..." — مطابقة لـ Figma:
//   الميقات 21:1380 (القريبة 21:1448) — مكة 21:1499 (القريبة 21:1580) — الفندق 21:1729 — المسجد الحرام 21:1657
// التصميم المشترك بـ RouteLayout والفروقات بين الشاشات هون (أرقام Figma)
// الميقات ومكة والمسجد الحرام: ملاحة حية (موقع المستخدم + المسار + المسافة والوقت) عن طريق RouteNavigationController
// -------------------------------------------------------------
class RouteScreen extends StatefulWidget {
  final FieldDestination destination;

  const RouteScreen({super.key, required this.destination});

  @override
  State<RouteScreen> createState() => _RouteScreenState();

  static const _specs = {
    // 21:1380
    FieldDestination.miqat: RouteSpec(
      title: RouteText.miqatTitle,
      backIconLeft: 19,
      titleRight: 379.6,
      distanceChip: Rect.fromLTWH(206, 117, 171, 44),
      timeChip: Rect.fromLTWH(16, 117, 173, 44),
      largeIcons: false,
      distanceIcon: Rect.fromLTWH(304.56, 127, 16.88, 24),
      timeIcon: Rect.fromLTWH(122, 127, 24, 24),
      distanceText: Rect.fromLTWH(259, 128, 34, 22),
      timeText: Rect.fromLTWH(60, 127, 54, 22),
      chipStyle: (size: 16, weight: FigmaWeight.poppinsMedium, color: Colors.black),
      chipPoppins: true,
      stepText: Rect.fromLTWH(22, 590, 350, 44),
      stepRuns: [(text: RouteText.miqatStep, weight: null)],
      stepTextShadow: true,
      stepNoDistance: RouteText.miqatStep,
      nearStep: RouteText.miqatNearStep,
      hintLabel: RouteText.miqatHint,
      hint: Rect.fromLTWH(63, 649, 267, 22),
      hintStyle: (size: 16, weight: FigmaWeight.semiBold, color: FieldColors.grey),
      arrivedLabel: RouteText.arrivedMiqat,
      arrivedButton: Offset(20, 703),
      lostButton: Offset(20, 769),
    ),
    // 21:1499
    FieldDestination.mecca: RouteSpec(
      title: RouteText.meccaTitle,
      distanceChip: Rect.fromLTWH(205, 114, 172, 44),
      timeChip: Rect.fromLTWH(16, 114, 173, 44),
      distanceIcon: Rect.fromLTWH(303.16, 122, 19.69, 28),
      timeIcon: Rect.fromLTWH(122, 122, 28, 28),
      distanceText: Rect.fromLTWH(257, 125, 34, 22),
      timeText: Rect.fromLTWH(56, 125, 58, 22),
      map: Rect.fromLTWH(15, 174, 361, 389),
      stepBox: Rect.fromLTWH(15, 579, 361, 59),
      darkStepBox: true,
      stepText: Rect.fromLTWH(41, 587, 310, 44),
      stepRuns: [(text: RouteText.meccaStep, weight: null)],
      stepNoDistance: RouteText.meccaStepNoDistance,
      nearStep: RouteText.meccaNearStep,
      nearStepBoxRadius: 19,
      hintLabel: RouteText.meccaHint,
      hint: Rect.fromLTWH(77, 657, 233, 22),
      arrivedLabel: RouteText.arrivedMecca,
      arrivedButton: Offset(17, 704),
      lostButton: Offset(15, 770),
      lostBorderColor: Colors.black,
    ),
    // 21:1729 (النقطة بعد "الأيمن" بوزن SF Compact 350 حسب Figma)
    FieldDestination.hotel: RouteSpec(
      title: RouteText.hotelTitle,
      distanceChip: Rect.fromLTWH(205, 117, 172, 44),
      timeChip: Rect.fromLTWH(19, 116, 173, 44),
      distanceIcon: Rect.fromLTWH(308.76, 125, 19.79, 28),
      timeIcon: Rect.fromLTWH(122, 125, 28, 28),
      distanceLabel: RouteText.chip24km,
      distanceText: Rect.fromLTWH(249.3, 128, 47.3, 22),
      timeText: Rect.fromLTWH(56, 128, 58, 22),
      stepText: Rect.fromLTWH(24, 590, 347, 44),
      stepRuns: [
        (text: RouteText.hotelStepA, weight: null),
        (text: RouteText.hotelStepB, weight: FigmaWeight.sfLight),
        (text: RouteText.hotelStepC, weight: null),
      ],
      hintLabel: RouteText.hotelHint,
      hint: Rect.fromLTWH(96, 655, 201, 22),
      arrivedLabel: RouteText.arrivedHotel,
      lostBorderColor: Colors.black,
    ),
    // 21:1657
    FieldDestination.haram: RouteSpec(
      title: RouteText.haramTitle,
      distanceChip: Rect.fromLTWH(206, 117, 171, 44),
      timeChip: Rect.fromLTWH(16, 117, 173, 44),
      distanceIcon: Rect.fromLTWH(303.16, 125, 19.69, 28),
      timeIcon: Rect.fromLTWH(120, 125, 28, 28),
      distanceText: Rect.fromLTWH(257, 128, 34, 22),
      timeText: Rect.fromLTWH(58, 127, 54, 22),
      chipStyle: (size: 16, weight: FigmaWeight.poppinsMedium, color: FieldColors.green),
      chipPoppins: true,
      map: Rect.fromLTWH(17, 177, 361, 389),
      stepBox: Rect.fromLTWH(17, 582, 361, 59),
      stepText: Rect.fromLTWH(54, 590, 288, 44),
      stepRuns: [(text: RouteText.haramStep, weight: null)],
      stepNoDistance: RouteText.haramStepNoDistance,
      hintLabel: RouteText.haramHint,
      hint: Rect.fromLTWH(75, 658, 236, 22),
      hintStyle: (size: 16, weight: FigmaWeight.poppinsMedium, color: FieldColors.accent),
      arrivedLabel: RouteText.arrivedHaram,
      lostBorderWidth: 2,
    ),
  };
}

class _RouteScreenState extends State<RouteScreen> {
  RouteNavigationController? _navigation;

  RouteSpec get _spec => RouteScreen._specs[widget.destination]!;

  @override
  void initState() {
    super.initState();
    final place = widget.destination.place;
    if (place != null) _navigation = RouteNavigationController(place)..start();
  }

  @override
  void dispose() {
    _navigation?.dispose();
    super.dispose();
  }

  void _onArrived() => FieldModeController.arrived(context, widget.destination);

  // انا ضائع → مركز المساعدة (رابط Figma — طلب صاحب المشروع)
  void _onLost() => HelpCenterController.open(context);

  RouteLiveInfo _liveInfo(RouteNavigationController navigation) {
    final remaining = navigation.remainingMeters;
    final seconds = navigation.remainingSeconds;
    final next = navigation.nextStepMeters;

    final String step;
    final nearStep = _spec.nearStep;
    if (remaining != null && navigation.isNear && nearStep != null) {
      step = nearStep().replaceFirst('{distance}', RouteFormat.distance(remaining));
    } else if (next != null) {
      step = _spec.stepRuns.first.text().replaceFirst('{distance}', RouteFormat.distance(next));
    } else {
      step = _spec.stepNoDistance!();
    }

    return RouteLiveInfo(
      distance: RouteText.chipDistance(remaining == null ? '--' : RouteFormat.distance(remaining)),
      time: seconds == null ? '--' : RouteFormat.duration(seconds),
      step: step,
      near: navigation.isNear,
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigation = _navigation;
    if (navigation == null) return RouteLayout(spec: _spec, onArrived: _onArrived, onLost: _onLost);

    return ListenableBuilder(
      listenable: navigation,
      builder: (context, _) => RouteLayout(
        spec: _spec,
        live: _liveInfo(navigation),
        map: RouteMap(controller: navigation),
        onArrived: _onArrived,
        onLost: _onLost,
      ),
    );
  }
}
