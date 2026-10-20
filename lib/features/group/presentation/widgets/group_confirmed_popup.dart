import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/top_popup.dart';
import '../../../family/presentation/widgets/family_colors.dart';
import '../l10n/group_arrival_text.dart';

// -------------------------------------------------------------
// النافذة "تم التأكيد" (Figma 163:5858 — 391×353 #ECF4F1) بتنزل من فوق الشاشة:
// 👍 (92×92 من 164,53) — "تم التأكيد" (15,179 361×36) — العودة إلى مجموعتي (15,249)
// -------------------------------------------------------------
class GroupConfirmedPopup extends StatelessWidget {
  final VoidCallback onBack;

  const GroupConfirmedPopup({super.key, required this.onBack});

  static const height = 353.0;

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    final c = FigmaCanvas(s, originTop: 0);
    // الكرت من x1 بإطار الشاشة (393)
    const x = 1.0;
    return TopPopup(
      height: height,
      child: Stack(
        children: [
          c.box(left: x, top: 0, width: 391, height: height, color: FamilyColors.dialogFill, radius: 16),
          // الأيقونة مقصوصة من Figma بهامش 2 من كل جهة
          c.image('assets/images/group/ic_thumbs_up.png', left: x + 162, top: 51, width: 96, height: 96, color: Colors.black),
          c.text(GroupArrivalText.confirmed(), left: x + 15, top: 177, width: 361, height: 36, dy: 0, align: TextAlign.center, style: c.style(24, FigmaWeight.sfBold, FamilyColors.green, lineHeight: null, letterSpacing: 0)),
          c.button(GroupArrivalText.backToGroup(), left: x + 15, top: 249, figmaSpacing: true, onTap: onBack),
        ],
      ),
    );
  }
}
