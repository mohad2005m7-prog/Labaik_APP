import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/common_text.dart';
import '../../data/models/trip_setup_data.dart';
import '../../data/sources/arrival_points.dart';
import '../l10n/entry_port_text.dart';
import '../widgets/custom_step_progress.dart';
import '../widgets/primary_button.dart';
import '../widgets/setup_dropdown.dart';
import '../widgets/setup_header.dart';
import 'trip_route_screen.dart';

// -------------------------------------------------------------
// شاشة "ما منفذ دخولك؟" — مطابقة لـ Figma (393×852)
// -------------------------------------------------------------
class EntryPortScreen extends StatefulWidget {
  const EntryPortScreen({super.key});

  @override
  State<EntryPortScreen> createState() => _EntryPortScreenState();
}

class _EntryPortScreenState extends State<EntryPortScreen> {
  final _data = TripSetupData.instance;

  void _onNextPressed() {
    if (_data.arrivalPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(EntryPortText.chooseFirst())),
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
    final groups = ArrivalPointsData.groups
        .map((g) => SetupDropdownGroup(g.country, g.points.map((p) => SetupDropdownItem(p, p)).toList()))
        .toList();
    // نتأكد إنو القيمة المحفوظة موجودة بقائمة هاي الشاشة
    final exists = groups.any((g) => g.items.any((i) => i.value == _data.arrivalPlace));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SetupHeader(title: EntryPortText.title()),
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
                      EntryPortText.description(),
                      style: GoogleFonts.tajawal(fontSize: 13, color: const Color(0xFF000000)),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: SetupDropdown(
                        hint: EntryPortText.search(),
                        value: exists ? _data.arrivalPlace : null,
                        groups: groups,
                        onChanged: (v) => setState(() => _data.arrivalPlace = v),
                      ),
                    ),
                    const SizedBox(height: 31),
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
}
