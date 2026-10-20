import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../l10n/report_sent_text.dart';
import 'help_colors.dart';
import 'help_text.dart';

// -------------------------------------------------------------
// "تم إرسال البلاغ بنجاح!" (Figma 181:7354 — OVERLAY بنص الشاشة): كرت 391×230 #ECF4F1
// العنوان (SF Compact Bold 20) + الرسالة (Poppins 500 16 بـ 3 سطور زي Figma) + زر "تأكيد" 152×39 → الرئيسية
// الرجوع من الجهاز كمان بيروح للرئيسية
// -------------------------------------------------------------
Future<void> showReportSent(BuildContext context, {required VoidCallback onConfirm}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 200),
    transitionBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: child),
    pageBuilder: (context, _, _) => PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onConfirm();
      },
      child: _SentCard(onConfirm: onConfirm),
    ),
  );
}

class _SentCard extends StatelessWidget {
  final VoidCallback onConfirm;

  const _SentCard({required this.onConfirm});

  // الكرت من x1 بإطار الشاشة (393)
  static const _x = 1.0;

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    final c = FigmaCanvas(s, originTop: 0);
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: s.y(230),
          child: Stack(
            children: [
              c.box(left: _x, top: 0, width: 391, height: 230, color: HelpColors.successFill, radius: 16),
              c.text(
                ReportSentText.title(),
                left: _x + 11.25,
                top: 40,
                width: 379,
                height: 26,
                dy: 0,
                align: TextAlign.center,
                style: c.style(19.4, 640, Colors.black, lineHeight: null, letterSpacing: 0),
              ),
              // صندوق Figma 361×54 والسطور التلاتة أطول منه (بتطلع من فوق وتحت بالتساوي)
              HelpText.paragraph(c, ReportSentText.message(), left: _x + 10, top: 82 - 6, width: 361, lines: 3, align: TextAlign.center, style: c.style(16, FigmaWeight.poppinsMedium, Colors.black)),
              c.button(ReportSentText.confirm(), left: _x + 120, top: 156, width: 152, height: 39, labelSize: 16, labelWeight: FigmaWeight.sfRegular, figmaSpacing: true, onTap: onConfirm),
            ],
          ),
        ),
      ),
    );
  }
}
