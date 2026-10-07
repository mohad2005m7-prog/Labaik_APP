import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/custom_step_progress.dart';
import '../widgets/setup_header.dart';
import '../widgets/time_wheel_picker.dart';
import 'stay_location_screen.dart';

// -------------------------------------------------------------
// شاشة "متى ستنطلق في رحلتك إلى مكة؟" — مطابقة لـ Figma (393×852)
// الحالات: (1) فارغة  (2) التقويم مفتوح  (3) عجلة الوقت مفتوحة  (4) معبّأة
// التاريخ: تقويم ينفتح تحت الحقل (iOS + Android)
// الوقت: iOS عجلة تحت الحقل — Android نافذة الساعة الأصلية
// -------------------------------------------------------------
class DepartureDateTimeScreen extends StatefulWidget {
  const DepartureDateTimeScreen({super.key});

  @override
  State<DepartureDateTimeScreen> createState() =>
      _DepartureDateTimeScreenState();
}

class _DepartureDateTimeScreenState extends State<DepartureDateTimeScreen> {
  // ألوان Figma
  static const _green = Color(0xFF1F3B2E);
  static const _black = Color(0xFF1F3B2E);
  static const _accent = Color(0xFF4C7A75);
  static const _fieldFill = Color(0x1A4C7A75); // #4C7A75 بشفافية 10%

  DateTime? _arrivalDate;
  TimeOfDay? _arrivalTime;
  TimeOfDay? _pendingTime; // قيمة العجلة قبل تثبيتها بالحقل
  bool _notDecidedYet = false;

  bool _isDateOpen = false;
  bool _isTimeOpen = false;

  static const _months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  bool get _isIOS => Theme.of(context).platform == TargetPlatform.iOS;

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  String get _dateText {
    final d = _arrivalDate;
    if (d == null) return 'تاريخ الوصول';
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  String get _timeText {
    final t = _arrivalTime;
    if (t == null) return 'اختر وقت الوصول';
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.period == DayPeriod.am ? 'am' : 'pm'}';
  }

  // تثبيت قيمة عجلة الوقت بالحقل عند إغلاقها
  void _commitPendingTime() {
    if (_pendingTime != null) {
      _arrivalTime = _pendingTime;
      _pendingTime = null;
      _notDecidedYet = false;
    }
  }

  void _onDateFieldTap() {
    setState(() {
      _commitPendingTime();
      _isTimeOpen = false;
      _isDateOpen = !_isDateOpen;
    });
  }

  Future<void> _onTimeFieldTap() async {
    if (_isIOS) {
      setState(() {
        if (_isTimeOpen) {
          _commitPendingTime();
        } else {
          _pendingTime = _arrivalTime ?? TimeOfDay.now();
        }
        _isDateOpen = false;
        _isTimeOpen = !_isTimeOpen;
      });
      return;
    }

    // Android: نافذة الساعة الأصلية
    setState(() => _isDateOpen = false);
    final picked = await showTimePicker(
      context: context,
      initialTime: _arrivalTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _accent,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _arrivalTime = picked;
        _notDecidedYet = false;
      });
    }
  }

  void _onNextPressed() {
    setState(_commitPendingTime);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StayLocationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SetupHeader(title: 'متى ستنطلق في رحلتك إلى مكة؟'),
            // Slider (369×42)
            const SizedBox(
              height: 42,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Center(child: CustomStepProgress(currentStep: 4)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'يرجى إدخال تاريخ ووقت انطلاقك لنتمكن من تنبيهك بخطوات الإحرام في الوقت المناسب.',
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        color: _black,
                        height: 1.6,
                      ),
                    ),

                    // ---------- التاريخ ----------
                    _labelSlot(
                      'اختر تاريخ الوصول',
                      visible: _isDateOpen || _isTimeOpen,
                      color: _isDateOpen ? _accent : _black,
                    ),
                    _pickerField(
                      text: _dateText,
                      icon: Icons.event_available_outlined,
                      isOpen: _isDateOpen,
                      onTap: _onDateFieldTap,
                    ),
                    if (_isDateOpen) ...[
                      const SizedBox(height: 38),
                      _calendarCard(),
                      const SizedBox(height: 33),
                    ],

                    // ---------- الوقت (يختفي أثناء فتح التقويم) ----------
                    if (!_isDateOpen) ...[
                      const SizedBox(height: 5),
                      _labelSlot(
                        'وقت الوصول المتوقع',
                        visible: _isTimeOpen,
                        color: _black,
                      ),
                      _pickerField(
                        text: _timeText,
                        icon: Icons.access_time,
                        isOpen: _isTimeOpen,
                        onTap: _onTimeFieldTap,
                      ),
                      if (_isTimeOpen) ...[
                        const SizedBox(height: 22),
                        TimeWheelPicker(
                          initialTime: _pendingTime ?? TimeOfDay.now(),
                          onChanged: (t) => _pendingTime = t,
                        ),
                        const SizedBox(height: 36),
                      ] else ...[
                        const SizedBox(height: 16),
                        _notDecidedRow(),
                        const SizedBox(height: 26),
                        Text(
                          'يمكنك تعديل الموعد لاحقًا إذا تغيّرت خطتك.',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: _accent,
                          ),
                        ),
                        const SizedBox(height: 36),
                      ],
                    ],

                    // زر التالي (361×50)
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _onNextPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'التالي',
                          style: GoogleFonts.tajawal(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // مساحة العنوان فوق الحقل (361×36) — محجوزة دائماً حتى ما تتحرك الحقول
  Widget _labelSlot(
    String text, {
    required bool visible,
    required Color color,
  }) {
    return SizedBox(
      height: 36,
      child: Align(
        alignment: AlignmentDirectional.bottomStart,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: visible
              ? Text(
                  text,
                  style: GoogleFonts.tajawal(fontSize: 12, color: color),
                )
              : null,
        ),
      ),
    );
  }

  // الحقل (361×40): الأيقونة بالبداية — النص — السهم بالنهاية
  Widget _pickerField({
    required String text,
    required IconData icon,
    required bool isOpen,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: _fieldFill,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: _black),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.tajawal(fontSize: 12, color: _black),
              ),
            ),
            Icon(
              isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 24,
              color: _black,
            ),
          ],
        ),
      ),
    );
  }

  // كرت التقويم: أبيض، radius 13، ظل (0,4) blur 4 أسود 25%
  Widget _calendarCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _accent,
            onPrimary: Colors.white,
            onSurface: Color(0xFF3C3C43),
          ),
        ),
        child: Directionality(
          textDirection:
              TextDirection.ltr, // التقويم بالشكل الإنجليزي حسب Figma
          child: CalendarDatePicker(
            initialDate: _arrivalDate ?? _today,
            firstDate: _today,
            lastDate: DateTime(_today.year + 2, 12, 31),
            onDateChanged: (d) {
              setState(() {
                _arrivalDate = d;
                _notDecidedYet = false;
                _isDateOpen = false; // يُغلق بعد اختيار اليوم
              });
            },
          ),
        ),
      ),
    );
  }

  // "لم أحدد موعد الوصول بعد" (checkbox 20×20)
  Widget _notDecidedRow() {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: _notDecidedYet,
            activeColor: _green,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            side: const BorderSide(color: _black, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
            onChanged: (val) {
              setState(() {
                _notDecidedYet = val ?? false;
                if (_notDecidedYet) {
                  _arrivalDate = null;
                  _arrivalTime = null;
                  _pendingTime = null;
                }
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'لم أحدد موعد الوصول بعد',
            style: GoogleFonts.tajawal(fontSize: 12, color: Color(0xFF000000)),
        ),
      ],
    );
  }
}
