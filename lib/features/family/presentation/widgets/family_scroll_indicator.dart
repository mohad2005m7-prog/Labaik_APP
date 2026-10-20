import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/design_scale.dart';

// -------------------------------------------------------------
// شريط التمرير جنب القائمة (Figma "Line 15": مسار أسود بخط 5 وفوقه الجزء الظاهر رمادي #717171 بخط 3)
// محسوب من القائمة الفعلية: طول الرمادي = نسبة الظاهر من كل الأفراد، ومكانه = قديش نزلت
// (لو كل الأفراد ظاهرين الرمادي بياخد المسار كله) — [metrics]: من FamilyScrollIndicator.track حوالين القائمة
// -------------------------------------------------------------
class FamilyScrollIndicator extends StatelessWidget {
  final DesignScale s;
  final ValueListenable<ScrollMetrics?> metrics;

  const FamilyScrollIndicator({super.key, required this.s, required this.metrics});

  static const _thumb = Color(0xFF717171);

  /// القائمة [child] بتحدّث [metrics] مع كل تمرير أو تغيير بطولها (أفراد انضافوا، بحث...)
  static Widget track(ValueNotifier<ScrollMetrics?> metrics, Widget child) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (n) {
        metrics.value = n.metrics.copyWith();
        return false;
      },
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (n) {
          metrics.value = n.metrics.copyWith();
          return false;
        },
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(s.x(2.5));
    return LayoutBuilder(
      builder: (context, constraints) => ValueListenableBuilder<ScrollMetrics?>(
        valueListenable: metrics,
        builder: (context, m, _) {
          final height = constraints.maxHeight;
          var thumb = height, offset = 0.0;
          if (m != null && m.hasContentDimensions && m.maxScrollExtent > 0) {
            final content = m.maxScrollExtent + m.viewportDimension;
            thumb = math.min(height, math.max(s.y(40), height * m.viewportDimension / content));
            offset = (height - thumb) * (m.pixels / m.maxScrollExtent).clamp(0.0, 1.0);
          }
          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(radius))),
              ),
              // الرمادي بنص الأسود (3 من 5)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: offset),
                    child: SizedBox(
                      width: s.x(3),
                      height: thumb,
                      child: DecoratedBox(decoration: BoxDecoration(color: _thumb, borderRadius: BorderRadius.circular(s.x(1.5)))),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
