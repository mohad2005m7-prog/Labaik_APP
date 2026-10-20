import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/common_text.dart';
import '../../../../core/utils/app_preferences.dart';
import '../l10n/onboarding_text.dart';
import 'auth_welcome_screen.dart';

// -------------------------------------------------------------
// 2. شاشات الترحيب (Onboarding Screen)
// -------------------------------------------------------------
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // آخر صفحة: بنحفظ إنه شاف شاشات الترحيب (ما بتظهر مرة ثانية) ثم 5.SignUp/Login (فيها مفتاح اللغة)
  Future<void> _onNextPressed(int pagesCount) async {
    if (_currentIndex == pagesCount - 1) {
      await AppPreferences.setOnboardingSeen();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthWelcomeScreen()),
      );
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> pages = [
      {
        'image': 'assets/images/2.Onboarding.png',
        'title': OnboardingText.title1(),
        'desc': OnboardingText.description1(),
      },
      {
        'image': 'assets/images/3.Onboarding.png',
        'title': OnboardingText.title2(),
        'desc': OnboardingText.description2(),
      },
      {
        'image': 'assets/images/4.Onboarding.png',
        'title': OnboardingText.title3(),
        'desc': OnboardingText.description3(),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Expanded(
                        flex: 6,
                        child: SizedBox(
                          width: double.infinity,
                          child: Image.asset(
                            pages[index]['image']!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                pages[index]['title']!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.tajawal(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1C382B),
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                pages[index]['desc']!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.tajawal(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E1E1E),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? const Color(0xFF1C382B)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _onNextPressed(pages.length),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C382B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _currentIndex == pages.length - 1
                        ? OnboardingText.startJourney()
                        : CommonText.next(),
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
