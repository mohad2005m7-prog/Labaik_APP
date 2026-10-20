import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../domain/entities/company_notification.dart';
import '../cubits/company_notifications_cubit.dart';
import '../l10n/company_notifications_text.dart';
import '../widgets/company_colors.dart';
import '../widgets/company_notification_card.dart';

// -------------------------------------------------------------
// إشعارات الشركة — مطابقة لـ Figma "الاشعارات" (751:4011) — من الجرس برئيسية الشركة
// أيام: "اليوم" عند y107 وأول كرت بعده بـ 28، الكروت كل 112، واليوم الجاي بعد آخر كرت بـ 10 وكرته بعده بـ 24.75
// والقائمة الطويلة بتتمرر
// -------------------------------------------------------------
class CompanyNotificationsScreen extends StatelessWidget {
  const CompanyNotificationsScreen({super.key});

  static const _firstLabel = 107.0;
  static const _pitch = 112.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyNotificationsCubit, CompanyNotificationsState>(
      builder: (context, state) {
        final days = _days(state.items);
        final layout = _layout(days);
        return FigmaPage(
          title: CompanyNotificationsText.title(),
          titleRight: 349,
          chevronLeft: 367,
          frameHeight: math.max(852, layout.bottom + 34),
          body: (c) => days.isEmpty
              ? [_status(c, state)]
              : [
                  for (final (i, day) in days.indexed) ...[
                    _dayLabel(c, day.first.createdAt, layout.tops[i].$1, first: i == 0),
                    for (final (j, n) in day.indexed) ...CompanyNotificationCard.build(c, top: layout.tops[i].$2 + j * _pitch, title: n.title, body: n.body, important: n.important),
                  ],
                ],
        );
      },
    );
  }

  static List<List<CompanyNotification>> _days(List<CompanyNotification> items) {
    final days = <List<CompanyNotification>>[];
    for (final n in items) {
      final last = days.lastOrNull;
      if (last != null && DateUtils.isSameDay(last.first.createdAt, n.createdAt)) {
        last.add(n);
      } else {
        days.add([n]);
      }
    }
    return days;
  }

  static ({List<(double, double)> tops, double bottom}) _layout(List<List<CompanyNotification>> days) {
    final tops = <(double, double)>[];
    var y = _firstLabel;
    var bottom = 0.0;
    for (final (i, day) in days.indexed) {
      final card = y + (i == 0 ? 28 : 24.75);
      tops.add((y, card));
      bottom = card + (day.length - 1) * _pitch + CompanyNotificationCard.height;
      y = bottom + 10;
    }
    return (tops: tops, bottom: bottom);
  }

  // "اليوم" (SF Compact 457 11) / "الأمس 9:40" (SF Compact 556 11) / التاريخ — #3C3C43 60% بالنص
  Widget _dayLabel(FigmaCanvas c, DateTime at, double top, {required bool first}) {
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day).difference(DateTime(at.year, at.month, at.day)).inDays;
    final label = days <= 0
        ? CompanyNotificationsText.today()
        : days == 1
            ? CompanyNotificationsText.yesterdayAt('${at.hour % 12 == 0 ? 12 : at.hour % 12}:${at.minute.toString().padLeft(2, '0')}')
            : CompanyNotificationsText.date(at);
    return c.text(label, left: 63, top: top, width: 267, height: 13, align: TextAlign.center, dy: 0, style: c.style(11, first ? FigmaWeight.sfRegular : FigmaWeight.semiBold, CompanyColors.secondaryLabel, lineHeight: 13, letterSpacing: first ? 0.066 : 0.06));
  }

  // لسا بيحمّل / ما في إشعارات (مش بـ Figma)
  Widget _status(FigmaCanvas c, CompanyNotificationsState state) {
    return c.rect(
      left: 24,
      top: 135,
      width: 345,
      height: 40,
      child: Align(
        alignment: Alignment.topCenter,
        child: state.loading
            ? SizedBox.square(dimension: c.s.x(24), child: const CircularProgressIndicator(strokeWidth: 2.5, color: CompanyColors.green))
            : Text(CompanyNotificationsText.empty(), textAlign: TextAlign.center, style: c.style(14, FigmaWeight.sfRegular, const Color(0xFF717171), lineHeight: null, letterSpacing: 0)),
      ),
    );
  }
}
