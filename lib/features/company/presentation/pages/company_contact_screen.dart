import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_page.dart';
import '../l10n/company_profile_text.dart';
import '../widgets/company_colors.dart';

// -------------------------------------------------------------
// "معلومات التواصل" — Figma (393×852) → FigmaPage
// 3 حقول: رقم الهاتف / البريد الإلكتروني / الموقع الإلكتروني + زر حفظ
// -------------------------------------------------------------
class CompanyContactScreen extends StatefulWidget {
  const CompanyContactScreen({super.key});

  @override
  State<CompanyContactScreen> createState() => _CompanyContactScreenState();
}

class _CompanyContactScreenState extends State<CompanyContactScreen> {
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _website = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    _website.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: CompanyProfileText.contactTitle(),
      titleRight: 349,
      chevronLeft: 367,
      body: (c) => [
        _label(c, CompanyProfileText.phone(), 117),
        _field(c, _phone, CompanyProfileText.phoneHint(), 160.5, keyboard: TextInputType.phone),
        _label(c, CompanyProfileText.email(), 216),
        _field(c, _email, CompanyProfileText.emailHint(), 259.5, keyboard: TextInputType.emailAddress),
        _label(c, CompanyProfileText.website(), 315),
        _field(c, _website, CompanyProfileText.websiteHint(), 358.5, keyboard: TextInputType.url),
        c.button(CompanyProfileText.saveButton(), left: 16, top: 449, figmaSpacing: true, onTap: _submit),
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

  Widget _field(dynamic c, TextEditingController ctrl, String hint, double top, {TextInputType? keyboard}) => c.rect(
        left: 16.5,
        top: top,
        width: 365,
        height: 52,
        child: _ContactTextField(controller: ctrl, hint: hint, keyboard: keyboard),
      );
}

class _ContactTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;

  const _ContactTextField({required this.controller, required this.hint, this.keyboard});

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
          keyboardType: keyboard,
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
