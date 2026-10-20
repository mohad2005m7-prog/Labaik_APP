import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../controllers/field_mode_controller.dart';
import '../l10n/ready_text.dart';
import '../widgets/field_colors.dart';
import '../widgets/field_mode_page.dart';

// -------------------------------------------------------------
// شاشة "أنت جاهز للخطوة التالية" — مطابقة لـ Figma (21:1935)
// الهيدر سهم رجوع بس (بدون عنوان) — "متابعة" حسب حالة الإحرام (شوف FieldModeController)
// -------------------------------------------------------------
class ReadyNextStepScreen extends StatelessWidget {
  const ReadyNextStepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FieldModePage(
      builder: (c) => [
        // العنوان: SF Compact 790 24 — line height auto — طرفه عند x317
        c.text(
          ReadyText.title(),
          left: 76,
          top: 133,
          width: 241,
          height: 29,
          dy: 1.2,
          style: c.style(24, FigmaWeight.sfBold, FieldColors.green, lineHeight: null, letterSpacing: 0),
        ),

        // الوصف: SF Compact 556 15 #4C7A75 بالنص
        c.text(
          ReadyText.description(),
          left: 19,
          top: 178,
          width: 358,
          height: 44,
          dy: 0,
          align: TextAlign.center,
          style: c.style(15, FigmaWeight.semiBold, FieldColors.accent),
        ),

        // البوصلة: 148×148 عند x123 y254
        c.image('assets/images/field_mode/ic_compass.png', left: 123, top: 254, width: 148, height: 148),

        // متابعة: 361×50 عند x17 y434
        c.button(ReadyText.continueLabel(), left: 17, top: 434, onTap: () => FieldModeController.continueFromReady(context)),
      ],
    );
  }
}
