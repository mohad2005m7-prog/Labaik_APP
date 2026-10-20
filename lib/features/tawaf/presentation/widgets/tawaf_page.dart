import 'package:flutter/material.dart';

import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_page.dart';

/// ألوان شاشات الطواف (Figma)
abstract final class TawafColors {
  static const green = Color(0xFF1F3B2E);
  static const accent = Color(0xFF4C7A75);
  // الكرت #4C7A75 10% فوق الأبيض — مصمت حتى ظله ما يبين من تحته
  static const card = Color(0xFFEDF2F1);
  // حلقة الأشواط: #4C7A75 30%
  static const track = Color(0x4D4C7A75);
  // نافذة التنبيه
  static const warningFill = Color(0xFFFFFCE8);
  static const warningBorder = Color(0x9E000000);
  static const gold = Color(0xFFA59063);
}

// -------------------------------------------------------------
// صفحة شاشات الطواف: FigmaPage بهيدر "Frame 38" (372 عرض من x11) — العنوان والسهم ">" مقاسين من Figma
//   الشاشات الأولى: الهيدر من y59 — "ابدأ الطواف" والأشواط و"أتممت الطواف": من y51 ([high])
// -------------------------------------------------------------
class TawafPage extends StatelessWidget {
  final String title;
  final bool high;
  final double frameHeight;
  final List<Widget> Function(FigmaCanvas c) body;

  const TawafPage({super.key, required this.title, required this.body, this.high = false, this.frameHeight = 852});

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: title,
      titleRight: high ? 344 : 347.5,
      chevronLeft: high ? 363.5 : 364.75,
      headerDy: high ? -11 : -2,
      frameHeight: frameHeight,
      body: body,
    );
  }
}
