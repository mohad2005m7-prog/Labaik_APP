import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/content_direction.dart';
import '../../../../core/utils/design_scale.dart';
import 'budget_colors.dart';

// -------------------------------------------------------------
// حقل بشاشة الميزانية ("شو اشتريت؟" / "كم دفعت؟"): أبيض بحد #1F3B2E 1 — radius 10 — طوله 41
// النص والـ placeholder (#717171) على بعد [textInset] من البداية
// -------------------------------------------------------------
class BudgetInputField extends StatelessWidget {
  final DesignScale s;
  final TextEditingController controller;
  final String hint;
  final bool amount;
  final bool autofocus;

  /// بُعد النص من بداية الحقل (Figma: 33 لـ "شو اشتريت؟" و 35.5 لـ "كم دفعت؟")
  final double textInset;

  const BudgetInputField({super.key, required this.s, required this.controller, required this.hint, this.amount = false, this.autofocus = false, this.textInset = 33});

  static const height = 41.0;

  @override
  Widget build(BuildContext context) {
    TextStyle style(Color color) => figmaText(s, size: 16, weight: FigmaWeight.sfRegular, color: color, lineHeight: null, letterSpacing: 0);
    return Container(
      height: s.y(height),
      alignment: AlignmentDirectional.centerStart,
      padding: EdgeInsetsDirectional.only(start: s.x(textInset), end: s.x(16), bottom: s.y(6)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s.x(10)),
        border: Border.all(color: BudgetColors.green, width: s.x(1)),
      ),
      // اتجاه الكتابة حسب لغة اللي بينكتب
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => TextField(
          controller: controller,
          autofocus: autofocus,
          textDirection: contentDirection(value.text),
          maxLines: 1,
          keyboardType: amount ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          textInputAction: amount ? TextInputAction.done : TextInputAction.next,
          style: style(Colors.black),
          cursorColor: BudgetColors.green,
          decoration: InputDecoration.collapsed(hintText: hint, hintStyle: style(BudgetColors.grey)),
        ),
      ),
    );
  }
}
