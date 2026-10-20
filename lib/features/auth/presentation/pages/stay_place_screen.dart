import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/common_text.dart';
import '../../data/models/stay_type.dart';
import '../../data/models/trip_setup_data.dart';
import '../../data/sources/city_hotels.dart';
import '../controllers/auth_controller.dart';
import '../l10n/stay_text.dart';
import '../widgets/custom_step_progress.dart';
import '../widgets/setup_header.dart';

// -------------------------------------------------------------
// شاشة "أين ستقيم؟" (2) — مطابقة لـ Figma (393×852)
// لكل مدينة حسب اختيار الشاشة السابقة:
//  - فندق     → قائمة منسدلة "ابحث عن مكان اقامتك" (331×38)
//  - مكان اخر → حقل بحث "أدخل أو حدّد مكان إقامتك" (322×33)
// -------------------------------------------------------------
class StayPlaceScreen extends StatefulWidget {
  const StayPlaceScreen({super.key});

  @override
  State<StayPlaceScreen> createState() => _StayPlaceScreenState();
}

class _StayPlaceScreenState extends State<StayPlaceScreen> {
  // ألوان Figma
  static const _green = Color(0xFF1F3B2E);
  static const _black = Color(0xFF000000);
  static const _chipFill = Color(0x404C7A75); // #4C7A75 بشفافية 25%
  static const _fieldFill = Color(0x1F767680); // #767680 بشفافية 12%
  static const _hintColor = Color(0x8A3C3C43); // #3C3C43 بشفافية 54%

  final _data = TripSetupData.instance;

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final city in _citiesToShow) {
      if (_data.stayTypes[city] == StayType.other) {
        _controllers[city] = TextEditingController(text: _data.stayPlaces[city] ?? '');
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // المدن اللي اختار لها نوع إقامة بالشاشة السابقة
  List<String> get _citiesToShow =>
      _data.stayCities.where((c) => _data.stayTypes[c] != null).toList();

  void _onNextPressed() {
    _controllers.forEach((city, ctrl) {
      final text = ctrl.text.trim();
      _data.stayPlaces[city] = text.isEmpty ? null : text;
    });
    // آخر خطوة بإعداد الرحلة → رئيسية المعتمر (والحساب بيتسجّل إنه خلّص إعداده)
    AuthController.finishTripSetup(context);
  }

  @override
  Widget build(BuildContext context) {
    final cities = _citiesToShow;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SetupHeader(title: StayText.title()),
            const SizedBox(
              height: 42,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Center(child: CustomStepProgress(currentStep: 6)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      StayText.description(),
                      style: GoogleFonts.tajawal(fontSize: 13, color: _green, height: 1.6),
                    ),
                    const SizedBox(height: 14),

                    for (int i = 0; i < cities.length; i++) ...[
                      if (i > 0) const SizedBox(height: 15),
                      _buildSection(cities[i]),
                    ],
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
                          CommonText.next(),
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

  // قسم مدينة: الشارة (161×21) + "أين ستقيم؟" + الحقل حسب نوع الإقامة
  Widget _buildSection(String city) {
    final isHotel = _data.stayTypes[city] == StayType.hotel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 21,
          padding: const EdgeInsets.symmetric(horizontal: 17),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: _chipFill, borderRadius: BorderRadius.circular(21)),
          child: Text(StayText.inCity(city), style: GoogleFonts.tajawal(fontSize: 12, color: _green)),
        ),
        const SizedBox(height: 8),
        Text(StayText.title(), style: GoogleFonts.tajawal(fontSize: 12, color: _black)),
        SizedBox(height: isHotel ? 7 : 10),
        Center(child: isHotel ? _hotelDropdown(city) : _placeSearchField(city)),
      ],
    );
  }

  // فندق → قائمة منسدلة (331×38) بفنادق المدينة مقسّمة حسب التصنيف
  Widget _hotelDropdown(String city) {
    final groups = CityHotels.forCity(city);
    final saved = _data.stayPlaces[city];
    final exists = groups.any((g) => g.hotels.contains(saved));

    final items = <DropdownMenuItem<String>>[];
    for (final g in groups) {
      // عنوان المجموعة (غير قابل للاختيار)
      items.add(
        DropdownMenuItem<String>(
          enabled: false,
          child: Text(
            g.title,
            style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.bold, color: _green),
          ),
        ),
      );
      for (final h in g.hotels) {
        items.add(
          DropdownMenuItem<String>(
            value: h,
            child: Text(
              h,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.tajawal(fontSize: 13, color: _black),
            ),
          ),
        );
      }
    }

    final hint = Text(
      StayText.search(),
      style: GoogleFonts.tajawal(fontSize: 15, color: _hintColor),
    );

    return Container(
      width: 331,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _fieldFill,
        border: Border.all(color: _green, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: exists ? saved : null,
          hint: hint,
          disabledHint: hint,
          menuMaxHeight: 360,
          borderRadius: BorderRadius.circular(10),
          icon: const Icon(Icons.keyboard_arrow_down, size: 22, color: _green),
          items: items,
          onChanged: (v) => setState(() => _data.stayPlaces[city] = v),
        ),
      ),
    );
  }

  // مكان اخر → حقل بحث (322×33)
  Widget _placeSearchField(String city) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _green, width: 1),
    );
    return SizedBox(
      width: 322.63,
      height: 33,
      child: TextField(
        controller: _controllers[city],
        style: GoogleFonts.tajawal(fontSize: 14, color: _black),
        cursorColor: _green,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: _fieldFill,
          hintText: StayText.enterPlace(),
          hintStyle: GoogleFonts.tajawal(fontSize: 15, color: _hintColor),
          prefixIcon: const Icon(Icons.search, size: 20, color: _green),
          prefixIconConstraints: const BoxConstraints(minWidth: 34, minHeight: 33),
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          border: border,
          enabledBorder: border,
          focusedBorder: border,
        ),
      ),
    );
  }
}
