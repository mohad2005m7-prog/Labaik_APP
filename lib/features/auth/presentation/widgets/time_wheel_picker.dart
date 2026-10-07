import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// -------------------------------------------------------------
// عجلة اختيار الوقت (ستايل iOS) مطابقة لـ Figma (355×177):
// ساعة / دقيقة / AM-PM، شريط الاختيار بلون #4C7A75 والرقم المختار أبيض،
// باقي الأرقام #3C3C43 بشفافية 60%.
// -------------------------------------------------------------
class TimeWheelPicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onChanged;

  const TimeWheelPicker({super.key, required this.initialTime, required this.onChanged});

  @override
  State<TimeWheelPicker> createState() => _TimeWheelPickerState();
}

class _TimeWheelPickerState extends State<TimeWheelPicker> {
  static const _accent = Color(0xFF4C7A75);
  static const _idleText = Color(0x993C3C43); // #3C3C43 بشفافية 60%
  static const double _itemExtent = 32;

  late int _hourIndex; // 0..11 => الساعة 1..12
  late int _minute; // 0..59
  late int _period; // 0 = AM, 1 = PM

  late final FixedExtentScrollController _hourCtrl;
  late final FixedExtentScrollController _minuteCtrl;
  late final FixedExtentScrollController _periodCtrl;

  @override
  void initState() {
    super.initState();
    final t = widget.initialTime;
    final hour12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    _hourIndex = hour12 - 1;
    _minute = t.minute;
    _period = t.period == DayPeriod.am ? 0 : 1;
    _hourCtrl = FixedExtentScrollController(initialItem: _hourIndex);
    _minuteCtrl = FixedExtentScrollController(initialItem: _minute);
    _periodCtrl = FixedExtentScrollController(initialItem: _period);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    _periodCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    final hour24 = (_hourIndex + 1) % 12 + (_period == 1 ? 12 : 0);
    widget.onChanged(TimeOfDay(hour: hour24, minute: _minute));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 177,
      child: Directionality(
        textDirection: TextDirection.ltr, // ترتيب الأعمدة: ساعة، دقيقة، AM/PM
        child: Stack(
          alignment: Alignment.center,
          children: [
            // شريط الاختيار
            Container(
              width: double.infinity,
              height: _itemExtent,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _column(
                  controller: _hourCtrl,
                  count: 12,
                  selected: _hourIndex,
                  looping: true,
                  label: (i) => '${i + 1}',
                  onChanged: (i) {
                    setState(() => _hourIndex = i);
                    _emit();
                  },
                ),
                _column(
                  controller: _minuteCtrl,
                  count: 60,
                  selected: _minute,
                  looping: true,
                  label: (i) => i.toString().padLeft(2, '0'),
                  onChanged: (i) {
                    setState(() => _minute = i);
                    _emit();
                  },
                ),
                _column(
                  controller: _periodCtrl,
                  count: 2,
                  selected: _period,
                  looping: false,
                  label: (i) => i == 0 ? 'AM' : 'PM',
                  onChanged: (i) {
                    setState(() => _period = i);
                    _emit();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _column({
    required FixedExtentScrollController controller,
    required int count,
    required int selected,
    required bool looping,
    required String Function(int) label,
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      width: 66,
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: _itemExtent,
        looping: looping,
        selectionOverlay: const SizedBox.shrink(),
        onSelectedItemChanged: onChanged,
        children: List.generate(
          count,
          (i) => Center(
            child: Text(
              label(i),
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w500,
                color: i == selected ? Colors.white : _idleText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
