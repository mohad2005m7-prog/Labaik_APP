import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/content_direction.dart';
import '../../../../core/utils/figma_canvas.dart';
import 'duas_colors.dart';

// -------------------------------------------------------------
// حقل بشاشة إضافة دعاء ("Rectangle 138/140"): x18 عرض 359 — أبيض بحد أسود 1 — radius 10
// النص والـ placeholder (16 #717171) على بعد 20 من الطرفين و [textTop] من فوق
// [multiline]: مربع نص الدعاء (418 طول) — بيكتب فيه كذا سطر وبيتمرر جواته
// -------------------------------------------------------------
class DuaInputField extends StatelessWidget {
  final FigmaCanvas c;
  final double top;
  final double height;
  final double textTop;
  final TextEditingController controller;
  final String hint;
  final bool multiline;

  const DuaInputField({
    super.key,
    required this.c,
    required this.top,
    required this.height,
    required this.textTop,
    required this.controller,
    required this.hint,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    TextStyle style(Color color) => c.style(16, FigmaWeight.sfRegular, color, lineHeight: null, letterSpacing: 0);
    return c.rect(
      left: 18,
      top: top,
      width: 359,
      height: height,
      child: Container(
        alignment: AlignmentDirectional.topStart,
        padding: EdgeInsetsDirectional.only(start: s.x(20), end: s.x(20), top: s.y(textTop), bottom: s.y(multiline ? 10 : 0)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(s.x(10)),
          border: Border.all(color: Colors.black, width: s.x(1)),
        ),
        // اتجاه الكتابة حسب لغة اللي بينكتب (دعاء عربي بالواجهة الإنجليزية بيضل من اليمين)
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => TextField(
            controller: controller,
            textDirection: contentDirection(value.text),
            maxLines: multiline ? null : 1,
            expands: multiline,
            textAlignVertical: TextAlignVertical.top,
            keyboardType: multiline ? TextInputType.multiline : TextInputType.text,
            textInputAction: multiline ? TextInputAction.newline : TextInputAction.next,
            style: style(Colors.black),
            cursorColor: DuasColors.green,
            decoration: InputDecoration.collapsed(hintText: hint, hintStyle: style(DuasColors.grey)),
          ),
        ),
      ),
    );
  }
}
