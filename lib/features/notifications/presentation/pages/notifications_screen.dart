import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/api_error_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../domain/entities/app_notification.dart';
import '../controllers/notifications_controller.dart';
import '../cubits/notifications_cubit.dart';
import '../l10n/notifications_text.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_day_label.dart';

// -------------------------------------------------------------
// إشعارات المعتمر — مطابقة لـ Figma "الاشعارات" (114:10192) — من الجرس بالرئيسية
// الهيدر "Frame 38" (372 من x14) — تحته أيام: "اليوم" عند y107 وأول كرت بعده بـ 28، وكل كرت بعد اللي قبله بـ 101،
// واليوم الجاي بعد آخر كرت بـ 15 وكرته الأول بعده بـ 21 — والقائمة الطويلة بتتمرر
// -------------------------------------------------------------
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _firstLabel = 107.0;
  static const _pitch = 101.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final days = _days(state.visible);
        return FigmaPage(
          title: NotificationsText.title(),
          titleRight: 349,
          chevronLeft: 367,
          // الإطار بيطول (وبيتمرر) لو الكروت أكتر من الشاشة — وتحت آخر كرت مساحة شريط الرجوع للرئيسية
          frameHeight: math.max(852, _layout(days).bottom + 34),
          body: (c) => days.isEmpty ? [_status(c, state)] : _list(context, c, days),
        );
      },
    );
  }

  /// مكان عنوان كل يوم وأول كرت فيه، وآخر كرت بالقائمة
  static ({List<(double label, double card)> tops, double bottom}) _layout(List<List<AppNotification>> days) {
    final tops = <(double, double)>[];
    var y = _firstLabel;
    var bottom = 0.0;
    for (final (i, day) in days.indexed) {
      final card = y + (i == 0 ? 28 : 21);
      tops.add((y, card));
      bottom = card + (day.length - 1) * _pitch + NotificationCard.height;
      y = bottom + 15;
    }
    return (tops: tops, bottom: bottom);
  }

  List<Widget> _list(BuildContext context, FigmaCanvas c, List<List<AppNotification>> days) {
    final tops = _layout(days).tops;
    return [
      for (final (i, day) in days.indexed) ...[
        NotificationDayLabel.build(c, NotificationDayLabel.of(day.first.createdAt), top: tops[i].$1, first: i == 0),
        for (final (j, n) in day.indexed) ..._card(context, c, n, tops[i].$2 + j * _pitch),
      ],
    ];
  }

  /// الإشعارات (من الأحدث) مقسومة حسب اليوم
  static List<List<AppNotification>> _days(List<AppNotification> items) {
    final days = <List<AppNotification>>[];
    for (final n in items) {
      final last = days.lastOrNull;
      final d = n.createdAt;
      if (last != null && DateUtils.isSameDay(last.first.createdAt, d)) {
        last.add(n);
      } else {
        days.add([n]);
      }
    }
    return days;
  }

  List<Widget> _card(BuildContext context, FigmaCanvas c, AppNotification n, double top) {
    return NotificationCard.build(
      c,
      top: top,
      title: NotificationsText.announcementTitle(),
      body: NotificationsText.announcementBody(),
      onTap: () => NotificationsController.openAnnouncement(context, n),
    );
  }

  // لسا بيحمّل / خطأ / ما في إشعارات (مش بـ Figma)
  Widget _status(FigmaCanvas c, NotificationsState state) {
    final error = state.error;
    final text = state.loading
        ? null
        : error != null
            ? ApiErrorText.of(error)()
            : NotificationsText.empty();
    return c.rect(
      left: 24,
      top: 135,
      width: 345,
      height: 40,
      child: Align(
        alignment: Alignment.topCenter,
        child: text == null
            ? SizedBox.square(dimension: c.s.x(24), child: const CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF1F3B2E)))
            : Text(text, textAlign: TextAlign.center, style: c.style(14, FigmaWeight.sfRegular, const Color(0xFF717171), lineHeight: null, letterSpacing: 0)),
      ),
    );
  }
}
