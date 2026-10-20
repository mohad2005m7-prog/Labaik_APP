import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_line.dart';
import '../../../../core/widgets/figma_page.dart';
import '../l10n/trip_details_text.dart';
import '../l10n/trip_edit_text.dart';
import 'trip_colors.dart';
import 'trip_steps_bar.dart';

// -------------------------------------------------------------
// شاشة "تعديل تفاصيل الرحلة" (Figma 1تعديل … 7تعديل):
// خطوات التعديل — "معلومات الرحلة الخاصة بك" — الكرت (361×427 #EEF2F2 radius 10 بظل) وجوّاه السؤال — الزر تحت
// أماكن العناصر بتختلف شوي بين الإطارات فكل شاشة بتمرّر أرقامها من Figma
// -------------------------------------------------------------
class TripEditPage extends StatelessWidget {
  /// خطوط الخطوات المعبّاية (null = ما في خطوات — أول شاشة)
  final int? steps;
  final double infoTop;

  /// طرف "معلومات الرحلة الخاصة بك" اليمين (طرف الحبر + 0.5)
  final double infoRight;
  final double cardTop;
  final String button;
  final double buttonLeft;
  final double buttonTop;
  final VoidCallback onNext;
  final List<Widget> Function(FigmaCanvas c) content;

  /// فوق الزر (مثل التقويم المفتوح)
  final List<Widget> Function(FigmaCanvas c)? overlay;

  const TripEditPage({
    super.key,
    this.steps,
    this.infoTop = 161,
    this.infoRight = 380,
    this.cardTop = 207,
    required this.button,
    this.buttonLeft = 17,
    this.buttonTop = 666,
    required this.onNext,
    required this.content,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: TripEditText.title(),
      // "Frame 48" عرضه 372 بهالإطارات (مقاس)
      titleRight: 347,
      chevronLeft: 367,
      body: (c) => [
        if (steps != null) Positioned.fill(child: TripStepsBar(c: c, done: steps!)),
        // SF Compact 556 16 أسود
        c.line(TripDetailsText.info(), left: infoRight - 200, top: infoTop, width: 200, height: 22, style: c.style(16, FigmaWeight.semiBold, Colors.black)),
        c.box(left: 16, top: cardTop, width: 361, height: 427, color: TripColors.cardFill, radius: 10, hasShadow: true),
        ...content(c),
        c.button(button, left: buttonLeft, top: buttonTop, figmaSpacing: true, onTap: onNext),
        ...?overlay?.call(c),
      ],
    );
  }
}
