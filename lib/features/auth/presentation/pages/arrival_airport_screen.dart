import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/sources/saudi_airports.dart';
import '../../data/models/trip_setup_data.dart';
import '../widgets/custom_step_progress.dart';
import '../widgets/primary_button.dart';
import '../widgets/setup_dropdown.dart';
import '../widgets/setup_header.dart';
import 'trip_route_screen.dart';

// -------------------------------------------------------------
// شاشة "ما مطار وصولك؟" — مطابقة لـ Figma (393×852)
// -------------------------------------------------------------
class ArrivalAirportScreen extends StatefulWidget {
  const ArrivalAirportScreen({super.key});

  @override
  State<ArrivalAirportScreen> createState() => _ArrivalAirportScreenState();
}

class _ArrivalAirportScreenState extends State<ArrivalAirportScreen> {
  final _data = TripSetupData.instance;

  void _onNextPressed() {
    if (_data.arrivalPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار مطار الوصول أولاً')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TripRouteScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = [
      SetupDropdownGroup(
        'المطارات الدولية الرئيسية',
        SaudiAirports.international.map((a) => SetupDropdownItem(a.code, a.name)).toList(),
      ),
      SetupDropdownGroup(
        'المطارات الإقليمية والمحلية',
        SaudiAirports.regional.map((a) => SetupDropdownItem(a.code, a.name)).toList(),
      ),
    ];
    // نتأكد إنو القيمة المحفوظة موجودة بقائمة هاي الشاشة
    final exists = groups.any((g) => g.items.any((i) => i.value == _data.arrivalPlace));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SetupHeader(title: 'ما مطار وصولك؟'),
            const SizedBox(
              height: 42,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Center(child: CustomStepProgress(currentStep: 2)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'اختر المطار الذي ستصل إليه في السعودية.',
                      style: GoogleFonts.tajawal(fontSize: 13, color: const Color(0xFF000000)),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: SetupDropdown(
                        hint: 'ابحث عن مطار وصولك',
                        value: exists ? _data.arrivalPlace : null,
                        groups: groups,
                        onChanged: (v) => setState(() => _data.arrivalPlace = v),
                      ),
                    ),
                    const SizedBox(height: 31),
                    PrimaryButton(label: 'التالي', onPressed: _onNextPressed),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
