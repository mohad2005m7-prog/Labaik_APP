import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/app_launcher.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_lines.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../../supervisor/presentation/widgets/supervisor_colors.dart';
import '../../../supervisor/presentation/widgets/supervisor_widgets.dart';
import '../../domain/entities/company_group.dart';
import '../../domain/entities/company_member.dart';
import '../../domain/repositories/company_repository.dart';
import '../controllers/company_controller.dart';
import '../l10n/company_forms_text.dart';
import '../l10n/company_groups_text.dart';
import '../l10n/company_profile_text.dart';
import '../widgets/company_box.dart';
import '../widgets/company_colors.dart';

// -------------------------------------------------------------
// "بيانات المشرف" — التحكم بمشرف من الشركة (مش بـ Figma — بستايل شاشات الشركة):
//   الصورة والاسم وحالة الحساب ← البريد (نسخ) والهاتف (اتصال) ← مجموعاته (الضغط بيفتح تفاصيل المجموعة)
//   ← التحكم: كلمة مرور مؤقتة جديدة / إيقاف أو تفعيل الحساب / حذف من الشركة (بتأكيد)
// العمليات على السيرفر (20 أكتوبر) — ولو السيرفر أقدم بتطلع رسالة واضحة بدل ما تفشل بصمت
// بترجع true للي فتحها لو تغيّر إشي (حذف أو إيقاف)
// -------------------------------------------------------------
class CompanySupervisorScreen extends StatefulWidget {
  final CompanySupervisor supervisor;
  final CompanyRepository repository;

  const CompanySupervisorScreen({super.key, required this.supervisor, required this.repository});

  @override
  State<CompanySupervisorScreen> createState() => _CompanySupervisorScreenState();
}

class _CompanySupervisorScreenState extends State<CompanySupervisorScreen> {
  late CompanySupervisor _s = widget.supervisor;
  List<CompanyGroup>? _groups;
  String? _busy;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    widget.repository.groups().then((all) {
      if (mounted) setState(() => _groups = [for (final g in all) if (g.supervisorName == _s.name) g]);
    }, onError: (_) {
      if (mounted) setState(() => _groups = const []);
    });
  }

  /// "المجموعات" → تفاصيل مجموعته (ولو أكتر من وحدة بنختار من قائمة)
  Future<void> _openGroups() async {
    final groups = _groups ?? const <CompanyGroup>[];
    if (groups.isEmpty) return;
    final group = groups.length == 1 ? groups.first : await _pickGroup(groups);
    if (group == null || !mounted) return;
    if (await CompanyController.openGroupFrom(context, widget.repository, group) && mounted) {
      _changed = true;
      _loadGroups();
    }
  }

  Future<CompanyGroup?> _pickGroup(List<CompanyGroup> groups) => showModalBottomSheet<CompanyGroup>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(CompanyFormsText.chooseGroup(), style: const TextStyle(fontFamily: 'NotoSansArabic', fontSize: 16, fontWeight: FontWeight.bold, color: CompanyColors.green)),
              ),
              for (final g in groups)
                ListTile(
                  leading: Image.asset('$companyAssets/ic_groups.png', width: 24, height: 24, color: CompanyColors.green),
                  title: Text(g.name, style: const TextStyle(fontFamily: 'NotoSansArabic', fontSize: 15, color: CompanyColors.green)),
                  subtitle: Text(CompanyGroupsText.pilgrimCount(g.memberCount, hajj: g.hajj), style: const TextStyle(fontFamily: 'NotoSansArabic', fontSize: 12)),
                  trailing: const Icon(Icons.chevron_left_rounded, color: CompanyColors.green),
                  onTap: () => Navigator.pop(ctx, g),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );

  void _fail(Object e, {String? conflict}) {
    if (!mounted) return;
    if (e is ApiException && (e.statusCode == 404 || e.statusCode == 405 || e.statusCode == 501)) return CompanyController.showMessage(context, CompanyProfileText.notOnServer());
    if (e is ApiException && e.statusCode == 409 && conflict != null) return CompanyController.showMessage(context, conflict);
    CompanyController.showError(context, e);
  }

  Future<bool> _confirm(String message, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(message, style: const TextStyle(fontFamily: 'NotoSansArabic', fontSize: 15)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(CompanyProfileText.cancel())),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(action, style: const TextStyle(color: SupColors.red, fontWeight: FontWeight.bold))),
          ],
        ),
      ) ??
      false;

  Future<void> _run(String key, Future<void> Function() action) async {
    if (_busy != null) return;
    setState(() => _busy = key);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _tempPassword() => _run('password', () async {
        try {
          final p = await widget.repository.supervisorTempPassword(_s.userId);
          if (!mounted) return;
          if (p.isNotEmpty) Clipboard.setData(ClipboardData(text: p));
          CompanyController.showMessage(context, p.isEmpty ? CompanyProfileText.tempPasswordDone() : CompanyProfileText.tempPasswordValue(p));
        } catch (e) {
          _fail(e);
        }
      });

  Future<void> _toggleSuspend() async {
    final suspend = !_s.suspended;
    if (suspend && !await _confirm(CompanyProfileText.suspendConfirm(), CompanyProfileText.suspend())) return;
    await _run('suspend', () async {
      try {
        await widget.repository.setSupervisorSuspended(_s.userId, suspended: suspend);
        if (!mounted) return;
        setState(() {
          _s = _s.copyWith(suspended: suspend);
          _changed = true;
        });
        CompanyController.showMessage(context, suspend ? CompanyProfileText.suspended() : CompanyProfileText.resumed());
      } catch (e) {
        _fail(e);
      }
    });
  }

  Future<void> _remove() async {
    if ((_groups ?? const []).isNotEmpty) return CompanyController.showMessage(context, CompanyProfileText.removeHasGroups());
    if (!await _confirm(CompanyProfileText.removeConfirm(), CompanyProfileText.remove())) return;
    await _run('remove', () async {
      try {
        await widget.repository.removeSupervisor(_s.userId);
        if (!mounted) return;
        CompanyController.showMessage(context, CompanyProfileText.removed());
        Navigator.of(context).pop(true);
      } catch (e) {
        _fail(e, conflict: CompanyProfileText.removeHasGroups());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final green = CompanyColors.green;
    final groups = _groups;
    final groupsText = groups == null ? '…' : (groups.isEmpty ? CompanyProfileText.noGroups() : groups.map((g) => g.name).join('، '));
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: FigmaPage(
        title: CompanyProfileText.supervisorTitle(),
        titleRight: 349,
        chevronLeft: 367,
        body: (c) => [
          c.box(left: 17, top: 108, width: 360, height: 1, color: const Color(0xFFE5E5EA)),
          c.rect(left: 157, top: 125, width: 80, height: 80, child: SupPhoto(photo: null, size: c.s.x(80), name: _s.name)),
          c.text(_s.name, left: 16, top: 215, width: 361, height: 24, align: TextAlign.center, dy: 0, style: c.style(18, FigmaWeight.sfBold, green, lineHeight: null, letterSpacing: 0)),
          companyBox(c, left: 141, top: 247, width: 111, height: 21, radius: 10.5, color: _s.suspended ? SupColors.red : green),
          FigmaLines.build(c, _s.suspended ? CompanyProfileText.suspendedBadge() : CompanyProfileText.activeBadge(), left: 141, top: 247, width: 111, align: TextAlign.center, style: c.style(11, FigmaWeight.sfRegular, Colors.white, lineHeight: 21), lineHeight: 21, wrap: false),

          // المعلومات
          companyBox(c, left: 16, top: 288, width: 361, height: 186, radius: 12, color: CompanyColors.card, shadow: CompanyColors.shadow),
          ..._info(c, CompanyProfileText.emailLabel(), _s.email, top: 300, ltr: true, onTap: () {
            Clipboard.setData(ClipboardData(text: _s.email));
            CompanyController.showMessage(context, _s.email);
          }),
          ..._info(c, CompanyProfileText.phoneLabel(), _s.phone ?? '—', top: 360, ltr: true, onTap: _s.phone == null ? null : () => AppLauncher.call(_s.phone!)),
          ..._info(c, CompanyProfileText.groupsLabel(), groupsText, top: 420, onTap: (groups ?? const []).isEmpty ? null : _openGroups),

          // التحكم
          FigmaLines.build(c, CompanyProfileText.actions(), left: 177, top: 494, width: 200, style: c.style(16, FigmaWeight.semiBold, green), wrap: false),
          ..._action(c, CompanyProfileText.tempPassword(), Icons.key_rounded, top: 528, busy: _busy == 'password', onTap: _tempPassword),
          ..._action(c, _s.suspended ? CompanyProfileText.resume() : CompanyProfileText.suspend(), _s.suspended ? Icons.play_circle_outline_rounded : Icons.pause_circle_outline_rounded, top: 588, busy: _busy == 'suspend', onTap: _toggleSuspend),
          ..._action(c, CompanyProfileText.remove(), Icons.person_remove_outlined, top: 648, busy: _busy == 'remove', danger: true, onTap: _remove),
        ],
      ),
    );
  }

  List<Widget> _info(FigmaCanvas c, String label, String value, {required double top, bool ltr = false, VoidCallback? onTap}) => [
        FigmaLines.build(c, label, left: 40, top: top, width: 321, style: c.style(12, FigmaWeight.sfRegular, CompanyColors.secondaryLabel), wrap: false),
        c.rect(
          left: 40,
          top: top + 22,
          width: 321,
          height: 24,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: ltr ? TextDirection.ltr : null, style: c.style(15, FigmaWeight.semiBold, CompanyColors.green, lineHeight: null, letterSpacing: 0)),
          ),
        ),
        if (onTap != null) c.tapArea(left: 16, top: top - 6, width: 361, height: 56, onTap: onTap),
      ];

  // صف تحكم 361×48 أبيض بظل — الأيقونة بالبداية والنص بعدها (الحذف أحمر)
  List<Widget> _action(FigmaCanvas c, String label, IconData icon, {required double top, required bool busy, required VoidCallback onTap, bool danger = false}) {
    final color = danger ? SupColors.red : CompanyColors.green;
    return [
      companyBox(c, left: 16, top: top, width: 361, height: 48, radius: 12, color: Colors.white, shadow: CompanyColors.shadow, borderColor: danger ? SupColors.red.withValues(alpha: 0.4) : null),
      c.rect(left: 337, top: top + 12, width: 24, height: 24, child: busy ? Padding(padding: EdgeInsets.all(c.s.x(3)), child: CircularProgressIndicator(strokeWidth: 2, color: color)) : Icon(icon, size: c.s.x(22), color: color)),
      FigmaLines.build(c, label, left: 40, top: top + 13, width: 289, style: c.style(15, FigmaWeight.semiBold, color), wrap: false),
      c.tapArea(left: 16, top: top, width: 361, height: 48, onTap: onTap),
    ];
  }
}
