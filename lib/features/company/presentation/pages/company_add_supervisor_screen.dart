import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../domain/repositories/company_repository.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_profile_text.dart';
import '../widgets/company_colors.dart';
import '../widgets/company_form_fields.dart';

// -------------------------------------------------------------
// "إضافة مشرف جديد" — مطابقة لـ Figma 681:4159
// الاسم الكامل * / البريد الإلكتروني * / رقم الهاتف * + ملاحظة الدعوة + "إضافة المشرف"
// POST /company/supervisors: إيميل جديد = حساب مشرف بكلمة مؤقتة على بريده، إيميل مسجّل = بينضاف للقائمة
// بترجع المشرف للي فتحها (تفاصيل المجموعة بتعيّنه مباشرة)
// -------------------------------------------------------------
class CompanyAddSupervisorScreen extends StatefulWidget {
  final CompanyRepository repository;

  const CompanyAddSupervisorScreen({super.key, required this.repository});

  @override
  State<CompanyAddSupervisorScreen> createState() => _CompanyAddSupervisorScreenState();
}

class _CompanyAddSupervisorScreenState extends State<CompanyAddSupervisorScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  bool _busy = false;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_busy) return;
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty || _phone.text.trim().isEmpty) return CompanyController.showMessage(context, CompanyProfileText.fillAll());
    if (!_emailPattern.hasMatch(_email.text.trim())) return CompanyController.showMessage(context, CompanyProfileText.invalidEmail());
    setState(() => _busy = true);
    try {
      final added = await widget.repository.addSupervisor(fullName: _name.text, email: _email.text, phone: _phone.text);
      if (!mounted) return;
      CompanyController.showMessage(context, CompanyProfileText.added());
      Navigator.of(context).pop(added);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      if (e is ApiException && e.statusCode == 409) return CompanyController.showMessage(context, CompanyProfileText.exists());
      CompanyController.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: CompanyProfileText.addTitle(),
      titleRight: 349,
      chevronLeft: 367,
      body: (c) => [
        c.box(left: 17, top: 108, width: 360, height: 1, color: const Color(0xFFE5E5EA)),
        companyFieldLabel(c, CompanyProfileText.fullName(), top: 133, right: 377, width: 362),
        c.rect(left: 15, top: 163, width: 362, height: 53, child: CompanyTextBox(s: c.s, controller: _name, hint: CompanyProfileText.fullNameHint())),
        companyFieldLabel(c, CompanyProfileText.email(), top: 224, right: 377, width: 362),
        c.rect(left: 15, top: 254, width: 362, height: 53, child: CompanyTextBox(s: c.s, controller: _email, hint: CompanyProfileText.supervisorEmailHint(), keyboard: TextInputType.emailAddress)),
        companyFieldLabel(c, CompanyProfileText.phoneRequired(), top: 315, right: 377, width: 362),
        c.rect(left: 15, top: 345, width: 362, height: 53, child: CompanyTextBox(s: c.s, controller: _phone, hint: CompanyProfileText.phoneEnter(), keyboard: TextInputType.phone)),
        c.rect(left: 15, top: 421, width: 362, height: 44, child: Text(CompanyProfileText.inviteNote(), maxLines: 2, style: c.style(13, FigmaWeight.sfRegular, CompanyColors.secondaryLabel, lineHeight: 22, letterSpacing: 0))),
        c.button(CompanyProfileText.add(), left: 23.5, top: 503, width: 345, figmaSpacing: true, onTap: _submit),
        if (_busy) c.rect(left: 23.5, top: 503, width: 345, height: 50, child: const CompanyBusyButton()),
      ],
    );
  }
}
