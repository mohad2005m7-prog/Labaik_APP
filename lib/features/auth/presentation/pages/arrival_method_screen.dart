import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/common_text.dart';
import '../../data/models/arrival_method_enum.dart';
import '../../data/models/trip_setup_data.dart';
import '../l10n/arrival_method_text.dart';
import '../widgets/custom_step_progress.dart';
import '../widgets/primary_button.dart';
import '../widgets/setup_header.dart';
import 'arrival_airport_screen.dart';
import 'arrival_point_screen.dart';
import 'entry_port_screen.dart';

// -------------------------------------------------------------
// شاشة "كيف ستصل إلى السعودية؟" — مطابقة لـ Figma (393×852)
// طائرة → مطار الوصول | حافلة → منفذ الدخول | سيارة خاصة → نقطة الوصول
// -------------------------------------------------------------
class ArrivalMethodScreen extends StatefulWidget {
  const ArrivalMethodScreen({super.key});

  @override
  State<ArrivalMethodScreen> createState() => _ArrivalMethodScreenState();
}

class _ArrivalMethodScreenState extends State<ArrivalMethodScreen> {
  static const _green = Color(0xFF1F3B2E);
  static const _optionFill = Color(0x1A4C7A75); // #4C7A75 بشفافية 10%

  final _data = TripSetupData.instance;

  void _onNextPressed() {
    final method = _data.arrivalMethod;
    if (method == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ArrivalMethodText.chooseFirst())),
      );
      return;
    }

    final Widget next;
    switch (method) {
      case ArrivalMethod.airplane:
        next = const ArrivalAirportScreen();
        break;
      case ArrivalMethod.bus:
        next = const EntryPortScreen();
        break;
      case ArrivalMethod.privateCar:
        next = const ArrivalPointScreen();
        break;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => next));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SetupHeader(title: ArrivalMethodText.title()),
            const SizedBox(
              height: 42,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Center(child: CustomStepProgress(currentStep: 1)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      ArrivalMethodText.description(),
                      style: GoogleFonts.tajawal(fontSize: 13, color: const Color(0xFF000000)),
                    ),
                    const SizedBox(height: 18),
                    _optionCard(ArrivalMethod.airplane, ArrivalMethodText.airplane(), Icons.flight),
                    const SizedBox(height: 16),
                    _optionCard(ArrivalMethod.bus, ArrivalMethodText.bus(), Icons.directions_bus_outlined),
                    const SizedBox(height: 16),
                    _optionCard(ArrivalMethod.privateCar, ArrivalMethodText.privateCar(), Icons.directions_car_outlined),
                    const SizedBox(height: 36),
                    PrimaryButton(label: CommonText.next(), onPressed: _onNextPressed),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // كرت الخيار (361×50) — المحتوى 320×22 — أيقونة 24×24
  Widget _optionCard(ArrivalMethod method, String title, IconData icon) {
    final isSelected = _data.arrivalMethod == method;
    return GestureDetector(
      onTap: () => setState(() {
        // لو غيّر الوسيلة، نمسح المكان المختار سابقاً (مطار/منفذ/نقطة)
        if (_data.arrivalMethod != method) _data.arrivalPlace = null;
        _data.arrivalMethod = method;
      }),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: _optionFill,
          border: Border.all(color: isSelected ? _green : Colors.transparent, width: 1.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: _green),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: const Color(0xFF000000),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
