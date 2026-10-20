import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../l10n/trip_edit_text.dart';
import 'trip_colors.dart';
import 'trip_search_field.dart';

// -------------------------------------------------------------
// محطة بمسار الرحلة (Figma 6تعديل): "وجهتك الاولى/التالية" (SF Compact 457 12 #1F3B2E طرفه عند x342)
// وتحتها بـ 22 حقل الاختيار (من x22.82)
// -------------------------------------------------------------
class TripRouteStop extends StatelessWidget {
  final FigmaCanvas c;
  final double top;
  final String label;
  final String? city;
  final String hint;
  final VoidCallback onTap;

  const TripRouteStop({super.key, required this.c, required this.top, required this.label, required this.city, required this.hint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.text(label, left: 142, top: top, width: 200, height: 14, dy: 0, style: c.style(12, FigmaWeight.sfRegular, TripColors.green, lineHeight: null, letterSpacing: 0)),
        Positioned.fill(child: TripSearchField(c: c, left: 22.82, top: top + 22, text: city ?? hint, empty: city == null, onTap: onTap)),
      ],
    );
  }
}

/// "+ إضافة محطة" (SF Compact 457 12 #1F3B2E — صندوقه 266..338)
class TripAddStop extends StatelessWidget {
  final FigmaCanvas c;
  final double top;
  final VoidCallback onTap;

  const TripAddStop({super.key, required this.c, required this.top, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.text(TripEditText.addStop(), left: 138, top: top, width: 200, height: 14, dy: 0, style: c.style(12, FigmaWeight.sfRegular, TripColors.green, lineHeight: null, letterSpacing: 0)),
        c.tapArea(left: 258, top: top - 11, width: 88, height: 36, onTap: onTap),
      ],
    );
  }
}
