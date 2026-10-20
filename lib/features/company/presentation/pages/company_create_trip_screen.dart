import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../../supervisor/presentation/widgets/supervisor_format.dart';
import '../l10n/company_create_trip_text.dart';
import '../widgets/company_colors.dart';

// -------------------------------------------------------------
// "إنشاء رحلة جديدة" — Figma 572:3961 (393×1046) → FigmaPage frameHeight 1046
// الحقول: نوع الرحلة (dropdown) / الاسم / الوجهات / تاريخا الذهاب والعودة / العدد / الانطلاق / ملاحظات
// بعد "إنشاء الرحلة" بيطلع بوب-أب "تم إنشاء الرحلة" (647:4722) 391×353
// الباك-اند ما فيه دعم للشركة بعد — الشاشة UI فقط وبتتحدّث بعد ما يضيف الصديق الـ endpoints
// -------------------------------------------------------------
class CompanyCreateTripScreen extends StatefulWidget {
  const CompanyCreateTripScreen({super.key});

  @override
  State<CompanyCreateTripScreen> createState() => _CompanyCreateTripScreenState();
}

class _CompanyCreateTripScreenState extends State<CompanyCreateTripScreen> {
  int _tripTypeIndex = 0; // 0 = عمرة، 1 = حج
  final _name = TextEditingController();
  final _destinations = TextEditingController();
  DateTime? _departureDate;
  DateTime? _returnDate;
  final _pilgrims = TextEditingController();
  final _departurePoint = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _destinations, _pilgrims, _departurePoint, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _pickTripType() {
    final types = [CompanyCreateTripText.typeUmrah(), CompanyCreateTripText.typeHajj()];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        final s = DesignScale.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: s.x(8)),
              Container(width: s.x(36), height: s.x(4), decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(s.x(2)))),
              SizedBox(height: s.x(8)),
              for (final (i, label) in types.indexed)
                ListTile(
                  title: Text(label, style: TextStyle(fontSize: s.x(16), color: _tripTypeIndex == i ? CompanyColors.green : Colors.black87, fontWeight: _tripTypeIndex == i ? FontWeight.bold : FontWeight.normal)),
                  trailing: _tripTypeIndex == i ? Icon(Icons.check_rounded, color: CompanyColors.green, size: s.x(22)) : null,
                  onTap: () {
                    setState(() => _tripTypeIndex = i);
                    Navigator.pop(ctx);
                  },
                ),
              SizedBox(height: s.x(8)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDate(bool departure) async {
    final now = DateTime.now();
    final initial = departure ? (_departureDate ?? now.add(const Duration(days: 30))) : (_returnDate ?? (_departureDate ?? now).add(const Duration(days: 14)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null && mounted) {
      setState(() {
        if (departure) {
          _departureDate = picked;
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_name.text.trim().isEmpty) return;
    _showSuccess();
  }

  void _showSuccess() {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (a, animation, b, child) => FadeTransition(opacity: animation, child: child),
      pageBuilder: (a, b, c2) => _TripCreatedDialog(
        onBack: () {
          Navigator.of(context).pop(); // dialog
          Navigator.of(context).pop(); // form screen
        },
      ),
    );
  }

  // ──── مواضع Figma (إطار 393×1046) ────
  // تسمية (22) → حقل (53) → فراغ (20) per section
  // تسمية → y: 113 / 216 / 319 / 422 / 525 / 628 / 731 / 834
  // حقل   → y: 143 / 246 / 349 / 452 / 555 / 658 / 761 / 864  (آخرها textarea 74)
  // زر    → y: 962  (height 50)

  @override
  Widget build(BuildContext context) {
    final types = [CompanyCreateTripText.typeUmrah(), CompanyCreateTripText.typeHajj()];
    return FigmaPage(
      title: CompanyCreateTripText.title(),
      titleRight: 349,
      chevronLeft: 367,
      frameHeight: 1046,
      body: (c) {
        final s = c.s;

        Widget label(String text, double top) => c.text(
              text,
              left: 16,
              top: top,
              width: 361,
              height: 22,
              align: TextAlign.start,
              dy: 0,
              style: c.style(13, FigmaWeight.sfRegular, CompanyColors.green, lineHeight: null, letterSpacing: 0),
            );

        Widget textField(TextEditingController ctrl, String hint, double top, {TextInputType? keyboard, bool multiline = false}) {
          return c.rect(
            left: 16,
            top: top,
            width: 361,
            height: multiline ? 74 : 53,
            child: _FormField(s: s, controller: ctrl, hint: hint, keyboard: keyboard, multiline: multiline),
          );
        }

        Widget dateField(DateTime? date, String hint, double top, bool departure) {
          return c.rect(
            left: 16,
            top: top,
            width: 361,
            height: 53,
            child: _DateField(s: s, date: date, hint: hint, onTap: () => _pickDate(departure)),
          );
        }

        return [
          // 1. نوع الرحلة
          label(CompanyCreateTripText.tripType(), 113),
          c.rect(
            left: 16,
            top: 143,
            width: 361,
            height: 53,
            child: _DropdownField(s: s, value: types[_tripTypeIndex], onTap: _pickTripType),
          ),
          // 2. اسم الرحلة
          label(CompanyCreateTripText.tripName(), 216),
          textField(_name, CompanyCreateTripText.tripNameHint(), 246),
          // 3. الوجهات
          label(CompanyCreateTripText.destinations(), 319),
          textField(_destinations, CompanyCreateTripText.destinationsHint(), 349),
          // 4. تاريخ الذهاب
          label(CompanyCreateTripText.departureDate(), 422),
          dateField(_departureDate, CompanyCreateTripText.departureDateHint(), 452, true),
          // 5. تاريخ العودة
          label(CompanyCreateTripText.returnDate(), 525),
          dateField(_returnDate, CompanyCreateTripText.returnDateHint(), 555, false),
          // 6. عدد المعتمرين
          label(CompanyCreateTripText.pilgrimsCount(), 628),
          textField(_pilgrims, CompanyCreateTripText.pilgrimsCountHint(), 658, keyboard: TextInputType.number),
          // 7. مكان الانطلاق
          label(CompanyCreateTripText.departurePoint(), 731),
          textField(_departurePoint, CompanyCreateTripText.departurePointHint(), 761),
          // 8. ملاحظات إضافية (اختياري)
          label(CompanyCreateTripText.notesLabel(), 834),
          textField(_notes, CompanyCreateTripText.notesHint(), 864, multiline: true),
          // زر "إنشاء الرحلة"
          c.button(CompanyCreateTripText.createButton(), left: 16, top: 962, figmaSpacing: true, onTap: _submit),
        ];
      },
    );
  }
}

// ──── حقل نص عادي ────

class _FormField extends StatelessWidget {
  final DesignScale s;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;
  final bool multiline;

  const _FormField({required this.s, required this.controller, required this.hint, this.keyboard, this.multiline = false});

  static const _bg = Color(0xFFF9F9F9);
  static const _border = Color(0xFFE5E5EA);

  @override
  Widget build(BuildContext context) {
    final style = figmaText(s, size: 14, weight: FigmaWeight.sfRegular, color: CompanyColors.green, lineHeight: null, letterSpacing: 0);
    return DecoratedBox(
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(s.x(12)), border: Border.all(color: _border, width: s.x(1))),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(s.x(16), multiline ? s.x(12) : 0, s.x(16), multiline ? s.x(12) : 0),
        child: TextField(
          controller: controller,
          keyboardType: multiline ? TextInputType.multiline : keyboard,
          maxLines: multiline ? null : 1,
          textInputAction: multiline ? TextInputAction.newline : TextInputAction.next,
          textAlignVertical: multiline ? TextAlignVertical.top : TextAlignVertical.center,
          cursorColor: CompanyColors.green,
          inputFormatters: keyboard == TextInputType.number ? [FilteringTextInputFormatter.digitsOnly] : null,
          style: style,
          decoration: InputDecoration.collapsed(hintText: hint, hintStyle: style.copyWith(color: CompanyColors.secondaryLabel)),
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
        ),
      ),
    );
  }
}

// ──── حقل dropdown (نوع الرحلة) ────

class _DropdownField extends StatelessWidget {
  final DesignScale s;
  final String value;
  final VoidCallback onTap;

  const _DropdownField({required this.s, required this.value, required this.onTap});

  static const _bg = Color(0xFFF9F9F9);
  static const _border = Color(0xFFE5E5EA);

  @override
  Widget build(BuildContext context) {
    final style = figmaText(s, size: 14, weight: FigmaWeight.sfRegular, color: CompanyColors.green, lineHeight: null, letterSpacing: 0);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(s.x(12)), border: Border.all(color: _border, width: s.x(1))),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: s.x(16)),
          child: Row(
            children: [
              Expanded(child: Text(value, style: style, overflow: TextOverflow.ellipsis, maxLines: 1)),
              Icon(Icons.keyboard_arrow_down_rounded, size: s.x(22), color: CompanyColors.green),
            ],
          ),
        ),
      ),
    );
  }
}

// ──── حقل تاريخ (اختيار من date picker) ────

class _DateField extends StatelessWidget {
  final DesignScale s;
  final DateTime? date;
  final String hint;
  final VoidCallback onTap;

  const _DateField({required this.s, required this.date, required this.hint, required this.onTap});

  static const _bg = Color(0xFFF9F9F9);
  static const _border = Color(0xFFE5E5EA);

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    final style = figmaText(s, size: 14, weight: FigmaWeight.sfRegular, color: hasDate ? CompanyColors.green : CompanyColors.secondaryLabel, lineHeight: null, letterSpacing: 0);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(s.x(12)), border: Border.all(color: _border, width: s.x(1))),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: s.x(16)),
          child: Row(
            children: [
              Expanded(child: Text(hasDate ? SupFormat.date(date!) : hint, style: style, overflow: TextOverflow.ellipsis, maxLines: 1)),
              Icon(Icons.keyboard_arrow_down_rounded, size: s.x(22), color: CompanyColors.green),
            ],
          ),
        ),
      ),
    );
  }
}

// ──── بوب-أب "تم إنشاء الرحلة" (Figma 647:4722, 391×353) ────

class _TripCreatedDialog extends StatelessWidget {
  final VoidCallback onBack;

  const _TripCreatedDialog({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    final c = FigmaCanvas(s, originTop: 0);
    const x = 1.0; // margin جانبي بسيط
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: s.y(353),
          child: Stack(
            children: [
              c.box(left: x, top: 0, width: 391, height: 353, color: CompanyColors.card, radius: 16),
              // أيقونة النجاح 92×92 — مركزها أفقياً: (391-92)/2 = 149.5 من طرف الكرت
              c.image('assets/images/trip/ic_success.png', left: x + 149.5, top: 51, width: 92, height: 92),
              // العنوان
              c.text(
                CompanyCreateTripText.successTitle(),
                left: x + 15,
                top: 169,
                width: 361,
                height: 36,
                align: TextAlign.center,
                dy: 0,
                style: c.style(20, FigmaWeight.sfBold, CompanyColors.green, lineHeight: null, letterSpacing: 0),
              ),
              // زر "العودة للرحلات"
              c.button(CompanyCreateTripText.successButton(), left: x + 15, top: 287, figmaSpacing: true, onTap: onBack),
            ],
          ),
        ),
      ),
    );
  }
}
