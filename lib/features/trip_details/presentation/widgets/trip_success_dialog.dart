import 'package:flutter/material.dart';

import '../../../../core/theme/figma_spaced_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../l10n/trip_success_text.dart';

// -------------------------------------------------------------
// "Success Screen" (Figma 176:6844) بعد حفظ تفاصيل الرحلة: كرت 391×444 #ECF4F1 radius 16 بنص الشاشة
// بيطلع من تحت (MOVE_IN من BOTTOM زي البروتوتايب) — 👍 92×92 — "تمت إضافة التفاصيل بنجاح!" — الرسالة —
// "الذهاب للرئيسية" ← الرئيسية (والرجوع من الجهاز كمان)
// -------------------------------------------------------------
Future<void> showTripSuccess(BuildContext context, {required VoidCallback onHome}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, _, child) => SlideTransition(
      position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: child,
    ),
    pageBuilder: (context, _, _) => PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onHome();
      },
      child: _SuccessCard(onHome: onHome),
    ),
  );
}

class _SuccessCard extends StatelessWidget {
  final VoidCallback onHome;

  const _SuccessCard({required this.onHome});

  static const _fill = Color(0xFFECF4F1);

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    // أرقام الكرت نفسه — الكرت من x1 بإطار الشاشة (393)
    final c = FigmaCanvas(s, originTop: 0);
    final lines = TripSuccessText.message().split('\n');
    const x = 1.0;
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: s.y(444),
          child: Stack(
            children: [
              c.box(left: x, top: 0, width: 391, height: 444, color: _fill, radius: 16),
              c.image('assets/images/trip/ic_success.png', left: x + 164, top: 53, width: 92, height: 92),
              // العنوان (SF Compact Bold 20 أسود) والرسالة (سطرين line height 22) بنص الكرت
              c.text(TripSuccessText.title(), left: x + 6.75, top: 181, width: 380, height: 26, dy: 0, align: TextAlign.center, style: c.style(20, 640, Colors.black, lineHeight: null, letterSpacing: 0)),
              c.rect(
                left: x + 15,
                top: 218,
                width: 361,
                height: 44,
                child: IgnorePointer(
                  child: Column(
                    children: [
                      // سطور Figma كل واحد بسطر (والإنجليزي بيلتف بسطرين)
                      for (final line in lines)
                        FigmaSpacedText(line, style: c.style(16, 585, Colors.black), letterSpacing: s.x(-0.408), width: s.x(361), align: TextAlign.center, maxLines: lines.length == 1 ? 2 : 1),
                    ],
                  ),
                ),
              ),
              c.button(TripSuccessText.goHome(), left: x + 15, top: 285, figmaSpacing: true, onTap: onHome),
            ],
          ),
        ),
      ),
    );
  }
}
