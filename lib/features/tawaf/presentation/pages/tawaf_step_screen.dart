import 'package:flutter/material.dart';

import '../../../../core/l10n/app_language.dart';
import '../../../field_mode/data/models/destination_info_dto.dart';
import '../l10n/tawaf_steps_text.dart';
import '../widgets/gate_photo.dart';
import '../widgets/tawaf_page.dart';
import '../widgets/tawaf_parts.dart';
import '../widgets/tawaf_step_spec.dart';

// -------------------------------------------------------------
// شاشة خطوة من الباب لبداية الطواف (Figma 203:1886 … 203:2095 — كلها نفس التصميم، TawafSteps فيه الأرقام):
// العنوان ← العنوان الفرعي ← الصورة ← الكرت ← السطر/الدعاء ← الزر
// شاشة الباب ([gate]): العنوان والصورة حسب الباب اللي وصله المعتمر
// -------------------------------------------------------------
class TawafStepScreen extends StatelessWidget {
  final TawafStepSpec spec;
  final DestinationInfoDto? gate;
  final VoidCallback onNext;

  const TawafStepScreen({super.key, required this.spec, required this.onNext, this.gate});

  @override
  Widget build(BuildContext context) {
    final gate = this.gate;
    final photo = spec.photo;
    final title = gate != null ? TawafStepsText.gateTitle(gate.nameAr, gate.nameEn) : spec.title!();
    final r = spec.photoRect;
    return TawafPage(
      title: title,
      high: spec.highHeader,
      frameHeight: spec.frameHeight,
      body: (c) => [
        TawafParts.subtitle(c, spec.subtitle(), spec.subtitleBox),
        c.rect(
          left: r.left,
          top: r.top,
          width: r.width,
          height: r.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(c.s.x(10)),
            child: photo != null ? Image.asset(photo, fit: BoxFit.cover) : GatePhoto(gate: gate!),
          ),
        ),
        TawafParts.card(c, spec.card),
        TawafParts.centered(c, spec.cardText(), spec.cardBox, TawafParts.cardStyle(c), maxHeight: spec.card.bottom - 4 - spec.cardBox.top),
        TawafParts.centered(
          c,
          spec.note.text(),
          spec.note.box,
          c.style(spec.note.size, spec.note.weight, TawafColors.accent),
          // الإنجليزي بياخد لحد الزر
          maxHeight: AppLanguage.isArabic ? null : spec.button.top - 6 - spec.note.box.top,
        ),
        TawafParts.button(c, spec.button, spec.buttonLabel(), onNext),
      ],
    );
  }
}
