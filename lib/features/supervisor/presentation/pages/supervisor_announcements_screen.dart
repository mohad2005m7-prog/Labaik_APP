import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/tx.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/entities/supervisor_group.dart';
import '../controllers/supervisor_controller.dart';
import '../cubits/announcements_cubit.dart';
import '../cubits/supervisor_content_cubits.dart';
import '../l10n/announcements_text.dart';
import '../widgets/photo_picker.dart';
import '../widgets/sup_list_status.dart';
import '../widgets/supervisor_colors.dart';
import '../widgets/supervisor_page.dart';
import '../widgets/supervisor_widgets.dart';

// -------------------------------------------------------------
// الإعلانات — مطابقة لـ Figma "الإعلانات":
//   "إنشاء إعلان جديد" (234:3302، إطار 896 فبيتمرر 44) | "إعلانات سابقة" (234:3360)
// التبويبين صفحات بتنسحب. المسودة بتنحفظ أول بأول (AnnouncementFormCubit)
// الإرسال ما بيمشي بدون عنوان ونوع ونص، والإعلان الجديد بيطلع أول "إعلانات سابقة"
// -------------------------------------------------------------
class SupervisorAnnouncementsScreen extends StatefulWidget {
  const SupervisorAnnouncementsScreen({super.key});

  @override
  State<SupervisorAnnouncementsScreen> createState() => _SupervisorAnnouncementsScreenState();
}

class _SupervisorAnnouncementsScreenState extends State<SupervisorAnnouncementsScreen> {
  static const _pageTop = 140.0;

  // 0 = إنشاء إعلان جديد (يمين بالعربي)، 1 = إعلانات سابقة (بتفتح عليها)
  final _pages = PageController(initialPage: 1);

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnnouncementFormCubit, AnnouncementFormState>(
      listenWhen: (a, b) => a.feedback != b.feedback,
      listener: (context, state) {
        if (state.message != null) SupervisorController.showMessage(context, state.message!);
      },
      child: BlocListener<AnnouncementFormCubit, AnnouncementFormState>(
        listenWhen: (a, b) => a.sent != b.sent,
        listener: (context, _) {
          FocusScope.of(context).unfocus();
          _pages.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
        },
        child: SupervisorPage(
          inShell: true,
          builder: (c) => [
            // Poppins SemiBold 24 — #717171 — بالنص
            c.text(AnnouncementsText.title(), left: 96, top: 59, width: 201, height: 29, align: TextAlign.center, style: supText(c, 24, FigmaWeight.semiBold, SupColors.grey)),
            c.rect(
              left: 25,
              top: 104,
              width: 343,
              height: 32,
              child: SupSegmented(
                s: c.s,
                controller: _pages,
                labels: [AnnouncementsText.createTab(), AnnouncementsText.previousTab()],
                fill: SupColors.segmentFillDark,
                labelStyle: supText(c, 13, FigmaWeight.semiBold, Colors.black),
              ),
            ),
            c.rect(
              left: 0,
              top: _pageTop,
              width: 393,
              height: 818 - _pageTop,
              child: PageView(
                controller: _pages,
                children: [
                  SupKeepAlive(child: _CreateForm(c: c.at(_pageTop))),
                  SupKeepAlive(child: _PreviousList(c: c.at(150))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// إعلانات سابقة — كروت 361×158 كل 174
// ---------------------------------------------------------
class _PreviousList extends StatelessWidget {
  final FigmaCanvas c;

  const _PreviousList({required this.c});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnnouncementsCubit, AnnouncementsState>(
      builder: (context, state) => state.items.isEmpty
          ? Align(
              alignment: Alignment.topCenter,
              child: SupListStatus(loaded: state.loaded, failed: state.failed, isEmpty: true, empty: SupListStatusText.noAnnouncements, onRetry: context.read<AnnouncementsCubit>().load),
            )
          : ListView.builder(
        // أول كرت عند y160 (الصفحة بتبدأ 140) — وآخر واحد فوق شريط التنقل
        padding: EdgeInsets.only(top: c.s.y(10), bottom: c.s.y(49)),
        physics: supScrollPhysics,
        itemCount: state.items.length,
        itemExtent: c.s.y(174),
        itemBuilder: (context, i) => Stack(clipBehavior: Clip.none, children: _card(context, state.items[i])),
      ),
    );
  }

  List<Widget> _card(BuildContext context, Announcement a) {
    final t = c.originTop + 10;
    final (icon, iconRect) = switch (a.icon) {
      AnnouncementIcon.group => ('ic_users', const Rect.fromLTWH(328.5, 31, 20.5, 18.5)),
      AnnouncementIcon.calendar => ('ic_calendar_clock_b', const Rect.fromLTWH(327, 28, 24, 24)),
      AnnouncementIcon.book => ('ic_book', const Rect.fromLTWH(326, 31, 26, 19.5)),
    };
    return [
      c.box(left: 16, top: t, width: 361, height: 158, color: SupColors.cardFill, radius: 10, hasShadow: true),
      // مربع الأيقونة 45 — #4C7A75 10% فوق الكرت — ظل
      c.box(left: 316, top: t + 18, width: 45, height: 45, color: SupColors.iconSquare, radius: 10, hasShadow: true),
      c.image('$supAssets/$icon.png', left: iconRect.left, top: t + iconRect.top, width: iconRect.width, height: iconRect.height),
      // العنوان (SemiBold 13) والجهة · الوقت (SF Compact Regular 11) — طرفهم x308
      c.text(a.title, left: 125, top: t + 18.5, width: 183, height: 16, style: supText(c, 13, FigmaWeight.semiBold, SupColors.green)),
      c.text('${a.target} · ${a.whenLabel}', left: 125, top: t + 45, width: 182.5, height: 13, style: supText(c, 11.3, FigmaWeight.sfRegular, SupColors.green)),
      // الشارة: مهم / تم الإرسال
      c.box(left: 32, top: t + 17, width: 83, height: 21, color: SupColors.green, radius: 10.5),
      c.text((a.isImportant ? AnnouncementsText.badgeImportant : AnnouncementsText.badgeSent)(), left: 32, top: t + 19.5, width: 83, height: 16, align: TextAlign.center, dy: 0, style: supText(c, 11, FigmaWeight.semiBold, Colors.white)),
      // الملخص — SF Compact Regular 13 — طرفه x360.5 (سطر واحد)
      c.text(a.summary, left: 24, top: t + 82, width: 336.5, height: 16, style: supText(c, 13, FigmaWeight.sfRegular, SupColors.green)),
      c.box(left: 24, top: t + 118, width: 345, height: 1, color: SupColors.green),
      c.text(AnnouncementsText.viewDetails(), left: 50, top: t + 130, width: 76.5, height: 14, style: supText(c, 11.5, FigmaWeight.sfRegular, SupColors.green)),
      c.image('$supAssets/ic_chevron_details.png', left: 32, top: t + 131, width: 8, height: 14, flipInLtr: true),
      c.tapArea(left: 16, top: t, width: 361, height: 158, onTap: () => SupervisorController.openAnnouncement(context, a)),
    ];
  }
}

// ---------------------------------------------------------
// إنشاء إعلان جديد — المحتوى من y140 لـ y862 (فبيتمرر 44 فوق شريط التنقل زي Figma)
// ---------------------------------------------------------
class _CreateForm extends StatefulWidget {
  final FigmaCanvas c;

  const _CreateForm({required this.c});

  @override
  State<_CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends State<_CreateForm> {
  late final _form = context.read<AnnouncementFormCubit>();
  late final _title = TextEditingController(text: _form.state.draft.title);
  late final _body = TextEditingController(text: _form.state.draft.body);

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  // المسودة المسترجعة أو المسح بعد الإرسال بيوصلوا للحقول (الكتابة نفسها ما بتتعارض لأنه النص نفسه)
  void _syncFields(AnnouncementFormState state) {
    if (_title.text != state.draft.title) _title.text = state.draft.title;
    if (_body.text != state.draft.body) _body.text = state.draft.body;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final keyboard = math.max(0.0, MediaQuery.viewInsetsOf(context).bottom - MediaQuery.paddingOf(context).bottom);
    return BlocConsumer<AnnouncementFormCubit, AnnouncementFormState>(
      listenWhen: (a, b) => a.draft != b.draft,
      listener: (context, state) => _syncFields(state),
      // الكتابة بالحقول ما بتعيد بناء الصفحة (الحقول عندها نصها) — بس الاختيارات اللي بتبيّن على الشاشة
      buildWhen: (a, b) => a.draft.target != b.draft.target || a.draft.type != b.draft.type || a.draft.attachment != b.draft.attachment,
      builder: (context, state) => Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: SingleChildScrollView(
          physics: supScrollPhysics,
          child: SizedBox(
            height: c.s.y(862 - c.originTop),
            child: Stack(clipBehavior: Clip.none, children: _fields(context, state.draft)),
          ),
        ),
      ),
    );
  }

  List<Widget> _fields(BuildContext context, AnnouncementDraft draft) {
    final c = widget.c;
    final s = c.s;
    final label = supText(c, 13, FigmaWeight.sfBold, SupColors.green);
    final input = c.style(13, FigmaWeight.sfRegular, SupColors.green);
    final hint = c.style(13, FigmaWeight.sfRegular, SupColors.grey);
    final groups = context.read<SupervisorGroupsCubit>();
    final defaultTarget = groups.mainGroup?.name ?? '';

    Widget field(TextEditingController controller, String hintText, ValueChanged<String> onChanged, {bool multiline = false}) => TextField(
          controller: controller,
          onChanged: onChanged,
          cursorColor: SupColors.green,
          maxLines: multiline ? null : 1,
          expands: multiline,
          textAlignVertical: multiline ? TextAlignVertical.top : TextAlignVertical.center,
          style: input,
          decoration: InputDecoration.collapsed(hintText: hintText, hintStyle: hint).copyWith(hintMaxLines: 4),
        );

    final attachment = draft.attachment;
    return [
      c.text(AnnouncementsText.fieldTitle(), left: 200, top: 162, width: 176.5, height: 16, style: label),
      c.box(left: 16, top: 190, width: 361, height: 53, radius: 10, borderColor: SupColors.green),
      c.rect(left: 30, top: 206.5, width: 329, height: 24, child: field(_title, AnnouncementsText.fieldTitleHint(), _form.setTitle)),

      c.text(AnnouncementsText.fieldSendTo(), left: 200, top: 261.5, width: 176.5, height: 16, style: label),
      c.box(left: 16, top: 289, width: 361, height: 53, radius: 10, borderColor: SupColors.green),
      c.text(draft.target ?? defaultTarget, left: 60, top: 307, width: 299, height: 16, style: supText(c, 13, FigmaWeight.sfRegular, SupColors.grey)),
      c.image('$supAssets/ic_chevron_down.png', left: 37, top: 312, width: 14, height: 8),
      c.tapArea(left: 16, top: 289, width: 361, height: 53, onTap: () => _pickTarget(context, groups.state.items, draft.target ?? defaultTarget)),

      c.text(AnnouncementsText.fieldType(), left: 200, top: 360, width: 176.5, height: 16, style: label),
      ..._typeButton(c, draft, left: 201, type: AnnouncementType.normal, label: AnnouncementsText.typeNormal),
      ..._typeButton(c, draft, left: 12, type: AnnouncementType.important, label: AnnouncementsText.typeImportant),

      c.text(AnnouncementsText.fieldBody(), left: 200, top: 459, width: 176.5, height: 16, style: label),
      c.box(left: 16, top: 487, width: 361, height: 101, radius: 10, borderColor: SupColors.green),
      c.rect(left: 34, top: 501, width: 325.5, height: 82, child: field(_body, AnnouncementsText.fieldBodyHint(), _form.setBody, multiline: true)),

      c.text(AnnouncementsText.fieldAttachment(), left: 200, top: 606, width: 176.5, height: 19, style: label),
      c.box(left: 16, top: 635, width: 361, height: 86, radius: 10, borderColor: SupColors.green),
      c.tapArea(left: 16, top: 635, width: 361, height: 86, onTap: () => _pickAttachment(context, hasAttachment: attachment != null)),
      if (attachment == null) ...[
        c.image('$supAssets/ic_paperclip.png', left: 188.5, top: 651, width: 18, height: 18),
        c.text(AnnouncementsText.addAttachment(), left: 16, top: 684, width: 361, height: 16, align: TextAlign.center, style: supText(c, 13, FigmaWeight.sfRegular, SupColors.grey)),
      ] else ...[
        // الصورة المرفقة (الضغط عليها بيكبّرها) + زر حذفها
        c.rect(
          left: 166.5,
          top: 646,
          width: 64,
          height: 64,
          child: GestureDetector(
            onTap: () => SupervisorController.viewPhoto(context, photo: attachment, heroTag: 'attachment-draft', avatar: false),
            child: Hero(
              tag: 'attachment-draft',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(s.x(10)),
                child: Image(image: supImageProvider(attachment, cacheWidth: (s.x(64) * MediaQuery.devicePixelRatioOf(context)).round()), fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        c.rect(
          left: 222,
          top: 640,
          width: 20,
          height: 20,
          child: GestureDetector(
            onTap: _form.clearAttachment,
            child: const DecoratedBox(
              decoration: BoxDecoration(color: SupColors.green, shape: BoxShape.circle),
              child: Icon(Icons.close_rounded, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],

      c.rect(
        left: 16,
        top: 753,
        width: 361,
        height: 50,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
            _form.submit(defaultTarget: defaultTarget);
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(color: SupColors.green, borderRadius: BorderRadius.circular(s.x(14))),
            child: Text(AnnouncementsText.send(), maxLines: 1, style: c.style(19.5, FigmaWeight.semiBold, Colors.white)),
          ),
        ),
      ),
    ];
  }

  // زر نوع الإعلان 180.5×53 — حد #1F3B2E — SF Compact Bold 16 بالنص. المختار أخضر بنص أبيض.
  List<Widget> _typeButton(FigmaCanvas c, AnnouncementDraft draft, {required double left, required AnnouncementType type, required Tx label}) {
    final selected = draft.type == type;
    return [
      c.box(left: left, top: 388, width: 180.5, height: 53, radius: 10, color: selected ? SupColors.green : null, borderColor: SupColors.green),
      c.text(label(), left: left, top: 405, width: 180.5, height: 19, align: TextAlign.center, style: supText(c, 16, FigmaWeight.sfBold, selected ? Colors.white : SupColors.green)),
      c.tapArea(left: left, top: 388, width: 180.5, height: 53, onTap: () => _form.setType(type)),
    ];
  }

  Future<void> _pickTarget(BuildContext context, List<SupervisorGroup> groups, String current) async {
    final options = [...groups.map((g) => g.name), AnnouncementsText.allPilgrims()];
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final o in options)
              ListTile(
                title: Text(o, style: const TextStyle(fontFamily: 'NotoSansArabic', fontSize: 16, color: SupColors.green)),
                trailing: o == current ? const Icon(Icons.check, color: SupColors.green) : null,
                onTap: () => Navigator.pop(context, o),
              ),
          ],
        ),
      ),
    );
    if (picked != null) _form.setTarget(picked);
  }

  Future<void> _pickAttachment(BuildContext context, {required bool hasAttachment}) async {
    final path = await SupPhotoPicker.pick(context, onRemove: hasAttachment ? _form.clearAttachment : null);
    if (path != null) await _form.setAttachment(path);
  }
}
