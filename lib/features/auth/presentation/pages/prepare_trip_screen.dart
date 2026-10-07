import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/primary_button.dart';
import '../widgets/setup_header.dart';
import 'arrival_method_screen.dart';

// -------------------------------------------------------------
// شاشة "خلّينا نجهّز رحلتك" — مطابقة لـ Figma (393×852)
// -------------------------------------------------------------
class PrepareTripScreen extends StatelessWidget {
  const PrepareTripScreen({super.key});

  static const _black = Color(0xFF000000);
  // #4C7A75 بشفافية 10% فوق الأبيض (لون صلب حتى ما يبيّن الظل من تحت الكرت)
  static const _cardFill = Color(0xFFEDF2F1);

  @override
  Widget build(BuildContext context) {
    const items = [
      '✓ تفاصيل وصولك',
      '✓ مكان إقامتك',
      '✓ إرشادات لمسار رحلتك',
      '✓ تجربة تناسب احتياجاتك',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SetupHeader(title: 'خلّينا نجهّز رحلتك'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    // الصورة (290×203)
                    Image.asset(
                      'assets/images/prepare_trip.png',
                      width: 290,
                      height: 203,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    // النص (361×44)
                    Text(
                      'سنسألك عن بعض تفاصيل رحلتك لنقدّم لك إرشادات مناسبة من لحظة وصولك وحتى أداء المناسك.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w500, color: _black, height: 1.4),
                    ),
                    const SizedBox(height: 18),
                    // (205×20)
                    Text(
                      'لن يستغرق الأمر سوى بضع دقائق.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(fontSize: 12, color: const Color(0xFF717171)),
                    ),
                    const SizedBox(height: 22),

                    // الكرت (361×216) — radius 19 — ظل (0,4) blur 4 أسود 25%
                    Container(
                      width: double.infinity,
                      height: 216,
                      padding: const EdgeInsets.fromLTRB(25, 21, 25, 22),
                      decoration: BoxDecoration(
                        color: _cardFill,
                        borderRadius: BorderRadius.circular(19),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            offset: const Offset(0, 4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                            child: Center(
                              child: Text(
                                'ما الذي سنجهزه لك؟',
                                style: GoogleFonts.tajawal(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 9),
                          for (final item in items)
                            SizedBox(
                              height: 36,
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(item, style: GoogleFonts.tajawal(fontSize: 12, color: _black)),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 33),
                    PrimaryButton(
                      label: 'لنبدأ',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ArrivalMethodScreen()),
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
}
