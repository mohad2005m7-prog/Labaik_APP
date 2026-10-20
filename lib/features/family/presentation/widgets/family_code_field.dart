import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import 'family_colors.dart';

// -------------------------------------------------------------
// خانة "أدخل رمز المجموعة" (Figma 357.5×39 أبيض بحد أسود و radius 10):
// "مثال: UMRAH25" رمادي من اليمين — الرمز بيتكتب بالإنجليزي وأحرف كبيرة (A-Z و 0-9 بس)
// -------------------------------------------------------------
class FamilyCodeField extends StatelessWidget {
  final DesignScale s;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final VoidCallback onSubmit;

  const FamilyCodeField({super.key, required this.s, required this.controller, required this.focusNode, required this.hint, required this.onSubmit});

  static const maxLength = 12;

  @override
  Widget build(BuildContext context) {
    final style = figmaText(s, size: 13.25, weight: FigmaWeight.sfRegular, color: Colors.black, lineHeight: null, letterSpacing: 0);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: focusNode.requestFocus,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(s.x(10)),
          border: Border.all(color: Colors.black, width: s.x(1)),
        ),
        padding: EdgeInsetsDirectional.only(start: s.x(11), end: s.x(11)),
        alignment: AlignmentDirectional.centerStart,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          style: style.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontVariations: const []),
          cursorColor: FamilyColors.green,
          textCapitalization: TextCapitalization.characters,
          keyboardType: TextInputType.visiblePassword,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmit(),
          inputFormatters: [_UpperCode(), LengthLimitingTextInputFormatter(maxLength)],
          decoration: InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
            hint: Text.rich(poppinsLatinSpan(hint, style.copyWith(color: FamilyColors.grey), latinWeight: FontWeight.w400), maxLines: 1),
          ),
        ),
      ),
    );
  }
}

/// أحرف إنجليزية كبيرة وأرقام بس (الرمز ما فيه مسافات ولا رموز)
class _UpperCode extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (text == newValue.text) return newValue;
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
