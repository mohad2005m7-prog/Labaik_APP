import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/api_error_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../field_mode/presentation/widgets/back_title_header.dart';
import '../../domain/entities/supervisor_group.dart';
import '../../domain/entities/trip_program.dart';
import '../../domain/repositories/supervisor_repository.dart';
import '../controllers/supervisor_controller.dart';
import '../cubits/supervisor_content_cubits.dart';
import '../l10n/trip_program_text.dart';
import '../widgets/supervisor_colors.dart';
import '../widgets/supervisor_format.dart';
import '../widgets/supervisor_page.dart';
import '../widgets/supervisor_widgets.dart';

// -------------------------------------------------------------
// برنامج الرحلة — مطابقة لـ Figma "برنامج الرحلة" (234:2778 / 2858 / 2994 / 3131 = اليوم 1..4)
// الأيام صفحات بتنسحب يمين/يسار مع التبويبات: تاريخ اليوم بدائرة تقويم، خط متدرج،
// وأنشطة اليوم بخط زمني (دوائر 45 كل 101 بينهم خط متدرج). النشاط → "قريباً" (لسا ما انصممت تفاصيله)
// -------------------------------------------------------------
class TripProgramScreen extends StatelessWidget {
  final SupervisorGroup group;

  const TripProgramScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => TripProgramCubit(context.read<SupervisorRepository>(), group.id)..load(), child: const _ProgramView());
  }
}

class _ProgramView extends StatefulWidget {
  const _ProgramView();

  @override
  State<_ProgramView> createState() => _ProgramViewState();
}

class _ProgramViewState extends State<_ProgramView> {
  static const _pageTop = 155.0;
  final _pages = PageController();

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripProgramCubit, ListState<TripDay>>(
      builder: (context, state) {
        final days = state.items;
        return SupervisorPage(
          builder: (c) => [
            if (days.isNotEmpty)
              c.rect(
                left: 25,
                top: 117,
                width: 343,
                height: 32,
                child: SupSegmented(
                  s: c.s,
                  controller: _pages,
                  labels: [for (final d in days) TripProgramText.day('${d.number}')],
                  labelStyle: supText(c, 13, FigmaWeight.sfRegular, Colors.black),
                ),
              ),
            // مفتاح ثابت: تبويبات الأيام بتنضاف بعد التحميل، فبدونه بينبني PageView تاني لنفس الـ controller
            KeyedSubtree(
              key: const ValueKey('days'),
              child: c.rect(
                left: 0,
                top: _pageTop,
                width: 393,
                height: 818 - _pageTop,
                child: PageView(
                  controller: _pages,
                  children: [
                    for (final d in days)
                      SupKeepAlive(
                        child: _DayPage(c: c.at(_pageTop), day: d),
                      ),
                  ],
                ),
              ),
            ),
            // تحميل / فشل / فاضي
            if (!state.loaded) c.rect(left: 176, top: 300, width: 40, height: 40, child: const CircularProgressIndicator(strokeWidth: 2.4, color: SupColors.green)),
            if (state.loaded && days.isEmpty && state.failed) ...[
              c.text(TripProgramText.loadFailed(), left: 24, top: 300, width: 345, height: 44, align: TextAlign.center, style: supText(c, 14, FigmaWeight.sfRegular, SupColors.grey)),
              c.tapArea(left: 24, top: 290, width: 345, height: 64, onTap: context.read<TripProgramCubit>().load),
            ],
            if (state.loaded && days.isEmpty && !state.failed) ...[
              c.text(TripProgramText.empty(), left: 24, top: 280, width: 345, height: 24, align: TextAlign.center, style: supText(c, 18, FigmaWeight.sfBold, SupColors.green)),
              c.text(TripProgramText.emptyHint(), left: 40, top: 314, width: 313, height: 44, align: TextAlign.center, style: supText(c, 13, FigmaWeight.sfRegular, SupColors.grey)),
            ],
            if (state.loaded) c.button(TripProgramText.add(), left: 16, top: 748, figmaSpacing: true, onTap: () => _addActivity(context, days)),
            PositionedDirectional(
              start: 0,
              end: 0,
              top: 0,
              child: BackTitleHeader(scale: c.s, title: TripProgramText.title()),
            ),
          ],
        );
      },
    );
  }

  /// "+ إضافة نشاط": اليوم (افتراضياً اليوم المفتوح) والوقت والاسم والمكان → PUT البرنامج
  Future<void> _addActivity(BuildContext context, List<TripDay> days) async {
    final cubit = context.read<TripProgramCubit>();
    final page = _pages.hasClients ? (_pages.page ?? 0).round() : 0;
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddActivitySheet(cubit: cubit, initialDay: page < days.length ? days[page].date : null),
    );
    if (added == true && context.mounted) SupervisorController.showMessage(context, TripProgramText.added);
  }
}

/// نموذج إضافة نشاط — الأخطاء بتطلع جوّاه وبيضل مفتوح
class _AddActivitySheet extends StatefulWidget {
  final TripProgramCubit cubit;
  final DateTime? initialDay;

  const _AddActivitySheet({required this.cubit, this.initialDay});

  @override
  State<_AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<_AddActivitySheet> {
  final _title = TextEditingController();
  final _place = TextEditingController();
  late DateTime _day = widget.initialDay ?? DateTime.now();
  TimeOfDay? _time;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    super.dispose();
  }

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: _day, firstDate: DateTime(now.year - 1), lastDate: DateTime(now.year + 5));
    if (picked != null) setState(() => _day = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time ?? const TimeOfDay(hour: 6, minute: 0));
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_title.text.trim().isEmpty) return setState(() => _error = TripProgramText.needTitle());
    setState(() {
      _busy = true;
      _error = null;
    });
    final t = _time;
    try {
      await widget.cubit.addActivity(
        day: _day,
        title: _title.text,
        time: t == null ? null : DateTime(_day.year, _day.month, _day.day, t.hour, t.minute),
        place: _place.text,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e is StateError ? TripProgramText.noTrip() : ApiErrorText.of(e)();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = SupColors.green;
    const label = TextStyle(fontFamily: 'NotoSansArabic', fontSize: 13, color: green);
    const value = TextStyle(fontFamily: 'NotoSansArabic', fontSize: 14, color: green);
    const hint = TextStyle(fontFamily: 'NotoSansArabic', fontSize: 14, color: SupColors.secondaryLabel);
    final t = _time;
    Widget box(Widget child, {VoidCallback? onTap}) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            height: 53,
            alignment: AlignmentDirectional.centerStart,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E5EA))),
            child: child,
          ),
        );
    Widget field(TextEditingController c, String h) => box(TextField(controller: c, enabled: !_busy, style: value, cursorColor: green, decoration: InputDecoration.collapsed(hintText: h, hintStyle: hint)));
    Widget gap(String text) => Padding(padding: const EdgeInsets.only(top: 12, bottom: 8), child: Text(text, style: label));
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(TripProgramText.addTitle(), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'NotoSansArabic', fontSize: 18, fontWeight: FontWeight.bold, color: green)),
            gap(TripProgramText.activityTitle()),
            field(_title, TripProgramText.activityTitleHint()),
            gap(TripProgramText.date()),
            box(Text(SupFormat.date(_day), style: value), onTap: _busy ? null : _pickDay),
            gap(TripProgramText.time()),
            box(Text(t == null ? TripProgramText.timeHint() : SupFormat.longTime(DateTime(2000, 1, 1, t.hour, t.minute)), style: t == null ? hint : value), onTap: _busy ? null : _pickTime),
            gap(TripProgramText.place()),
            field(_place, TripProgramText.placeHint()),
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'NotoSansArabic', fontSize: 13, color: SupColors.red))),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: _busy ? null : _save,
                child: _busy
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                    : Text(TripProgramText.save(), style: const TextStyle(fontFamily: 'NotoSansArabic', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayPage extends StatelessWidget {
  final FigmaCanvas c;
  final TripDay day;

  const _DayPage({required this.c, required this.day});

  static const _firstCircle = 250.0;
  static const _pitch = 101.0;

  @override
  Widget build(BuildContext context) {
    final bottom = _firstCircle + _pitch * day.activities.length;
    return SingleChildScrollView(
      physics: supScrollPhysics,
      child: SizedBox(
        height: c.s.y(bottom - c.originTop),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // تاريخ اليوم
            c.box(left: 332, top: 165, width: 45, height: 45, color: SupColors.cardFill, radius: 22.5, hasShadow: true),
            c.image('$supAssets/ic_calendar_clock.png', left: 343, top: 176, width: 24, height: 24),
            c.text(day.dateLabel, left: 60, top: 176.5, width: 263, height: 19, style: supText(c, 16, FigmaWeight.sfRegular, SupColors.green)),
            // خط 285 متدرج من شفاف (يسار) لـ #1F3B2E (يمين)
            c.box(
              left: 55,
              top: 232,
              width: 285,
              height: 1,
              gradient: const LinearGradient(begin: AlignmentDirectional.centerEnd, end: AlignmentDirectional.centerStart, colors: [Color(0x001F3B2E), SupColors.green]),
            ),
            for (var i = 0; i < day.activities.length; i++) ..._activity(context, day.activities[i], _firstCircle + _pitch * i, last: i == day.activities.length - 1),
          ],
        ),
      ),
    );
  }

  List<Widget> _activity(BuildContext context, TripActivity a, double top, {required bool last}) {
    final hotel = a.kind == ActivityPlace.hotel;
    return [
      // الخط بين الدوائر: 1×40 متدرج من شفاف (فوق) لـ #1F3B2E (تحت)
      if (!last)
        c.box(
          left: 353,
          top: top + 53,
          width: 1,
          height: 40,
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x001F3B2E), SupColors.green]),
        ),
      c.box(left: 332, top: top, width: 45, height: 45, color: SupColors.cardFill, radius: 22.5, hasShadow: true),
      if (hotel) c.image('$supAssets/ic_hotel_sign.png', left: 342, top: top + 10, width: 26, height: 26) else c.image('$supAssets/ic_kaaba.png', left: 341, top: top + 11, width: 26, height: 24),
      // الوقت (SF Compact Regular 12.5) / النشاط (SemiBold 14) / المكان (SF Compact Regular 12) — طرفهم x323.5
      c.text(a.time, left: 120, top: top - 0.5, width: 203.5, height: 15, style: supText(c, 12.5, FigmaWeight.sfRegular, SupColors.green)),
      c.text(a.title, left: 60, top: top + 17, width: 263.5, height: 17, style: supText(c, 14, FigmaWeight.semiBold, SupColors.green)),
      c.text(a.place, left: 60, top: top + 38, width: 263.5, height: 14, style: supText(c, 12, FigmaWeight.sfRegular, SupColors.green)),
      ...supChevron(c, left: 19, top: top + 11),
      c.tapArea(left: 0, top: top - 5, width: 393, height: 55, onTap: () => SupervisorController.comingSoon(context)),
    ];
  }
}
