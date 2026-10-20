import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../tawaf/presentation/widgets/tawaf_page.dart';
import '../../../tawaf/presentation/widgets/tawaf_parts.dart';
import '../../../tawaf/presentation/widgets/tawaf_step_spec.dart';
import '../l10n/saee_steps_text.dart';

// -------------------------------------------------------------
// "أتمم تحللك من العمرة" (Figma) — بطاقتان: للرجال + للمرأة + ملاحظة + زر
//
// مقاسات Figma (393×852):
//   subtitle: TawafTextBox(16, 117, 360)
//   كرت للرجال: left=16.5, top=178, 360×116, rx=12
//     header: left=54, top=190, 280×20 (semiBold green)
//     body: TawafTextBox(54, 218, 280)
//   كرت للمرأة: left=16.5, top=308, 360×116, rx=12
//     header: left=54, top=320, 280×20
//     body: TawafTextBox(54, 348, 280)
//   ملاحظة: left=102.5, top=438, 188×22 (accent)
//   زر: Rect.fromLTWH(16, 472, 361, 50)
// -------------------------------------------------------------
class SaeeTahallulScreen extends StatelessWidget {
  final VoidCallback onNext;

  const SaeeTahallulScreen({super.key, required this.onNext});

  static const _cardRadius = 12.0;
  static const _cardW = 360.0;
  static const _cardH = 116.0;

  @override
  Widget build(BuildContext context) {
    return TawafPage(
      title: SaeeStepsText.tahallulTitle(),
      body: (c) => [
        TawafParts.subtitle(c, SaeeStepsText.tahallulSubtitle(), const TawafTextBox(16, 117, 360)),

        // ── كرت للرجال ──
        c.box(left: 16.5, top: 178, width: _cardW, height: _cardH, color: TawafColors.card, radius: _cardRadius, hasShadow: true),
        c.text(
          SaeeStepsText.tahallulMenHeader(),
          left: 54,
          top: 190,
          width: 280,
          height: 20,
          style: c.style(14, FigmaWeight.sfBold, TawafColors.green, lineHeight: null, letterSpacing: 0),
        ),
        TawafParts.centered(
          c,
          SaeeStepsText.tahallulMenBody(),
          const TawafTextBox(54, 218, 280),
          c.style(13, FigmaWeight.semiBold, TawafColors.accent),
          maxHeight: 56,
        ),

        // ── كرت للمرأة ──
        c.box(left: 16.5, top: 308, width: _cardW, height: _cardH, color: TawafColors.card, radius: _cardRadius, hasShadow: true),
        c.text(
          SaeeStepsText.tahallulWomenHeader(),
          left: 54,
          top: 320,
          width: 280,
          height: 20,
          style: c.style(14, FigmaWeight.sfBold, TawafColors.green, lineHeight: null, letterSpacing: 0),
        ),
        TawafParts.centered(
          c,
          SaeeStepsText.tahallulWomenBody(),
          const TawafTextBox(54, 348, 280),
          c.style(13, FigmaWeight.semiBold, TawafColors.accent),
          maxHeight: 56,
        ),

        // ملاحظة مركزة
        c.text(
          SaeeStepsText.tahallulNote(),
          left: 102.5,
          top: 438,
          width: 188,
          height: 22,
          align: TextAlign.center,
          style: c.style(13, FigmaWeight.semiBold, TawafColors.accent, lineHeight: null, letterSpacing: 0),
        ),

        TawafParts.button(c, const Rect.fromLTWH(16, 472, 361, 50), SaeeStepsText.tahallulButton(), onNext),
      ],
    );
  }
}
