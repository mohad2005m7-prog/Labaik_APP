import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
