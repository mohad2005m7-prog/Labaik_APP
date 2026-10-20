import 'dart:async';

import 'package:flutter/material.dart';

import '../../../tawaf/data/ritual_progress_store.dart';
import '../pages/saee_complete_screen.dart';
import '../pages/saee_done_screen.dart';
import '../pages/saee_round_screen.dart';
import '../pages/saee_step_screen.dart';
import '../pages/saee_tahallul_screen.dart';
import '../widgets/saee_steps.dart';

// -------------------------------------------------------------
// التنقل من نهاية الطواف لإنهاء العمرة:
//   اضبط إحرامك بعد الطواف → صلّ ركعتي الطواف → اشرب من زمزم
//   → اتجه نحو المسعى → ابدأ السعي من الصفا
//   → الشوط 1 … 7 → أتممت السعي
//   → اتجه إلى صالونات الحلاقة → أتمم تحللك → الحمدلله
// كل شوط بينحفظ (RitualProgressStore) حتى لو انسكّر التطبيق يتابع من نفس الشوط
// -------------------------------------------------------------
abstract final class SaeeController {
  static Future<void> _push(BuildContext context, Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  static Future<void> _step(BuildContext context, dynamic spec, VoidCallback Function(BuildContext) next) =>
      _push(context, Builder(builder: (context) => SaeeStepScreen(spec: spec, onNext: next(context))));

  /// الدخول من نهاية الطواف
  static void start(BuildContext context) {
    unawaited(RitualProgressStore.record('saee.idtiba', ihram: IhramState.inIhram));
    _step(context, SaeeSteps.idtiba, (ctx) => () => _prayer(ctx));
  }

  /// متابعة سعي ما كمل (التطبيق انسكّر بنص الشوط [lap])
  static void resumeLap(BuildContext context, int lap) => _round(context, lap.clamp(1, 7));

  static void _prayer(BuildContext context) => _step(context, SaeeSteps.prayer, (ctx) => () => _zamzam(ctx));

  static void _zamzam(BuildContext context) => _step(context, SaeeSteps.zamzam, (ctx) => () => _masaa(ctx));

  static void _masaa(BuildContext context) => _step(context, SaeeSteps.masaa, (ctx) => () => _ready(ctx));

  static void _ready(BuildContext context) => _step(context, SaeeSteps.ready, (ctx) => () => _round(ctx, 1));

  static void _round(BuildContext context, int round) {
    unawaited(RitualProgressStore.record(RitualProgressStore.saeeRound, saeeLap: round, ihram: IhramState.inIhram));
    _push(
      context,
      Builder(builder: (ctx) => SaeeRoundScreen(round: round, onDone: () => round < 7 ? _round(ctx, round + 1) : _done(ctx))),
    );
  }

  static void _done(BuildContext context) {
    unawaited(RitualProgressStore.record('saee.done', ihram: IhramState.inIhram));
    _doneScreen(context);
  }

  static void _doneScreen(BuildContext context) => _push(context, Builder(builder: (ctx) => SaeeDoneScreen(onNext: () => _barbershop(ctx))));

  static void _barbershop(BuildContext context) => _step(context, SaeeSteps.barbershop, (ctx) => () => _tahallul(ctx));

  static void _tahallul(BuildContext context) => _push(context, Builder(builder: (ctx) => SaeeTahallulScreen(onNext: () => _complete(ctx))));

  static void _complete(BuildContext context) {
    // تحلّل — العمرة خلصت (ما في إشي يتابعه)
    unawaited(RitualProgressStore.record(RitualProgressStore.completed, ihram: IhramState.released));
    _completeScreen(context);
  }

  static void _completeScreen(BuildContext context) => _push(context, Builder(builder: (ctx) => SaeeCompleteScreen(onFinish: () => _finish(ctx))));

  /// "إنهاء الرحلة" — يرجع لشاشة Home أو بيخبر المستخدم
  static void _finish(BuildContext context) {
    // بيرجع لأول شاشة في ستاك التنقل (Home screen) مع إزالة كل الشاشات قبله
    Navigator.of(context, rootNavigator: false).popUntil((route) => route.isFirst);
  }
}
