import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/content_direction.dart';
import '../../../../core/utils/design_scale.dart';
import 'family_colors.dart';
import 'family_icons.dart';

// -------------------------------------------------------------
// خانة البحث بـ "أفراد عائلتي" (Figma 345×36 — #767680 12% radius 10):
// العدسة سودا 15×15 (طرفها بعد 31 من حافة الخانة) و"بحث" أسود قبلها — الكتابة بتفلتر الأفراد بالاسم
// -------------------------------------------------------------
class FamilySearchField extends StatefulWidget {
  final DesignScale s;
  final String hint;
  final ValueChanged<String> onChanged;

  /// من طرف الخانة لطرف العدسة (العائلة 31 — المجموعة 4)
  final double startPad;

  const FamilySearchField({super.key, required this.s, required this.hint, required this.onChanged, this.startPad = 31});

  @override
  State<FamilySearchField> createState() => _FamilySearchFieldState();
}

class _FamilySearchFieldState extends State<FamilySearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final style = figmaText(s, size: 15, weight: FigmaWeight.sfRegular, color: Colors.black, lineHeight: null, letterSpacing: 0);
    return Container(
      decoration: BoxDecoration(color: FamilyColors.searchFill, borderRadius: BorderRadius.circular(s.x(10))),
      padding: EdgeInsetsDirectional.only(start: s.x(widget.startPad), end: s.x(12)),
      child: Row(
        children: [
          SearchLensIcon(size: s.x(15)),
          SizedBox(width: s.x(5.5)),
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) => TextField(
                controller: _controller,
                textDirection: contentDirection(value.text),
                onChanged: widget.onChanged,
                style: style,
                cursorColor: FamilyColors.green,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(isCollapsed: true, border: InputBorder.none, hintText: widget.hint, hintStyle: style),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
