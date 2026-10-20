import 'package:flutter/material.dart';

import '../../../../core/l10n/tx.dart';
import '../../../../core/theme/figma_text.dart';
import '../controllers/field_mode_controller.dart';
import '../l10n/ihram_prep_text.dart';
import '../widgets/field_colors.dart';
import '../widgets/field_mode_page.dart';

// -------------------------------------------------------------
// شاشات "الاستعداد للإحرام" (4 خطوات بالترتيب) — مطابقة لـ Figma:
//   1. اغتسل واستعد 21:868 — 2. صلِّ 21:897 — 3. انوِ العمرة 21:924 — 4. ابدأ التلبية 21:951
// "تم" بتنقل للخطوة اللي بعدها، وبعد الأخيرة لـ "أنت جاهز للخطوة التالية"
// -------------------------------------------------------------
class IhramPrepStepScreen extends StatelessWidget {
  final int step; // من 1 لـ 4

  const IhramPrepStepScreen({super.key, required this.step});

  static const stepsCount = 4;
  static const _assets = 'assets/images/field_mode';

  @override
  Widget build(BuildContext context) {
    final spec = _steps[step - 1];

    return FieldModePage(
      title: IhramPrepText.title(),
      backIconLeft: 20,
      titleRight: 380.6,
      builder: (c) {
        final body = c.style(16, FigmaWeight.semiBold, FieldColors.green);

        Widget text(InlineSpan span, Rect r, {TextAlign align = TextAlign.start}) =>
            c.rich(span, left: r.left, top: r.top, width: r.width, height: r.height, align: align);

        Widget pill(Rect r, Gradient gradient) => c.box(left: r.left, top: r.top, width: r.width, height: r.height, gradient: gradient, radius: 10);

        return [
          // اتبع الخطوات بالترتيب... — SF Compact 457 16 #4C7A75
          c.text(IhramPrepText.intro(), left: 63, top: 117, width: 314, height: 44, style: c.style(16, FigmaWeight.sfRegular, FieldColors.accent)),

          // الكرت: #4C7A75 10% — radius 10 — ظل
          c.box(
            left: spec.card.left,
            top: spec.card.top,
            width: spec.card.width,
            height: spec.card.height,
            color: FieldColors.cardFill,
            radius: 10,
            hasShadow: true,
          ),

          // الرسمة
          c.image('$_assets/${spec.image}', left: spec.imageRect.left, top: spec.imageRect.top, width: spec.imageRect.width, height: spec.imageRect.height),

          // عنوان الخطوة: مستطيل بتدرّج أخضر — radius 10 — نص أبيض بالنص
          pill(spec.titlePill, step == 1 ? FieldColors.firstStepGradient : FieldColors.stepGradient),
          text(
            TextSpan(
              children: [
                for (final run in spec.titleRuns)
                  spec.titlePoppins
                      ? poppinsLatinSpan(run.text(), c.style(run.size, run.weight, Colors.white))
                      : TextSpan(text: run.text(), style: c.style(run.size, run.weight, Colors.white)),
              ],
            ),
            spec.titleText,
            align: TextAlign.center,
          ),

          // نصوص الخطوة — SF Compact 556 16 #1F3B2E
          for (final p in spec.paragraphs) text(TextSpan(text: p.text(), style: body), p.rect),

          // زر فرعي (طريقة ارتداء الإحرام / التفاصيل) — شاشاتهم لسا ما انصممت
          if (spec.link != null) ...[
            pill(spec.link!.pill, FieldColors.stepGradient),
            text(
              TextSpan(text: spec.link!.label(), style: c.style(16, spec.link!.weight, Colors.white)),
              spec.link!.text,
              align: TextAlign.center,
            ),
            c.tapArea(
              left: spec.link!.pill.left,
              top: spec.link!.pill.top,
              width: spec.link!.pill.width,
              height: spec.link!.pill.height,
              onTap: () => FieldModeController.comingSoon(context),
            ),
          ],

          // تم
          c.button(IhramPrepText.done(), left: spec.button.dx, top: spec.button.dy, onTap: () => FieldModeController.completePrepStep(context, step)),
        ];
      },
    );
  }

  static const _steps = [
    // 21:868
    _StepSpec(
      card: Rect.fromLTWH(16, 177, 361, 408),
      titlePill: Rect.fromLTWH(202, 201, 151, 38),
      titleText: Rect.fromLTWH(218, 209, 119, 22),
      titleRuns: [(text: IhramPrepText.step1Title, size: 18, weight: FigmaWeight.poppinsMedium)],
      titlePoppins: true,
      paragraphs: [(text: IhramPrepText.step1Body, rect: Rect.fromLTWH(38, 255, 323, 44)), (text: IhramPrepText.step1Clothes, rect: Rect.fromLTWH(71, 315, 290, 66))],
      link: _Link(IhramPrepText.howToWear, Rect.fromLTWH(194, 405, 167, 38), Rect.fromLTWH(210, 413, 135, 22), FigmaWeight.poppinsMedium),
      image: 'prep_step_1.png',
      imageRect: Rect.fromLTWH(17, 394, 142, 190),
      button: Offset(17, 617),
    ),
    // 21:897
    _StepSpec(
      card: Rect.fromLTWH(15, 177, 361, 408),
      titlePill: Rect.fromLTWH(130, 201, 222, 38),
      titleText: Rect.fromLTWH(146, 209, 190, 22),
      titleRuns: [(text: IhramPrepText.step2Title, size: 18, weight: FigmaWeight.semiBold)],
      paragraphs: [(text: IhramPrepText.step2Body, rect: Rect.fromLTWH(37, 255, 323, 44)), (text: IhramPrepText.step2Note, rect: Rect.fromLTWH(184, 315, 176, 22))],
      image: 'prep_step_2.png',
      imageRect: Rect.fromLTWH(16, 395, 142, 190),
      button: Offset(17, 621),
    ),
    // 21:924 ("العمرة" بالعنوان حجمها 18 والباقي 19 حسب Figma)
    _StepSpec(
      card: Rect.fromLTWH(13, 176, 361, 409),
      titlePill: Rect.fromLTWH(230, 200, 120, 38),
      titleText: Rect.fromLTWH(246, 208, 88, 22),
      titleRuns: [
        (text: IhramPrepText.step3TitleA, size: 19, weight: FigmaWeight.semiBold),
        (text: IhramPrepText.step3TitleB, size: 18, weight: FigmaWeight.semiBold),
      ],
      paragraphs: [(text: IhramPrepText.step3Body, rect: Rect.fromLTWH(34, 254, 323, 44)), (text: IhramPrepText.step3Talbiya, rect: Rect.fromLTWH(198, 314, 159, 22))],
      image: 'prep_step_3.png',
      imageRect: Rect.fromLTWH(13, 395, 142, 190),
      button: Offset(17, 626),
    ),
    // 21:951
    _StepSpec(
      card: Rect.fromLTWH(16, 177, 361, 408),
      titlePill: Rect.fromLTWH(222, 201, 131, 38),
      titleText: Rect.fromLTWH(240, 209, 97, 22),
      titleRuns: [(text: IhramPrepText.step4Title, size: 19, weight: FigmaWeight.semiBold)],
      paragraphs: [
        (text: IhramPrepText.step4Body, rect: Rect.fromLTWH(177, 255, 184, 22)),
        (text: IhramPrepText.step4Talbiya, rect: Rect.fromLTWH(55, 293, 306, 44)),
        (text: IhramPrepText.step4Note, rect: Rect.fromLTWH(65, 353, 296, 22)),
      ],
      link: _Link(IhramPrepText.details, Rect.fromLTWH(252, 402, 109, 38), Rect.fromLTWH(268, 410, 77, 22), FigmaWeight.semiBold),
      image: 'prep_step_4.png',
      imageRect: Rect.fromLTWH(16, 423, 229, 162),
      button: Offset(16, 627),
    ),
  ];
}

class _Link {
  final Tx label;
  final Rect pill;
  final Rect text;
  final double weight;

  const _Link(this.label, this.pill, this.text, this.weight);
}

// الفروقات بين خطوات الإحرام بـ Figma
class _StepSpec {
  final Rect card;
  final Rect titlePill;
  final Rect titleText;
  final List<({Tx text, double size, double weight})> titleRuns;
  final bool titlePoppins; // العنوان Poppins 500 (الرقم بـ Poppins)
  final List<({Tx text, Rect rect})> paragraphs;
  final _Link? link;
  final String image;
  final Rect imageRect;
  final Offset button;

  const _StepSpec({
    required this.card,
    required this.titlePill,
    required this.titleText,
    required this.titleRuns,
    this.titlePoppins = false,
    required this.paragraphs,
    this.link,
    required this.image,
    required this.imageRect,
    required this.button,
  });
}
