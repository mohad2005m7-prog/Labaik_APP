import 'package:flutter/material.dart';

import '../../../../core/l10n/app_language.dart';
import '../../../tawaf/presentation/widgets/tawaf_page.dart';
import '../../../tawaf/presentation/widgets/tawaf_parts.dart';
import '../../../tawaf/presentation/widgets/tawaf_step_spec.dart';

// -------------------------------------------------------------
// شاشة خطوة من السعي (نفس بنية TawafStepScreen) — بتعامل مع غياب الصورة:
// الصور الناقصة (zamzam, masaa_direction, safa_start, barbershop) بتعرض placeholder
// حتى تُضاف الصور الحقيقية لـ assets/images/saee/
// -------------------------------------------------------------
class SaeeStepScreen extends StatelessWidget {
  final TawafStepSpec spec;
  final VoidCallback onNext;

  const SaeeStepScreen({super.key, required this.spec, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final photo = spec.photo!;
    final r = spec.photoRect;
    return TawafPage(
      title: spec.title!(),
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
            child: Image.asset(
              photo,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: TawafColors.card,
                child: Center(child: Icon(Icons.image_outlined, color: TawafColors.accent, size: c.s.x(48))),
              ),
            ),
          ),
        ),
        TawafParts.card(c, spec.card),
        TawafParts.centered(c, spec.cardText(), spec.cardBox, TawafParts.cardStyle(c), maxHeight: spec.card.bottom - 4 - spec.cardBox.top),
        TawafParts.centered(
          c,
          spec.note.text(),
          spec.note.box,
          c.style(spec.note.size, spec.note.weight, TawafColors.accent),
          maxHeight: AppLanguage.isArabic ? null : spec.button.top - 6 - spec.note.box.top,
        ),
        TawafParts.button(c, spec.button, spec.buttonLabel(), onNext),
      ],
    );
  }
}
