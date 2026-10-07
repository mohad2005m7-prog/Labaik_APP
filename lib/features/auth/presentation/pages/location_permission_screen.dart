import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/trip_setup_data.dart';
import '../widgets/primary_button.dart';
import '../widgets/setup_header.dart';
import 'prepare_trip_screen.dart';

// -------------------------------------------------------------
// شاشة "فعّل موقعك" — مطابقة لـ Figma (393×852)
// -------------------------------------------------------------
class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  void _goNext(BuildContext context, {required bool enable}) {
    TripSetupData.instance.locationEnabled = enable;
    // TODO: طلب صلاحية الموقع الفعلية من النظام (geolocator / permission_handler)
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
            const SetupHeader(title: 'فعّل موقعك'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                child: Column(
                  children: [
                    // الوصف (361×66)
                    Text(
                      'يساعدك لبيك على معرفة موقعك، الوصول إلى فندقك ومجموعتك، واستخدام الخريطة والمساعدة عند الحاجة.',
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
                      label: 'تفعيل الموقع',
                      onPressed: () => _goNext(context, enable: true),
                    ),
                    const SizedBox(height: 26),
                    PrimaryButton(
                      label: 'لاحقًا',
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
