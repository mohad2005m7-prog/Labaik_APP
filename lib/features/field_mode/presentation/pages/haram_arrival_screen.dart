import 'package:flutter/material.dart';

import '../../../../core/l10n/app_language.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../tawaf/presentation/controllers/tawaf_controller.dart';
import '../controllers/field_mode_controller.dart';
import '../controllers/haram_gates_controller.dart';
import '../l10n/route_text.dart';
import '../widgets/field_colors.dart';
import '../widgets/gate_info_card.dart';
import '../widgets/route_format.dart';
import '../widgets/route_layout.dart';
import '../widgets/route_map.dart';

// -------------------------------------------------------------
// شاشة "وصلت إلى المسجد الحرام" — مطابقة لـ Figma (21:1859 "الوصل للحرم")
// نفس تصميم شاشات الطريق، والخريطة: المسجد الحرام وأبوابه الرئيسية بتكبير 16–18 (صحن الطواف والأبواب)
// بترشده لأقرب باب لموقعه الفعلي مع المسافة والوقت الحيين — والضغط على أي باب بيفتح بطاقته
// (الصورة والاسمين والازدحام) والخريطة بتقرّب عليه بنعومة، ومن البطاقة بيختاره كوجهة
// "وصلت إلى المسجد الحرام" → الوصول للباب اللي اتجه إله وخطوات الطواف (TawafController)
// -------------------------------------------------------------
class HaramArrivalScreen extends StatefulWidget {
  const HaramArrivalScreen({super.key});

  static const _spec = RouteSpec(
    title: RouteText.haramArrivalTitle,
    distanceChip: Rect.fromLTWH(207, 117, 172, 44),
    timeChip: Rect.fromLTWH(18, 117, 173, 44),
    distanceIcon: Rect.fromLTWH(305.16, 125, 19.69, 28),
    timeIcon: Rect.fromLTWH(124, 125, 28, 28),
    distanceText: Rect.fromLTWH(259, 128, 34, 22),
    timeText: Rect.fromLTWH(58, 128, 58, 22),
    stepText: Rect.fromLTWH(42, 590, 310, 44),
    stepRuns: [(text: RouteText.haramGateStep, weight: null)],
    hintLabel: RouteText.haramHint,
    hint: Rect.fromLTWH(75, 658, 236, 22),
    hintStyle: (size: 16, weight: FigmaWeight.poppinsMedium, color: FieldColors.accent),
    arrivedLabel: RouteText.arrivedHaram,
  );

  /// تكبير شاشة الحرم: صحن الطواف والأبواب واضحين
  static const zoomRange = (min: 16.0, max: 18.0);

  @override
  State<HaramArrivalScreen> createState() => _HaramArrivalScreenState();
}

class _HaramArrivalScreenState extends State<HaramArrivalScreen> {
  final _gates = HaramGatesController();

  @override
  void initState() {
    super.initState();
    _gates.start();
  }

  @override
  void dispose() {
    _gates.dispose();
    super.dispose();
  }

  Future<void> _onLost() async {
    final result = await _gates.navigation.helpLost();
    if (mounted) FieldModeController.showLostResult(context, result);
  }

  RouteLiveInfo _liveInfo() {
    final navigation = _gates.navigation;
    final remaining = navigation.remainingMeters;
    final seconds = navigation.remainingSeconds;
    final gate = _gates.selected.name(AppLanguage.code);

    final String step;
    if (remaining == null) {
      step = RouteText.haramGateStepNoDistance();
    } else {
      final template = _gates.chosenByUser ? RouteText.haramGateStepChosen : RouteText.haramGateStep;
      step = template().replaceFirst('{distance}', RouteFormat.distance(navigation.nextStepMeters ?? remaining));
    }

    return RouteLiveInfo(
      distance: RouteText.chipDistance(remaining == null ? '--' : RouteFormat.distance(remaining)),
      time: seconds == null ? '--' : RouteFormat.duration(seconds),
      step: step.replaceFirst('{gate}', gate),
      near: false,
    );
  }

  // الخريطة مع بطاقة الباب (بتطلع من تحت بحركة ناعمة)
  Widget _map(BuildContext context) {
    final gate = _gates.inspected;
    return Stack(
      fit: StackFit.expand,
      children: [
        RouteMap(
          controller: _gates.navigation,
          pois: _gates.pois,
          onPoiTap: _gates.inspect,
          zoomRange: HaramArrivalScreen.zoomRange,
          focus: _gates.focus,
        ),
        PositionedDirectional(
          start: 0,
          end: 0,
          bottom: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(position: Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(animation), child: child),
            ),
            child: gate == null
                ? const SizedBox.shrink()
                : GateInfoCard(
                    key: ValueKey(gate.targetId),
                    gate: gate,
                    scale: DesignScale.of(context),
                    isDestination: gate.targetId == _gates.selected.targetId,
                    onGo: () => _gates.select(gate.targetId),
                    onClose: _gates.closeInspection,
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _gates,
      builder: (context, _) => RouteLayout(
        spec: HaramArrivalScreen._spec,
        live: _liveInfo(),
        map: _map(context),
        onArrived: () => TawafController.start(context, _gates.selected),
        onLost: _onLost,
      ),
    );
  }
}
