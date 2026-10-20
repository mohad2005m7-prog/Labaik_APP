import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/figma_page.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_profile_text.dart';
import '../widgets/company_form_fields.dart';

// -------------------------------------------------------------
// "المساعدة والدعم" — مطابقة لـ Figma 698:4428
// إلى (بريد دعم لبيك) / الموضوع / نص الرسالة (جاهز وفيه اسم الشركة) + "إرسال" → تطبيق البريد بالجهاز
// بريد الدعم: supportEmail من GET /company/me (إعدادات السيرفر Support:Email)، وإلا وقت البناء (--dart-define=LABAIK_SUPPORT_EMAIL=...)
// ولو الاتنين فاضيين بيفتح البريد بلا مستلم
// -------------------------------------------------------------
class CompanyHelpScreen extends StatefulWidget {
  final String companyName;
  final String? supportEmail;

  const CompanyHelpScreen({super.key, required this.companyName, this.supportEmail});

  static const buildSupportEmail = String.fromEnvironment('LABAIK_SUPPORT_EMAIL');

  @override
  State<CompanyHelpScreen> createState() => _CompanyHelpScreenState();
}

class _CompanyHelpScreenState extends State<CompanyHelpScreen> {
  late final _subject = TextEditingController(text: CompanyProfileText.subjectDefault());
  late final _message = TextEditingController(text: CompanyProfileText.messageDefault(widget.companyName));
  late final _to = TextEditingController(text: (widget.supportEmail?.trim().isNotEmpty ?? false) ? widget.supportEmail!.trim() : CompanyHelpScreen.buildSupportEmail);

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    _to.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    final uri = Uri(
      scheme: 'mailto',
      path: _to.text.trim(),
      query: 'subject=${Uri.encodeComponent(_subject.text)}&body=${Uri.encodeComponent(_message.text)}',
    );
    var opened = false;
    try {
      opened = await launchUrl(uri);
    } catch (_) {}
    if (!opened && mounted) CompanyController.showMessage(context, '${CompanyProfileText.noMailApp()} ${_to.text}');
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: CompanyProfileText.help(),
      titleRight: 349,
      chevronLeft: 367,
      body: (c) => [
        c.box(left: 17, top: 108, width: 360, height: 1, color: const Color(0xFFE5E5EA)),
        companyFieldLabel(c, CompanyProfileText.to(), top: 117, right: 376, width: 357),
        c.rect(left: 19, top: 147, width: 357, height: 53, child: CompanyTextBox(s: c.s, controller: _to, hint: CompanyProfileText.supportEmailLabel(), keyboard: TextInputType.emailAddress)),
        companyFieldLabel(c, CompanyProfileText.subject(), top: 208, right: 376, width: 357),
        c.rect(left: 19, top: 238, width: 357, height: 53, child: CompanyTextBox(s: c.s, controller: _subject, hint: CompanyProfileText.subjectDefault())),
        companyFieldLabel(c, CompanyProfileText.message(), top: 307, right: 377, width: 361),
        c.rect(left: 16, top: 337, width: 361, height: 393, child: CompanyTextBox(s: c.s, controller: _message, hint: '', multiline: true)),
        c.button(CompanyProfileText.send(), left: 16, top: 753, figmaSpacing: true, onTap: _send),
      ],
    );
  }
}
