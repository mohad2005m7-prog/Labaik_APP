import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';

// -------------------------------------------------------------
// هيدر شاشات وضع الميدان حسب Figma ("Group 38": ارتفاعه 42 تحت شريط الحالة مباشرة)
// سهم الرجوع: Back Icon 18×24 — منطقة الضغط ("Left Accessory") 31.9 عرض وبكامل الارتفاع
//   مكانه بيختلف شوي من شاشة لشاشة بـ Figma (x16 / x19 / x20) فبينبعت [backIconLeft]
// العنوان: SF Compact Bold (790) 20 — line height auto — #1F3B2E — طرفه اليمين عند [titleRight]
//   العربي بيترسم بـ Noto Sans Arabic بوزن FigmaWeight.sfBold
// بالعربي: العنوان يمين والسهم يسار — بالإنجليزي: السهم يسار والعنوان بعده (نفس SetupHeader)
// -------------------------------------------------------------
class BackTitleHeader extends StatelessWidget {
  final DesignScale scale;
  final String? title;
  final double backIconLeft;
  final double titleRight;
  final VoidCallback? onBack;

  const BackTitleHeader({super.key, required this.scale, this.title, this.backIconLeft = 19, this.titleRight = 380, this.onBack});

  static const _green = Color(0xFF1F3B2E);

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    // منطقة الضغط بتبدأ قبل الأيقونة بـ 7 (padding الـ Left Accessory)
    final tapLeft = backIconLeft - 7;

    return SizedBox(
      height: s.y(42),
      child: Stack(
        children: [
          // العنوان — Figma بيرسمه أوطى بـ 1 (نفس قياس ترحيب الرئيسية)
          // ما بيستقبل ضغطات (صندوقه ممكن يكون أعرض من النص ويغطي السهم)
          if (title != null)
            Positioned(
              right: isRtl ? s.x(393 - titleRight) : null,
              left: isRtl ? null : s.x(tapLeft + 31.9 + 12),
              top: s.y(9),
              height: s.y(24),
              child: IgnorePointer(
                child: Align(
                  alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                  child: Transform.translate(
                    offset: Offset(0, s.y(1)),
                    child: Text(
                      title!,
                      maxLines: 1,
                      softWrap: false,
                      style: figmaText(s, size: 20, weight: FigmaWeight.sfBold, color: _green, lineHeight: null, letterSpacing: 0),
                    ),
                  ),
                ),
              ),
            ),
          // سهم الرجوع (يسار باللغتين) — آخر عنصر حتى يكون فوق كل شي
          Positioned(
            left: s.x(tapLeft),
            top: 0,
            bottom: 0,
            width: s.x(31.9),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBack ?? () => Navigator.maybePop(context),
              child: Stack(
                children: [
                  Positioned(
                    left: s.x(7),
                    top: s.y(9 + 12) - s.x(12),
                    child: Image.asset('assets/images/field_mode/ic_back.png', width: s.x(18), height: s.x(24)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
