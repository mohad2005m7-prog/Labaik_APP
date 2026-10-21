import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/api_error_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/utils/latin_digits.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../domain/entities/company_group.dart';
import '../../domain/entities/company_member.dart';
import '../../domain/entities/company_trip.dart';
import '../../domain/repositories/company_repository.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_groups_text.dart';
import '../widgets/company_colors.dart';
import '../widgets/company_form_fields.dart';

// -------------------------------------------------------------
// "إنشاء مجموعة جديدة" — Figma 630:3979: اسم المجموعة / الرحلة / المشرف + زر "إنشاء المجموعة"
// الإنشاء: POST /company/trips/{tripId}/groups وبعده (لو اختار مشرف) PUT .../supervisor
// النجاح: بوب-أب "تم إنشاء المجموعة" (656:4748) فيه رمز الانضمام — بترجع المجموعة للي فتحها
// (Figma فيه "اضافة المعتمرون: أدخل العدد" — السيرفر ما فيه سعة للمجموعة، فالحقل مش موجود — docs)
// -------------------------------------------------------------
class CompanyCreateGroupScreen extends StatefulWidget {
  final CompanyRepository repository;
  final List<CompanyTrip> trips;
  final List<CompanySupervisor> supervisors;

  const CompanyCreateGroupScreen({super.key, required this.repository, required this.trips, required this.supervisors});

  @override
  State<CompanyCreateGroupScreen> createState() => _CompanyCreateGroupScreenState();
}

class _CompanyCreateGroupScreenState extends State<CompanyCreateGroupScreen> {
  final _name = TextEditingController();
  final _capacity = TextEditingController();
  final _notes = TextEditingController();
  CompanyTrip? _trip;
  CompanySupervisor? _supervisor;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.trips.length == 1) _trip = widget.trips.single;
  }

  @override
  void dispose() {
    _name.dispose();
    _capacity.dispose();
    _notes.dispose();
    super.dispose();
  }

  String _tripLabel(CompanyTrip t) => t.dates.isEmpty ? t.title : '${t.title} — ${t.dates}';

  Future<void> _pickTrip() async {
    final i = await companyPickOne(context, [for (final t in widget.trips) _tripLabel(t)], selected: _trip == null ? null : widget.trips.indexOf(_trip!));
    if (i != null) setState(() => _trip = widget.trips[i]);
  }

  Future<void> _pickSupervisor() async {
    final options = [CompanyGroupsText.noSupervisorOption(), for (final s in widget.supervisors) s.name];
    final current = _supervisor == null ? 0 : widget.supervisors.indexOf(_supervisor!) + 1;
    final i = await companyPickOne(context, options, selected: current);
    if (i != null) setState(() => _supervisor = i == 0 ? null : widget.supervisors[i - 1]);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final trip = _trip;
    if (_busy) return;
    if (trip == null || _name.text.trim().isEmpty) return CompanyController.showMessage(context, CompanyGroupsText.needTrip());
    final capacityText = latinDigits(_capacity.text.trim());
    final capacity = capacityText.isEmpty ? null : int.tryParse(capacityText);
    if (capacityText.isNotEmpty && (capacity == null || capacity <= 0)) return CompanyController.showMessage(context, CompanyGroupsText.invalidCapacity());
    setState(() => _busy = true);
    try {
      var group = await widget.repository.createGroup(tripId: trip.id, name: _name.text, notes: _notes.text, capacity: capacity);
      final supervisor = _supervisor;
      if (supervisor != null) {
        try {
          group = await widget.repository.assignSupervisor(group.id, supervisor.email);
        } catch (_) {
          // المجموعة انعملت — المشرف بيتعيّن بعدين من تفاصيل المجموعة
        }
      }
      if (!mounted) return;
      setState(() => _busy = false);
      await showCompanyGroupCreated(context, group);
      if (mounted) Navigator.of(context).pop(group);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      CompanyController.showMessage(context, ApiErrorText.of(e)());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: CompanyGroupsText.createTitle(),
      titleRight: 349,
      chevronLeft: 367,
      body: (c) => [
        companyFieldLabel(c, CompanyGroupsText.groupName(), top: 117, right: 377),
        c.rect(left: 22, top: 147, width: 361, height: 53, child: CompanyTextBox(s: c.s, controller: _name, hint: CompanyGroupsText.groupNameHint())),
        companyFieldLabel(c, CompanyGroupsText.trip(), top: 216, right: 377),
        c.rect(left: 22, top: 246, width: 361, height: 53, child: CompanyPickerBox(s: c.s, value: _trip == null ? null : _tripLabel(_trip!), hint: CompanyGroupsText.tripHint(), onTap: _pickTrip)),
        companyFieldLabel(c, CompanyGroupsText.supervisor(), top: 315, right: 377),
        c.rect(left: 22, top: 345, width: 361, height: 53, child: CompanyPickerBox(s: c.s, value: _supervisor?.name, hint: CompanyGroupsText.supervisorHint(), onTap: _pickSupervisor)),
        // السعة والملاحظات (اختياريين)
        companyFieldLabel(c, CompanyGroupsText.capacity(hajj: _trip?.isHajj ?? false), top: 414, right: 377),
        c.rect(left: 22, top: 444, width: 361, height: 53, child: CompanyTextBox(s: c.s, controller: _capacity, hint: CompanyGroupsText.capacityHint(), keyboard: TextInputType.number)),
        companyFieldLabel(c, CompanyGroupsText.notes(), top: 513, right: 377),
        c.rect(left: 22, top: 543, width: 361, height: 80, child: CompanyTextBox(s: c.s, controller: _notes, hint: CompanyGroupsText.notesHint(), multiline: true)),
        c.button(CompanyGroupsText.createButton(), left: 16, top: 650, figmaSpacing: true, onTap: _submit),
        if (_busy) c.rect(left: 16, top: 650, width: 361, height: 50, child: const CompanyBusyButton()),
      ],
    );
  }
}

/// بوب-أب "تم إنشاء المجموعة" (656:4748 — 391×353): أيقونة النجاح، العنوان، رمز الانضمام (اضغط للنسخ)، "العودة للمجموعات"
Future<void> showCompanyGroupCreated(BuildContext context, CompanyGroup group) => showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (a, animation, b, child) => FadeTransition(opacity: animation, child: child),
      pageBuilder: (dialogContext, a, b) {
        final s = DesignScale.of(dialogContext);
        final c = FigmaCanvas(s, originTop: 0);
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: SizedBox(
              width: MediaQuery.sizeOf(dialogContext).width,
              height: s.y(353),
              child: Stack(
                children: [
                  c.box(left: 1, top: 0, width: 391, height: 353, color: CompanyColors.card, radius: 16),
                  c.image('assets/images/trip/ic_success.png', left: 150.5, top: 51, width: 92, height: 92),
                  c.text(CompanyGroupsText.createdTitle(), left: 16, top: 165, width: 361, height: 36, align: TextAlign.center, dy: 0, style: c.style(20, FigmaWeight.sfBold, CompanyColors.green, lineHeight: null, letterSpacing: 0)),
                  if (group.joinCode.isNotEmpty) ...[
                    c.text(CompanyGroupsText.createdCode(group.joinCode), left: 16, top: 206, width: 361, height: 26, align: TextAlign.center, dy: 0, style: c.style(16, FigmaWeight.semiBold, const Color(0xFF4C7A75), lineHeight: null, letterSpacing: 0)),
                    c.tapArea(left: 96, top: 204, width: 201, height: 30, onTap: () {
                      Clipboard.setData(ClipboardData(text: group.joinCode));
                      CompanyController.showMessage(context, CompanyGroupsText.codeCopied());
                    }),
                  ],
                  c.button(CompanyGroupsText.backToGroups(), left: 16, top: 249, figmaSpacing: true, onTap: () => Navigator.of(dialogContext).pop()),
                ],
              ),
            ),
          ),
        );
      },
    );
