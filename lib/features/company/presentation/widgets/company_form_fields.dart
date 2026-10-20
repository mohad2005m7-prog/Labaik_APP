import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import 'company_colors.dart';

// -------------------------------------------------------------
// حقول نماذج الشركة (Figma: إنشاء رحلة/مجموعة، تعديل بيانات الشركة، معلومات التواصل، إضافة مشرف، المساعدة):
// التسمية SF Compact 457 13 #1F3B2E — الحقل 53 ارتفاع #F9F9F9 بحد #E5E5EA وradius 12 والنص 14
// -------------------------------------------------------------
const _fieldFill = Color(0xFFF9F9F9);
const _fieldBorder = Color(0xFFE5E5EA);

TextStyle _fieldText(DesignScale s, Color color) => figmaText(s, size: 14, weight: FigmaWeight.sfRegular, color: color, lineHeight: null, letterSpacing: 0);

/// تسمية الحقل — طرفها [right] (بداية السطر بالعربي)
Widget companyFieldLabel(FigmaCanvas c, String text, {required double top, double right = 377, double width = 361}) => c.text(
      text,
      left: right - width,
      top: top,
      width: width,
      height: 22,
      dy: 0,
      style: c.style(13, FigmaWeight.sfRegular, CompanyColors.green, lineHeight: null, letterSpacing: 0),
    );

BoxDecoration _box(DesignScale s) => BoxDecoration(color: _fieldFill, borderRadius: BorderRadius.circular(s.x(12)), border: Border.all(color: _fieldBorder, width: s.x(1)));

/// حقل نص — [ltr] للإيميل والأرقام
class CompanyTextBox extends StatelessWidget {
  final DesignScale s;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;
  final bool multiline;
  final bool enabled;

  const CompanyTextBox({super.key, required this.s, required this.controller, required this.hint, this.keyboard, this.multiline = false, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final ltr = keyboard == TextInputType.emailAddress || keyboard == TextInputType.phone;
    return DecoratedBox(
      decoration: _box(s),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: s.x(13), vertical: multiline ? s.x(14) : 0),
        child: multiline ? _field(context, ltr) : Align(alignment: AlignmentDirectional.centerStart, child: _field(context, ltr)),
      ),
    );
  }

  Widget _field(BuildContext context, bool ltr) => TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: multiline ? TextInputType.multiline : keyboard,
          maxLines: multiline ? null : 1,
          expands: multiline,
          textAlign: ltr ? TextAlign.right : TextAlign.start,
          textDirection: ltr ? TextDirection.ltr : null,
          textAlignVertical: multiline ? TextAlignVertical.top : TextAlignVertical.center,
          inputFormatters: keyboard == TextInputType.phone ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]'))] : null,
          cursorColor: CompanyColors.green,
          style: _fieldText(s, CompanyColors.green),
          decoration: InputDecoration.collapsed(hintText: hint, hintStyle: _fieldText(s, CompanyColors.secondaryLabel)),
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
        );
}

/// حقل اختيار (السهم ⌄ بآخره) — [value] null = التلميح
class CompanyPickerBox extends StatelessWidget {
  final DesignScale s;
  final String? value;
  final String hint;
  final VoidCallback onTap;

  const CompanyPickerBox({super.key, required this.s, required this.value, required this.hint, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: _box(s),
          child: Padding(
            padding: EdgeInsetsDirectional.only(start: s.x(13), end: s.x(16)),
            child: Row(
              children: [
                Expanded(child: Text(value ?? hint, maxLines: 1, overflow: TextOverflow.ellipsis, style: _fieldText(s, value == null ? CompanyColors.secondaryLabel : CompanyColors.green))),
                Icon(Icons.keyboard_arrow_down_rounded, size: s.x(24), color: CompanyColors.green),
              ],
            ),
          ),
        ),
      );
}

/// فوق الزر أثناء الحفظ
class CompanyBusyButton extends StatelessWidget {
  const CompanyBusyButton({super.key});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(color: CompanyColors.green, borderRadius: BorderRadius.circular(14)),
        child: const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))),
      );
}

/// قائمة اختيار من تحت — بترجع رقم الخيار (أو null لو سكّرها)
Future<int?> companyPickOne(BuildContext context, List<String> options, {int? selected}) {
  final s = DesignScale.of(context);
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.6),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: s.x(8)),
          children: [
            Center(child: Container(width: s.x(36), height: s.x(4), decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(s.x(2))))),
            SizedBox(height: s.x(8)),
            for (final (i, label) in options.indexed)
              ListTile(
                title: Text(label, style: _fieldText(s, CompanyColors.green).copyWith(fontSize: s.x(16), fontWeight: i == selected ? FontWeight.bold : null)),
                trailing: i == selected ? Icon(Icons.check_rounded, color: CompanyColors.green, size: s.x(22)) : null,
                onTap: () => Navigator.pop(ctx, i),
              ),
          ],
        ),
      ),
    ),
  );
}
