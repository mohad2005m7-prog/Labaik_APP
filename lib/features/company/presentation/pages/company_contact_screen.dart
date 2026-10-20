import 'package:flutter/material.dart';

import '../../../../core/widgets/figma_page.dart';
import '../../domain/entities/company_profile.dart';
import '../../domain/repositories/company_repository.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_profile_text.dart';
import '../widgets/company_form_fields.dart';

// -------------------------------------------------------------
// "معلومات التواصل" — مطابقة لـ Figma 672:4061
// البريد الإلكتروني الرسمي / رقم الهاتف / اسم مسؤول الشركة + "حفظ التعديلات"
// الحفظ: PUT /company/me (officialEmail / primaryPhone / contactFullName — والباقي زي ما هو)
// -------------------------------------------------------------
class CompanyContactScreen extends StatefulWidget {
  final CompanyRepository repository;
  final CompanyProfile profile;

  const CompanyContactScreen({super.key, required this.repository, required this.profile});

  @override
  State<CompanyContactScreen> createState() => _CompanyContactScreenState();
}

class _CompanyContactScreenState extends State<CompanyContactScreen> {
  late final _email = TextEditingController(text: widget.profile.email ?? '');
  late final _phone = TextEditingController(text: widget.profile.phone ?? '');
  late final _contact = TextEditingController(text: widget.profile.contactName);
  bool _busy = false;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _contact.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_busy) return;
    if (_contact.text.trim().isEmpty) return CompanyController.showMessage(context, CompanyProfileText.required());
    final email = _email.text.trim();
    if (email.isNotEmpty && !_emailPattern.hasMatch(email)) return CompanyController.showMessage(context, CompanyProfileText.invalidEmail());
    setState(() => _busy = true);
    try {
      final saved = await widget.repository.updateProfile(widget.profile.copyWith(email: email, phone: _phone.text, contactName: _contact.text));
      if (!mounted) return;
      CompanyController.showMessage(context, CompanyProfileText.saved());
      Navigator.of(context).pop(saved);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      CompanyController.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: CompanyProfileText.contactInfo(),
      titleRight: 349,
      chevronLeft: 367,
      body: (c) => [
        c.box(left: 17, top: 108, width: 360, height: 1, color: const Color(0xFFE5E5EA)),
        companyFieldLabel(c, CompanyProfileText.officialEmail(), top: 130, right: 382, width: 366),
        c.rect(left: 16, top: 160, width: 366, height: 53, child: CompanyTextBox(s: c.s, controller: _email, hint: CompanyProfileText.emailHint(), keyboard: TextInputType.emailAddress)),
        companyFieldLabel(c, CompanyProfileText.phone(), top: 229, right: 382, width: 366),
        c.rect(left: 16, top: 259, width: 366, height: 53, child: CompanyTextBox(s: c.s, controller: _phone, hint: CompanyProfileText.phoneHint(), keyboard: TextInputType.phone)),
        companyFieldLabel(c, CompanyProfileText.contactName(), top: 328, right: 382, width: 366),
        c.rect(left: 16, top: 358, width: 366, height: 53, child: CompanyTextBox(s: c.s, controller: _contact, hint: CompanyProfileText.contactNameHint())),
        c.button(CompanyProfileText.save(), left: 16, top: 449, width: 366, figmaSpacing: true, onTap: _save),
        if (_busy) c.rect(left: 16, top: 449, width: 366, height: 50, child: const CompanyBusyButton()),
      ],
    );
  }
}
