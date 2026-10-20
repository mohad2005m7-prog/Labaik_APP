import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../l10n/lost_child_text.dart';
import 'help_colors.dart';

// -------------------------------------------------------------
// قائمة "العمر التقريبي للطفل" (القائمة نفسها مش مصممة بـ Figma — بنفس ألوان وخط الشاشة)
// من سنة لـ 15 سنة — بترجع العمر المختار أو null لو سكّر
// -------------------------------------------------------------
Future<int?> showAgePicker(BuildContext context, {int? selected}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (context) {
      final s = DesignScale.of(context);
      TextStyle style(bool chosen) => figmaText(s, size: 16, weight: chosen ? FigmaWeight.semiBold : FigmaWeight.sfRegular, color: HelpColors.green, lineHeight: null, letterSpacing: 0);
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.6),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: s.y(8)),
            children: [
              for (var years = 1; years <= 15; years++)
                InkWell(
                  onTap: () => Navigator.pop(context, years),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: s.x(16), vertical: s.y(12)),
                    child: Row(
                      children: [
                        Expanded(child: Text(LostChildText.age(years), style: style(years == selected))),
                        if (years == selected) Icon(Icons.check_rounded, color: HelpColors.green, size: s.x(20)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
