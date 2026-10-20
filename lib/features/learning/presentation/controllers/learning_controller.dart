import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/widgets/top_popup.dart';
import '../../data/learning_progress_source.dart';
import '../pages/learning_stage_screen.dart';
import '../widgets/learning_popup.dart';
import '../widgets/learning_popup_spec.dart';
import '../widgets/learning_stages.dart';

// -------------------------------------------------------------
// التنقل بمراحل التعلم (بروتوتايب Figma):
// الرئيسية "تابع التعلم" → أول مرحلة ما خلصت (ولو خلصهم كلهم: من الأول للمراجعة)
//   الإحرام ── المحظورات الخاصة بالرجال / بالنساء (نوافذ) ── التالي →
//   الطواف ── ماذا لو انتقض وضوئي…؟ (نافذة) ── التالي →
//   السعي ── شروط وأحكام السعي (نافذة) ── التالي →
//   التحلّل ── تمت العمرة → مبروك إتمام العمرة → الرجوع للرئيسية
//   "الرئيسية" بأي مرحلة → الرئيسية — "حسناً" بيسكّر النافذة
// "التالي" / "تمت العمرة" بيحفظوا التقدّم (شريط الرئيسية بيمشي معه)
// -------------------------------------------------------------
abstract final class LearningController {
  static LearningProgressSource progress = LearningProgressSource();

  /// "تابع التعلم" — بيرجع لما يرجع المعتمر للرئيسية (حتى تتحدّث الرئيسية)
  static Future<void> resume(BuildContext context) async {
    final done = await progress.completed();
    if (!context.mounted) return;
    await open(context, done >= LearningStages.all.length ? 0 : done);
  }

  static Future<void> open(BuildContext context, int index) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => LearningStageScreen(index: index)));

  /// "التالي" (أو "تمت العمرة" بآخر مرحلة)
  static Future<void> next(BuildContext context, int index) async {
    await progress.complete(index);
    if (!context.mounted) return;
    if (index + 1 < LearningStages.all.length) {
      unawaited(open(context, index + 1));
    } else {
      unawaited(showPopup(context, LearningStages.donePopup));
    }
  }

  /// "الرئيسية"
  static void home(BuildContext context) => Navigator.popUntil(context, (route) => route.isFirst);

  /// زر ذهبي أو "تمت العمرة": النافذة بتنزل من فوق وبتثبت بالنص
  static Future<void> showPopup(BuildContext context, LearningPopupSpec spec) => showTopPopup<void>(
        context,
        label: spec.title(),
        dismissible: !spec.toHome,
        builder: (popup) => LearningPopup(
          spec: spec,
          onButton: () {
            Navigator.pop(popup);
            if (spec.toHome) home(context);
          },
        ),
      );
}
