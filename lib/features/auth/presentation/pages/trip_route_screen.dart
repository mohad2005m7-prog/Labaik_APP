import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/common_text.dart';
import '../../data/models/trip_setup_data.dart';
import '../../data/sources/saudi_cities.dart';
import '../l10n/trip_route_text.dart';
import '../widgets/custom_step_progress.dart';
import 'departure_datetime_screen.dart';

// -------------------------------------------------------------
// شاشة "ما مسار رحلتك؟"
// المستخدم يحدد وجهته الأولى والتالية داخل السعودية، مع إمكانية
// إضافة محطات إضافية. القوائم معبّأة بمدن السعودية مقسّمة حسب المنطقة.
// المقاسات والألوان مطابقة لتصميم Figma.
// -------------------------------------------------------------
class TripRouteScreen extends StatefulWidget {
  const TripRouteScreen({super.key});

  @override
  State<TripRouteScreen> createState() => _TripRouteScreenState();
}

class _TripRouteScreenState extends State<TripRouteScreen> {
  // ألوان Figma
  static const _green = Color(0xFF1F3B2E);
  static const _labelColor = Color(0xFF000000);
  // لون خلفية الحقل: #767680 بشفافية 12%
  static final _fieldFill = const Color(0xFF767680).withValues(alpha: 0.12);

  String? _firstDestination;
  String? _secondDestination;
  final List<String?> _extraStops = [];

  void _addStop() {
    setState(() => _extraStops.add(null));
  }

  void _onNextPressed() {
    // حفظ المدن بالترتيب (بدون فراغات أو تكرار) لتظهر بشاشات "أين ستقيم؟"
    final cities = <String>[];
    for (final c in [_firstDestination, _secondDestination, ..._extraStops]) {
      if (c != null && !cities.contains(c)) cities.add(c);
    }
    TripSetupData.instance.routeCities = cities;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DepartureDateTimeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _labelColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomStepProgress(currentStep: 3),
              const SizedBox(height: 28),

              // العنوان (Header ~ 24)
              Text(
                TripRouteText.title(),
                style: GoogleFonts.tajawal(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _labelColor,
                ),
              ),
              const SizedBox(height: 12),
              // الوصف (Body ~ 13)
              Text(
                TripRouteText.description(),
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),

              _buildFieldLabel(TripRouteText.firstStop()),
              const SizedBox(height: 8),
              _buildDropdown(
                hint: TripRouteText.searchFirst(),
                value: _firstDestination,
                onChanged: (val) => setState(() => _firstDestination = val),
              ),
              const SizedBox(height: 18),

              _buildFieldLabel(TripRouteText.nextStop()),
              const SizedBox(height: 8),
              _buildDropdown(
                hint: TripRouteText.searchNext(),
                value: _secondDestination,
                onChanged: (val) => setState(() => _secondDestination = val),
              ),
              const SizedBox(height: 14),

              ..._buildExtraStops(),

              GestureDetector(
                onTap: _addStop,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.add, size: 18, color: _green),
                      const SizedBox(width: 6),
                      Text(
                        TripRouteText.addStop(),
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // زر التالي (ارتفاع 50 مطابق لـ Figma)
              SizedBox(
                width: double.infinity,
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
                    CommonText.next(),
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _labelColor,
      ),
    );
  }

  List<Widget> _buildExtraStops() {
    final List<Widget> widgets = [];
    for (int i = 0; i < _extraStops.length; i++) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _buildDropdown(
            hint: TripRouteText.searchNext(),
            value: _extraStops[i],
            onChanged: (val) => setState(() => _extraStops[i] = val),
          ),
        ),
      );
    }
    return widgets;
  }

  // قائمة منسدلة بمدن السعودية مقسّمة حسب المنطقة
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 44, // مطابق لـ Figma (361×44)
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.tajawal(fontSize: 14, color: Colors.grey.shade500),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: _buildCityItems(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildCityItems() {
    final List<DropdownMenuItem<String>> items = [];
    for (final region in SaudiCitiesData.regions) {
      items.add(
        DropdownMenuItem<String>(
          enabled: false,
          child: Text(
            region.region,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _green,
            ),
          ),
        ),
      );
      items.addAll(region.cities.map(
        (c) => DropdownMenuItem<String>(
          value: c,
          child: Text(
            c,
            style: GoogleFonts.tajawal(fontSize: 13, color: _labelColor),
          ),
        ),
      ));
    }
    return items;
  }
}
