import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_page.dart';
import '../l10n/company_profile_text.dart';
import '../widgets/company_colors.dart';

// -------------------------------------------------------------
// "بيانات الشركة" — Figma (393×852) → FigmaPage
// 3 حقول: اسم الشركة / رقم الترخيص / العنوان + زر حفظ
// -------------------------------------------------------------
class CompanyDataScreen extends StatefulWidget {
  const CompanyDataScreen({super.key});

  @override
  State<CompanyDataScreen> createState() => _CompanyDataScreenState();
}

class _CompanyDataScreenState extends State<CompanyDataScreen> {
  final _name = TextEditingController();
  final _license = TextEditingController();
  final _address = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _license.dispose();
    _address.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_name.text.trim().isEmpty) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: CompanyProfileText.companyDataTitle(),
      titleRight: 349,
      chevronLeft: 367,
      body: (c) => [
        _label(c, CompanyProfileText.companyName(), 120),
        _field(c, _name, CompanyProfileText.companyNameHint(), 163.5),
        _label(c, CompanyProfileText.licenseNumber(), 211),
        _field(c, _license, CompanyProfileText.licenseNumberHint(), 254.5),
        _label(c, CompanyProfileText.address(), 302),
        _field(c, _address, CompanyProfileText.addressHint(), 345.5),
        c.button(CompanyProfileText.saveButton(), left: 23.5, top: 503, figmaSpacing: true, onTap: _submit),
      ],
    );
  }

  Widget _label(dynamic c, String text, double top) => c.text(
        text,
        left: 16,
        top: top,
        width: 361,
        height: 22,
        align: TextAlign.end,
        dy: 0,
        style: c.style(13, FigmaWeight.sfRegular, CompanyColors.green, lineHeight: null, letterSpacing: 0),
      );

  Widget _field(dynamic c, TextEditingController ctrl, String hint, double top) => c.rect(
        left: 15.5,
        top: top,
        width: 361,
        height: 52,
        child: _CompanyTextField(controller: ctrl, hint: hint),
      );
}

class _CompanyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _CompanyTextField({required this.controller, required this.hint});

  static const _bg = Color(0xFFF9F9F9);
  static const _border = Color(0xFFE5E5EA);

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 14, color: CompanyColors.green, fontFamily: 'NotoSansArabic', fontVariations: const [FontVariation('wght', FigmaWeight.sfRegular)]);
    return DecoratedBox(
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: controller,
          style: style,
          textAlignVertical: TextAlignVertical.center,
          cursorColor: CompanyColors.green,
          decoration: InputDecoration.collapsed(hintText: hint, hintStyle: style.copyWith(color: CompanyColors.secondaryLabel)),
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
        ),
      ),
    );
  }
}
