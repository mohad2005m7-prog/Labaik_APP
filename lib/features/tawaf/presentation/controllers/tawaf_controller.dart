import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/widgets/top_popup.dart';
import '../../../field_mode/data/models/destination_info_dto.dart';
import '../../../saee/presentation/controllers/saee_controller.dart';
import '../../data/ritual_progress_store.dart';
import '../l10n/tawaf_steps_text.dart';
import '../pages/tawaf_done_screen.dart';
import '../pages/tawaf_round_screen.dart';
import '../pages/tawaf_step_screen.dart';
import '../widgets/shoes_warning_popup.dart';
import '../widgets/tawaf_step_spec.dart';
import '../widgets/tawaf_steps.dart';

// -------------------------------------------------------------
// التنقل من "وصلت إلى المسجد الحرام" لحد نهاية الطواف (بروتوتايب Figma):
// وصلت إلى باب … (الباب اللي وصله) → دخلت الحرم → أنت الآن داخل المسجد الحرام
//   → وجدت لوحة «المطاف» → نافذة "تنبيه قبل المتابعة" (بتنزل من فوق، وبعد ثانيتين) → الكعبة أمامك
//   → وصلت إلى صحن المطاف → اقتربت من صحن المطاف → وصلت إلى صحن المطاف → اضبط إحرامك قبل الطواف
//   → تم ضبط الإحرام → قف عند بداية الطواف → أنا عند نقطة البداية → ابدأ الشوط الأول
//   → الشوط 1…7 ("تم الشوط") → أتممت الطواف → متابعة إلى الخطوة التالية → SaeeController
// سهم الرجوع بكل شاشة بيرجع للي قبلها
// التقدم بينحفظ أول بأول (RitualProgressStore) — ولو سكّر التطبيق بنص الطواف/السعي: "تتابع من الشوط …؟"
// -------------------------------------------------------------
abstract final class TawafController {
  /// مدة نافذة التنبيه قبل ما تنتقل لحالها (After delay 2000ms بـ Figma)
  static const warningDelay = Duration(seconds: 2);

  static Future<void> _push(BuildContext context, Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  static Future<void> _step(BuildContext context, TawafStepSpec spec, VoidCallback Function(BuildContext) next) =>
      _push(context, Builder(builder: (context) => TawafStepScreen(spec: spec, onNext: next(context))));

  /// "وصلت إلى المسجد الحرام" — [gate]: الباب اللي اتجه إله
  /// لو في طواف أو سعي ما كمل (أقل من 12 ساعة) بنسأله يتابع من نفس الشوط
  static Future<void> start(BuildContext context, DestinationInfoDto gate) async {
    final pending = await RitualProgressStore.resumable();
    if (!context.mounted) return;
    if (pending != null && await _askResume(context, pending)) {
      if (!context.mounted) return;
      if (pending.stepKey == RitualProgressStore.saeeRound) return SaeeController.resumeLap(context, pending.saeeLap!);
      return _round(context, pending.tawafRound!);
    }
    if (!context.mounted) return;
    unawaited(RitualProgressStore.record('tawaf.gate', ihram: IhramState.inIhram));
    return _push(
      context,
      Builder(builder: (context) => TawafStepScreen(spec: TawafSteps.gate, gate: gate, onNext: () => _inside(context))),
    );
  }

  static Future<bool> _askResume(BuildContext context, RitualSnapshot pending) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(
            pending.stepKey == RitualProgressStore.saeeRound ? TawafStepsText.resumeSaee(pending.saeeLap!) : TawafStepsText.resumeTawaf(pending.tawafRound!),
            style: const TextStyle(fontFamily: 'NotoSansArabic', fontSize: 15),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(TawafStepsText.restart())),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(TawafStepsText.resume(), style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
      ) ??
      false;

  static void _inside(BuildContext context) => _step(context, TawafSteps.inside, (context) => () => _shoesWarning(context));

  /// "وجدت لوحة «المطاف»": التنبيه بينزل من فوق، وبعد ثانيتين بيسكّر والشاشة اللي بعده بتفتح
  static Future<void> _shoesWarning(BuildContext context) async {
    final navigator = Navigator.of(context);
    var open = true;
    unawaited(showTopPopup<void>(context, label: TawafStepsText.shoesTitle(), dismissible: false, builder: (_) => const ShoesWarningPopup())
        .whenComplete(() => open = false));
    await Future<void>.delayed(warningDelay);
    if (!context.mounted) return;
    if (open) navigator.pop();
    _kaaba(context);
  }

  static void _kaaba(BuildContext context) => _step(context, TawafSteps.kaaba, (context) => () => _approach(context));

  static void _approach(BuildContext context) => _step(context, TawafSteps.approach, (context) => () => _idtiba(context));

  static void _idtiba(BuildContext context) => _step(context, TawafSteps.idtiba, (context) => () => _startPoint(context));

  static void _startPoint(BuildContext context) => _step(context, TawafSteps.start, (context) => () => _begin(context));

  static void _begin(BuildContext context) => _step(context, TawafSteps.begin, (context) => () => _round(context, 1));

  static void _round(BuildContext context, int round) {
    unawaited(RitualProgressStore.record(RitualProgressStore.tawafRound, tawafRound: round, ihram: IhramState.inIhram));
    _push(
      context,
      Builder(builder: (context) => TawafRoundScreen(round: round, onDone: () => round < 7 ? _round(context, round + 1) : _done(context))),
    );
  }

  static void _done(BuildContext context) {
    unawaited(RitualProgressStore.record('tawaf.done', ihram: IhramState.inIhram));
    _doneScreen(context);
  }

  static void _doneScreen(BuildContext context) => _push(context, Builder(builder: (context) => TawafDoneScreen(onNext: () => _next(context))));

  /// "متابعة إلى الخطوة التالية" → أول شاشة من السعي (الاضطباع بعد الطواف)
  static void _next(BuildContext context) => SaeeController.start(context);
}
