import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/api_error_text.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../l10n/company_forms_text.dart';
import 'company_colors.dart';

/// حقل نص بنموذج الشركة
class CompanySheetField {
  final String label;
  final String hint;
  final TextInputType keyboard;
  final bool required;
  final TextEditingController controller;

  CompanySheetField({required this.label, required this.hint, this.keyboard = TextInputType.text, this.required = true, String initial = ''})
      : controller = TextEditingController(text: initial);

  String get value => controller.text.trim();
}

/// اختيار من قائمة (الرحلة، أو المشرف) — [labels] بنفس ترتيب القيم
class CompanySheetChoice {
  final String label;
  final List<String> labels;
  int index;

  CompanySheetChoice({required this.label, required this.labels, this.index = 0});
}

// -------------------------------------------------------------
// نموذج منبثق من تحت لواجهة الشركة (إنشاء مجموعة، إضافة عضو، إضافة/تعيين مشرف)
// بنفس ستايل حقول "إنشاء رحلة جديدة" (#F9F9F9 وحدود #E5E5EA وزر أخضر)
// [onSubmit] بيرمي الخطأ لو فشل — الرسالة بتطلع جوّا النموذج وبيضل مفتوح، ولو نجح بيتسكّر ويرجع true
// [conflictMessage] = رسالة 409 (موجود من قبل)
// -------------------------------------------------------------
class CompanyFormSheet extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<CompanySheetField> fields;
  final CompanySheetChoice? choice;
  final String submitLabel;
  final String? conflictMessage;
  final String? notFoundMessage;
  final Future<void> Function() onSubmit;

  const CompanyFormSheet({
    super.key,
    required this.title,
    required this.fields,
    required this.submitLabel,
    required this.onSubmit,
    this.subtitle,
    this.choice,
    this.conflictMessage,
    this.notFoundMessage,
  });

  static Future<bool> show(BuildContext context, CompanyFormSheet sheet) async {
    final done = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => sheet,
    );
    return done ?? false;
  }

  @override
  State<CompanyFormSheet> createState() => _CompanyFormSheetState();
}

class _CompanyFormSheetState extends State<CompanyFormSheet> {
  bool _busy = false;
  String? _error;

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  // الحقول بتنسكّر مع النموذج نفسه (بعد ما يخلص أنيميشن الإغلاق) — القيم بتنقرأ بـ onSubmit قبلها
  @override
  void dispose() {
    for (final f in widget.fields) {
      f.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    for (final f in widget.fields) {
      if (f.required && f.value.isEmpty) return setState(() => _error = CompanyFormsText.fillRequired());
      if (f.keyboard == TextInputType.emailAddress && f.value.isNotEmpty && !_email.hasMatch(f.value)) {
        return setState(() => _error = CompanyFormsText.invalidEmail());
      }
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onSubmit();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = switch (e) {
          ApiException(statusCode: 409) when widget.conflictMessage != null => widget.conflictMessage,
          ApiException(statusCode: 404) when widget.notFoundMessage != null => widget.notFoundMessage,
          ApiException(statusCode: 400 || 422) => CompanyFormsText.invalidData(),
          _ => ApiErrorText.of(e)(),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    TextStyle text(double size, double weight, Color color) => figmaText(s, size: size, weight: weight, color: color, lineHeight: null, letterSpacing: 0);
    final choice = widget.choice;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(s.x(16), s.x(8), s.x(16), s.x(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: s.x(36), height: s.x(4), decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(s.x(2))))),
            SizedBox(height: s.x(16)),
            Text(widget.title, textAlign: TextAlign.center, style: text(18, FigmaWeight.sfBold, CompanyColors.green)),
            if (widget.subtitle != null) ...[
              SizedBox(height: s.x(6)),
              Text(widget.subtitle!, textAlign: TextAlign.center, style: text(13, FigmaWeight.sfRegular, CompanyColors.secondaryLabel)),
            ],
            SizedBox(height: s.x(12)),
            if (choice != null) ...[
              _label(s, choice.label, text),
              _box(
                s,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: choice.index,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: CompanyColors.green, size: s.x(22)),
                    style: text(14, FigmaWeight.sfRegular, CompanyColors.green),
                    items: [for (final (i, l) in choice.labels.indexed) DropdownMenuItem(value: i, child: Text(l, overflow: TextOverflow.ellipsis))],
                    onChanged: _busy ? null : (i) => setState(() => choice.index = i ?? 0),
                  ),
                ),
              ),
            ],
            for (final f in widget.fields) ...[
              _label(s, f.label, text),
              _box(
                s,
                child: TextField(
                  controller: f.controller,
                  enabled: !_busy,
                  keyboardType: f.keyboard,
                  textDirection: f.keyboard == TextInputType.emailAddress || f.keyboard == TextInputType.phone ? TextDirection.ltr : null,
                  inputFormatters: f.keyboard == TextInputType.phone ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]'))] : null,
                  cursorColor: CompanyColors.green,
                  style: text(14, FigmaWeight.sfRegular, CompanyColors.green),
                  decoration: InputDecoration.collapsed(hintText: f.hint, hintStyle: text(14, FigmaWeight.sfRegular, CompanyColors.secondaryLabel)),
                ),
              ),
            ],
            if (_error != null) ...[
              SizedBox(height: s.x(12)),
              Text(_error!, textAlign: TextAlign.center, style: text(13, FigmaWeight.sfRegular, const Color(0xFFD32F2F))),
            ],
            SizedBox(height: s.x(20)),
            SizedBox(
              height: s.x(50),
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: CompanyColors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(s.x(12)))),
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? SizedBox(width: s.x(22), height: s.x(22), child: const CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                    : Text(widget.submitLabel, style: text(16, FigmaWeight.semiBold, Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(DesignScale s, String label, TextStyle Function(double, double, Color) text) => Padding(
        padding: EdgeInsets.only(top: s.x(12), bottom: s.x(8)),
        child: Text(label, style: text(13, FigmaWeight.sfRegular, CompanyColors.green)),
      );

  Widget _box(DesignScale s, {required Widget child}) => Container(
        height: s.x(53),
        alignment: AlignmentDirectional.centerStart,
        padding: EdgeInsets.symmetric(horizontal: s.x(16)),
        decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(s.x(12)), border: Border.all(color: const Color(0xFFE5E5EA))),
        child: child,
      );
}
