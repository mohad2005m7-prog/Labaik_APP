import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../domain/entities/company_profile.dart';
import '../../domain/repositories/company_repository.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_profile_text.dart';
import '../widgets/company_box.dart';
import '../widgets/company_colors.dart';
import '../widgets/company_form_fields.dart';

// -------------------------------------------------------------
// "تعديل بيانات الشركة" — مطابقة لـ Figma 633:3772
// اسم الشركة / شعار الشركة (دائرة 80 وقلم) / رقم الترخيص / الدولة (اختيار) / المدينة + "حفظ التعديلات"
// الحفظ: PUT /company/me (استبدال كامل — معلومات التواصل بتنبعت زي ما هي) وبترجع المحفوظ
// الشعار: السيرفر لسا ما فيه رفع ملفات (POST /files) — القلم بيوضح هالشي
// -------------------------------------------------------------
class CompanyDataScreen extends StatefulWidget {
  final CompanyRepository repository;
  final CompanyProfile profile;

  const CompanyDataScreen({super.key, required this.repository, required this.profile});

  static const countries = ['فلسطين', 'الأردن', 'السعودية', 'مصر', 'الإمارات', 'قطر', 'الكويت', 'البحرين', 'عُمان', 'لبنان', 'سوريا', 'العراق', 'اليمن', 'تركيا', 'المغرب', 'الجزائر', 'تونس', 'ليبيا', 'السودان'];

  @override
  State<CompanyDataScreen> createState() => _CompanyDataScreenState();
}

class _CompanyDataScreenState extends State<CompanyDataScreen> {
  late final _name = TextEditingController(text: widget.profile.name);
  late final _license = TextEditingController(text: widget.profile.licenseNumber);
  late final _city = TextEditingController(text: widget.profile.city ?? '');
  late String? _country = widget.profile.country;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _license.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _pickCountry() async {
    final options = [...CompanyDataScreen.countries, if (_country != null && !CompanyDataScreen.countries.contains(_country)) _country!];
    final i = await companyPickOne(context, options, selected: _country == null ? null : options.indexOf(_country!));
    if (i != null) setState(() => _country = options[i]);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_busy) return;
    if (_name.text.trim().isEmpty || _license.text.trim().isEmpty || widget.profile.contactName.trim().isEmpty) {
      return CompanyController.showMessage(context, CompanyProfileText.required());
    }
    setState(() => _busy = true);
    try {
      final saved = await widget.repository.updateProfile(widget.profile.copyWith(name: _name.text, licenseNumber: _license.text, country: _country ?? '', city: _city.text));
      if (!mounted) return;
      CompanyController.showMessage(context, CompanyProfileText.saved());
      Navigator.of(context).pop(saved);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      if (e is ApiException && e.statusCode == 409) return CompanyController.showMessage(context, CompanyProfileText.licenseTaken());
      CompanyController.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final logo = widget.profile.logoUrl;
    return FigmaPage(
      title: CompanyProfileText.editTitle(),
      titleRight: 349,
      chevronLeft: 367,
      body: (c) => [
        c.box(left: 17, top: 108, width: 360, height: 1, color: const Color(0xFFE5E5EA)),
        companyFieldLabel(c, CompanyProfileText.companyName(), top: 129, right: 378, width: 365),
        c.rect(left: 13, top: 159, width: 365, height: 53, child: CompanyTextBox(s: c.s, controller: _name, hint: CompanyProfileText.companyNameHint())),

        companyFieldLabel(c, CompanyProfileText.logo(), top: 228, right: 378, width: 365),
        companyBox(c, left: 298, top: 254, width: 80, height: 80, color: CompanyColors.cardInset, circle: true, borderColor: const Color(0xFFE5E5EA)),
        if (logo != null)
          c.rect(left: 299, top: 255, width: 78, height: 78, child: ClipOval(child: Image.network(logo, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink())))
        else
          c.rect(left: 298, top: 254, width: 80, height: 80, child: Icon(Icons.apartment_rounded, size: c.s.x(42), color: const Color(0xFF4C7A75))),
        companyBox(c, left: 292, top: 304, width: 30, height: 30, color: Colors.white, circle: true, shadow: CompanyColors.shadow),
        c.image('assets/images/supervisor/ic_pen.png', left: 296, top: 308, width: 22, height: 22, color: CompanyColors.green),
        c.tapArea(left: 288, top: 300, width: 38, height: 38, onTap: () => CompanyController.showMessage(context, CompanyProfileText.logoSoon())),

        companyFieldLabel(c, CompanyProfileText.licenseLabel(), top: 352, right: 378, width: 365),
        c.rect(left: 13, top: 382, width: 365, height: 53, child: CompanyTextBox(s: c.s, controller: _license, hint: CompanyProfileText.licenseHint())),

        companyFieldLabel(c, CompanyProfileText.countryLabel(), top: 453, right: 378, width: 365),
        c.rect(left: 13, top: 483, width: 365, height: 53, child: CompanyPickerBox(s: c.s, value: _country, hint: CompanyProfileText.countryHint(), onTap: _pickCountry)),

        companyFieldLabel(c, CompanyProfileText.cityLabel(), top: 554, right: 378, width: 365),
        c.rect(left: 13, top: 584, width: 365, height: 53, child: CompanyTextBox(s: c.s, controller: _city, hint: CompanyProfileText.cityHint())),

        c.button(CompanyProfileText.save(), left: 13, top: 675, width: 365, figmaSpacing: true, onTap: _save),
        if (_busy) c.rect(left: 13, top: 675, width: 365, height: 50, child: const CompanyBusyButton()),
      ],
    );
  }
}
