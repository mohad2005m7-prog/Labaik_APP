import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/location_service.dart';
import '../../data/models/trip_setup_data.dart';
import '../l10n/location_permission_text.dart';
import '../widgets/primary_button.dart';
import '../widgets/setup_header.dart';
import 'prepare_trip_screen.dart';

// -------------------------------------------------------------
// شاشة "فعّل موقعك" — مطابقة لـ Figma (393×852)
// -------------------------------------------------------------
class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  Future<void> _goNext(BuildContext context, {required bool enable}) async {
    // "تفعيل الموقع" بيطلب صلاحية الموقع من النظام (وبنكمل حتى لو رفض — الخريطة بتطلبها مرة ثانية)
    final access = enable ? await LocationService.requestAccess() : null;
    TripSetupData.instance.locationEnabled = access == LocationAccess.granted;
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrepareTripScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SetupHeader(title: LocationPermissionText.title()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                child: Column(
                  children: [
                    // الوصف (361×66)
                    Text(
                      LocationPermissionText.description(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF000000),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 34),
                    // أيقونة الموقع (150×150)
                    const SizedBox(
                      width: 150,
                      height: 150,
                      child: Icon(Icons.location_on_outlined, size: 150, color: Color(0xFF1F3B2E)),
                    ),
                    const SizedBox(height: 33),
                    PrimaryButton(
                      label: LocationPermissionText.enable(),
                      onPressed: () => _goNext(context, enable: true),
                    ),
                    const SizedBox(height: 26),
                    PrimaryButton(
                      label: LocationPermissionText.later(),
                      outlined: true,
                      onPressed: () => _goNext(context, enable: false),
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
}
