import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/common_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_line.dart';
import '../../../auth/presentation/l10n/departure_text.dart';
import '../../../auth/presentation/widgets/time_wheel_picker.dart';
import '../../domain/entities/trip.dart';
import '../controllers/trip_details_controller.dart';
import '../cubits/trip_edit_cubit.dart';
import '../l10n/trip_edit_text.dart';
import '../l10n/trip_format.dart';
import '../widgets/trip_calendar_card.dart';
import '../widgets/trip_colors.dart';
import '../widgets/trip_edit_page.dart';
import '../widgets/trip_not_decided.dart';
import '../widgets/trip_picker_field.dart';
import '../widgets/trip_question.dart';

// -------------------------------------------------------------
// 7تعديل تفاصيل الرحلة — Figma (1:7914): "متى ستنطلق في رحلتك إلى مكة؟" — التاريخ — الوقت —
// "لم أحدد موعد الوصول بعد" — "يمكنك تعديل الموعد لاحقًا…" → التالي
// فتح الحقلين زي شاشة الإعداد (حالاتها مش مرسومة بإطارات التعديل): التقويم تحت حقل التاريخ (وبيخبّي الباقي)
// وعجلة الوقت تحت حقل الوقت (وبتخبّي "لم أحدد…" والملاحظة) — الوقت بيثبت لما تتسكّر العجلة
// -------------------------------------------------------------
class EditDepartureScreen extends StatefulWidget {
  const EditDepartureScreen({super.key});

  @override
  State<EditDepartureScreen> createState() => _EditDepartureScreenState();
}

class _EditDepartureScreenState extends State<EditDepartureScreen> {
  bool _dateOpen = false;
  bool _timeOpen = false;

  /// قيمة العجلة قبل ما تثبت بالحقل (دقائق من نص الليل)
  int? _pendingMinute;

  TripEditCubit get _cubit => context.read<TripEditCubit>();

  void _commitTime() {
    final minute = _pendingMinute;
    if (minute != null) _cubit.setDepartureMinute(minute);
    _pendingMinute = null;
  }

  void _toggleDate() => setState(() {
        if (_timeOpen) _commitTime();
        _timeOpen = false;
        _dateOpen = !_dateOpen;
      });

  void _toggleTime() => setState(() {
        if (_timeOpen) {
          _commitTime();
        } else {
          final now = TimeOfDay.now();
          _pendingMinute = _cubit.state.departureMinute ?? now.hour * 60 + now.minute;
        }
        _dateOpen = false;
        _timeOpen = !_timeOpen;
      });

  void _pickDate(DateTime date) {
    _cubit.setDepartureDate(date);
    setState(() => _dateOpen = false);
  }

  void _next() {
    setState(() {
      if (_timeOpen) _commitTime();
      _dateOpen = _timeOpen = false;
    });
    final trip = _cubit.state;
    if (!trip.departureNotDecided && (trip.departureDate == null || trip.departureMinute == null)) {
      TripDetailsController.showMessage(ScaffoldMessenger.of(context), TripEditText.chooseDeparture());
      return;
    }
    TripDetailsController.toStays(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripEditCubit, Trip>(
      builder: (context, trip) {
        final minute = trip.departureMinute;
        final pending = _pendingMinute ?? minute;
        return TripEditPage(
          steps: 4,
          button: CommonText.next(),
          onNext: _next,
          content: (c) => [
            TripQuestion.title(c, DepartureText.title()),
            TripQuestion.spaced(c, TripEditText.departureDescription(), width: 254, lines: 2),
            Positioned.fill(
              child: TripPickerField(
                c: c,
                top: 323,
                icon: TripFieldIcon.calendar,
                text: trip.departureDate == null ? DepartureText.arrivalDate() : TripFormat.date(trip.departureDate),
                empty: trip.departureDate == null,
                open: _dateOpen,
                textRight: 313.5,
                onTap: _toggleDate,
              ),
            ),
            if (!_dateOpen)
              Positioned.fill(
                child: TripPickerField(
                  c: c,
                  top: 379,
                  icon: TripFieldIcon.clock,
                  text: minute == null ? DepartureText.chooseArrivalTime() : TripFormat.time(minute),
                  empty: minute == null,
                  open: _timeOpen,
                  textRight: 315,
                  onTap: _toggleTime,
                ),
              ),
            if (_timeOpen)
              c.rect(
                left: 19,
                top: 427,
                width: 355,
                height: 177,
                child: TimeWheelPicker(
                  initialTime: TimeOfDay(hour: (pending ?? 0) ~/ 60, minute: (pending ?? 0) % 60),
                  onChanged: (t) => _pendingMinute = t.hour * 60 + t.minute,
                ),
              ),
            if (!_dateOpen && !_timeOpen) ...[
              Positioned.fill(child: TripNotDecided(c: c, checked: trip.departureNotDecided, onTap: () => _cubit.setDepartureNotDecided(!trip.departureNotDecided))),
              // Poppins 300 14 #1F3B2E
              // (صندوقه بـ Figma على قد النص: 94..305.5 — مقاس)
              c.line(TripEditText.canChangeLater(), left: 94, top: 476, width: 211.5, height: 22, fit: true, style: c.style(14, FigmaWeight.poppinsLight, TripColors.green)),
            ],
          ],
          // التقويم فوق الكل (بيطلع لتحت الكرت زي شاشة الإعداد)
          overlay: (c) => [if (_dateOpen) TripCalendarCard(c: c, top: 371, selected: trip.departureDate, onSelected: _pickDate)],
        );
      },
    );
  }
}
