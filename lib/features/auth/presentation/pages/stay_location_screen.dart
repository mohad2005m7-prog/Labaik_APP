import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/stay_type.dart';
import '../../data/models/trip_setup_data.dart';
import '../widgets/custom_step_progress.dart';
import '../widgets/setup_header.dart';
import 'home_screen.dart';
import 'stay_place_screen.dart';

// -------------------------------------------------------------
// شاشة "أين ستقيم؟" (1) — مطابقة لـ Figma (393×852)
// قسم لكل مدينة اختارها المستخدم بشاشة "ما مسار رحلتك؟":
// فندق / مكان اخر — أو "لم أحدد مكان إقامتي بعد"
// -------------------------------------------------------------
class StayLocationScreen extends StatefulWidget {
  const StayLocationScreen({super.key});

  @override
  State<StayLocationScreen> createState() => _StayLocationScreenState();
}

class _StayLocationScreenState extends State<StayLocationScreen> {
  // ألوان Figma
  static const _green = Color(0xFF1F3B2E);
  static const _black = Color(0xFF000000);
  static const _chipFill = Color(0x404C7A75); // #4C7A75 بشفافية 25%

  final _data = TripSetupData.instance;

  void _onNextPressed() {
    final hasAnyChoice = _data.stayCities.any((c) => _data.stayTypes[c] != null);

    // لو ما حدد مكان إقامته، ما في داعي لشاشة تفاصيل الإقامة
    if (_data.stayNotDecided || !hasAnyChoice) {
      // TODO: ربط لاحقاً بالشاشة التالية عند إرسالها
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StayPlaceScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cities = _data.stayCities;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SetupHeader(title: 'أين ستقيم؟'),
            const SizedBox(
              height: 42,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Center(child: CustomStepProgress(currentStep: 5)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أخبرنا بمكان إقامتك لنساعدك في الوصول إليه والعثور على الأماكن القريبة.',
                      style: GoogleFonts.tajawal(fontSize: 13, color: _green, height: 1.6),
                    ),
                    const SizedBox(height: 14),

                    // قسم لكل مدينة
                    for (int i = 0; i < cities.length; i++) ...[
                      if (i > 0) const SizedBox(height: 15),
                      _buildSection(cities[i]),
                    ],
                    const SizedBox(height: 24),

                    _notDecidedRow(),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _onNextPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // قسم مدينة: الشارة + "أين ستقيم؟" + فندق / مكان اخر
  Widget _buildSection(String city) {
    final selected = _data.stayTypes[city];
    void onSelect(StayType v) => setState(() {
          _data.stayTypes[city] = v;
          _data.stayNotDecided = false;
        });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 21,
          padding: const EdgeInsets.symmetric(horizontal: 17),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: _chipFill, borderRadius: BorderRadius.circular(21)),
          child: Text('إقامتك في $city', style: GoogleFonts.tajawal(fontSize: 12, color: _green)),
        ),
        const SizedBox(height: 8),
        Text('أين ستقيم؟', style: GoogleFonts.tajawal(fontSize: 12, color: _green)),
        const SizedBox(height: 17),
        _radioRow(StayType.hotel, selected, onSelect),
        const SizedBox(height: 6),
        _radioRow(StayType.other, selected, onSelect),
      ],
    );
  }

  Widget _radioRow(StayType value, StayType? selected, ValueChanged<StayType> onSelect) {
    final isSelected = value == selected;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelect(value),
      child: SizedBox(
        height: 21,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? _green : _black, width: 2),
              ),
              child: isSelected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
                    )
                  : null,
            ),
            const SizedBox(width: 6),
            Text(value.arabicLabel, style: GoogleFonts.tajawal(fontSize: 13, color: _green)),
          ],
        ),
      ),
    );
  }

  Widget _notDecidedRow() {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: _data.stayNotDecided,
            activeColor: _green,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            side: const BorderSide(color: _green, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            onChanged: (val) {
              setState(() {
                _data.stayNotDecided = val ?? false;
                if (_data.stayNotDecided) {
                  _data.stayTypes.clear();
                  _data.stayPlaces.clear();
                }
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Text('لم أحدد مكان إقامتي بعد', style: GoogleFonts.tajawal(fontSize: 12, color: _black)),
      ],
    );
  }
}
