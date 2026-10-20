import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import 'family_colors.dart';

// -------------------------------------------------------------
// "SegmentedPicker" (Figma 343×32 — #767680 24% radius 8 وحشوة 2):
// المختار أخضر #1F3B2E radius 7 ونصه أبيض — الثاني نصه أسود — التبويب الأول يمين بالعربي
// التبديل بحركة ناعمة
// -------------------------------------------------------------
class FamilySegmented extends StatelessWidget {
  final DesignScale s;
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  const FamilySegmented({super.key, required this.s, required this.labels, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    TextStyle style(bool chosen) => figmaText(s, size: 13, weight: FigmaWeight.semiBold, color: chosen ? Colors.white : Colors.black, lineHeight: null, letterSpacing: 0);
    return Container(
      padding: EdgeInsets.all(s.x(2)),
      decoration: BoxDecoration(color: FamilyColors.segmentFill, borderRadius: BorderRadius.circular(s.x(8))),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth / labels.length;
          return Stack(
            children: [
              AnimatedPositionedDirectional(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                start: width * selected,
                top: 0,
                bottom: 0,
                width: width,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: FamilyColors.green,
                    borderRadius: BorderRadius.circular(s.x(7)),
                    boxShadow: [BoxShadow(color: const Color(0x1F000000), offset: Offset(0, s.y(3)), blurRadius: s.x(8))],
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onSelect(i),
                        child: Center(
                          child: FittedBox(fit: BoxFit.scaleDown, child: Text(labels[i], maxLines: 1, style: style(i == selected))),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
