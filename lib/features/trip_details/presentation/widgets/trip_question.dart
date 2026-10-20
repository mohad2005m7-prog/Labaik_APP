import 'package:flutter/material.dart';

import '../../../../core/theme/figma_spaced_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import 'trip_colors.dart';

// -------------------------------------------------------------
// السؤال جوّا كرت التعديل: العنوان (SF Compact 790 20 #1F3B2E — line height auto بدون letter spacing)
// والشرح تحته (#4C7A75 14) — طرفهم اليمين عند x353 بكل الإطارات
// -------------------------------------------------------------
abstract final class TripQuestion {
  static const right = 353.0;

  static Widget title(FigmaCanvas c, String text, {double top = 231, double end = right}) {
    return c.text(text, left: end - 330, top: top, width: 330, height: 24, dy: 0, style: c.style(20, FigmaWeight.sfBold, TripColors.green, lineHeight: null, letterSpacing: 0));
  }

  /// شرح بـ line height auto وبدون letter spacing (السطور مكسورة بـ "\n" زي Figma)
  static Widget plain(FigmaCanvas c, String text, {required double weight, double top = 263, int lines = 1}) {
    return c.text(text, left: right - 330, top: top, width: 330, height: 16.7 * lines, dy: 0, style: c.style(14, weight, TripColors.teal, lineHeight: null, letterSpacing: 0));
  }

  /// شرح SemiBold 14 بـ line height 22 و letter spacing -0.408 — السطور مكسورة بـ "\n" زي Figma
  /// (والإنجليزي بيلتف بعرض صندوق Figma)
  static Widget spaced(FigmaCanvas c, String text, {required double width, double top = 263, int lines = 1, double end = right}) {
    final parts = text.split('\n');
    return c.rect(
      left: end - width,
      top: top + FigmaCanvas.baselineFix,
      width: width,
      height: 22.0 * lines,
      child: IgnorePointer(
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final part in parts)
                FigmaSpacedText(part, style: c.style(14, FigmaWeight.semiBold, TripColors.teal), letterSpacing: c.s.x(-0.408), width: c.s.x(width), maxLines: lines - parts.length + 1),
            ],
          ),
        ),
      ),
    );
  }
}
