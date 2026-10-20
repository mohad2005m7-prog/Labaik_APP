import 'package:flutter/material.dart';

import '../../../../core/l10n/common_text.dart';
import '../../data/models/trip_setup_data.dart';
import '../../data/models/trip_type.dart';
import '../l10n/trip_type_text.dart';
import '../widgets/icon_option_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/setup_header.dart';
import 'location_permission_screen.dart';

// -------------------------------------------------------------
// شاشة "نوع الرحلة" — مطابقة لـ Figma (393×852)
// -------------------------------------------------------------
class TripTypeScreen extends StatefulWidget {
  const TripTypeScreen({super.key});

  @override
  State<TripTypeScreen> createState() => _TripTypeScreenState();
}

class _TripTypeScreenState extends State<TripTypeScreen> {
  final _data = TripSetupData.instance;

  void _onContinuePressed() {
    if (_data.tripType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TripTypeText.chooseFirst())),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocationPermissionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SetupHeader(title: TripTypeText.title()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 19, 16, 24),
                child: Column(
                  children: [
                    IconOptionCard(
                      label: TripTypeText.umrah(),
                      icon: Icons.view_in_ar_outlined,
                      selected: _data.tripType == TripType.umrah,
                      onTap: () => setState(() => _data.tripType = TripType.umrah),
                    ),
                    const SizedBox(height: 16),
                    IconOptionCard(
                      label: TripTypeText.hajj(),
                      icon: Icons.groups_outlined,
                      selected: _data.tripType == TripType.hajj,
                      onTap: () => setState(() => _data.tripType = TripType.hajj),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(label: CommonText.continueLabel(), onPressed: _onContinuePressed),
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
