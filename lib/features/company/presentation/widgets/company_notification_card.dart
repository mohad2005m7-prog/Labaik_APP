import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import 'company_box.dart';
import 'company_colors.dart';

// -------------------------------------------------------------
// كرت إشعار الشركة (Figma 751:4011): 345×85 من x24 — radius 10
//   المقروء #4C7A75 10% بدون ظل ونصه وجرسه #1F3B2E — الجديد (ما انقرا) #4C7A75 25% بظل (0,4) blur 4 ونصه وجرسه أسود
//   [onTap] = الانتقال لموضوع الإشعار
//   الجرس 24 (334, +8) — العنوان SF Compact 790 16 طرفه x326 (+11) — النص SF Compact 350 14 (329×34 من x24، +39، سطرين 16.7)
// -------------------------------------------------------------
abstract final class CompanyNotificationCard {
  static const height = 85.0;

  static List<Widget> build(FigmaCanvas c, {required double top, required String title, required String body, required bool important, VoidCallback? onTap}) {
    final color = important ? Colors.black : CompanyColors.green;
    return [
      companyBox(c, left: 24, top: top, width: 345, height: height, color: important ? CompanyColors.cardStrong : CompanyColors.card, shadow: important ? CompanyColors.shadow : null),
      c.image('assets/images/notifications/ic_bell.png', left: 334, top: top + 8, width: 24, height: 24, color: color),
      c.text(title, left: 40, top: top + 11, width: 286, height: 19, dy: 0, style: c.style(16, FigmaWeight.sfBold, color, lineHeight: null, letterSpacing: 0)),
      // النص بيلتف لسطرين (صندوق Figma 329×34 من x24)
      c.rect(
        left: 24,
        top: top + 39,
        width: 329,
        height: 34,
        child: IgnorePointer(
          child: Text(body, maxLines: 2, overflow: TextOverflow.ellipsis, style: c.style(14, FigmaWeight.poppinsRegular, color, lineHeight: 16.7, letterSpacing: 0)),
        ),
      ),
      if (onTap != null) c.tapArea(left: 24, top: top, width: 345, height: height, onTap: onTap),
    ];
  }
}
