import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/auth_api_service.dart';
import '../../../../core/utils/token_storage.dart';
import '../widgets/custom_step_progress.dart';
import '../widgets/feature_card.dart';

// -------------------------------------------------------------
// شاشة الرئيسية (Home) — مطابقة لـ Figma "الرئيسية 1" (393×852)
// أول شاشة بعد تسجيل الدخول (أو بعد إنهاء سلسلة إعداد الحساب)
// -------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ألوان Figma
  static const _green = Color(0xFF1F3B2E);
  static const _cardFill = Color(0xFFE9F2EF);
  static const _heroQuestion = Color(0xFF385543);
  static const _heroBarFill = Color(0xB3E9F2EF); // #E9F2EF بشفافية 70%
  static const _topStroke = Color(0x1A000000); // أسود 10%
  static const _shadow = Color(0x40000000); // أسود 25%
  static const _tabBarFill = Color(0xF0F9F9F9); // #F9F9F9 بشفافية 94%
  static const _tabBarHairline = Color(0x4D000000); // أسود 30%
  static const _radius = BorderRadius.all(Radius.circular(10));

  static const _assets = 'assets/images/home';

  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) return;

    try {
      final response = await AuthApiService.getMe(token: token);
      if (response.statusCode == 200 && mounted) {
        setState(() => _userName = _extractName(response.body));
      }
    } catch (_) {
      // بنضل على "السلام عليكم" بدون اسم
    }
  }

  String? _extractName(String body) {
    try {
      if (body.isEmpty) return null;
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;

      final json = (decoded['data'] is Map<String, dynamic>)
          ? decoded['data'] as Map<String, dynamic>
          : decoded;

      final fullName = json['fullName'] ?? json['name'] ?? json['given_name'] ?? json['userName'];
      if (fullName == null) return null;

      return fullName.toString().split(' ').first;
    } catch (_) {
      return null;
    }
  }

  // نصوص Figma (Poppins) — line height 22 و letter spacing -0.408
  static TextStyle _text(double size, FontWeight weight, Color color) {
    return GoogleFonts.tajawal(
      textStyle: const TextStyle(leadingDistribution: TextLeadingDistribution.even),
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: -0.408,
      height: 22 / size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        // المحتوى بيمرّ تحت شريط التنقل الشفاف (blur)
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: 8, bottom: MediaQuery.paddingOf(context).bottom + 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildHeroCard(),
                const SizedBox(height: 24),
                _buildReadinessCard(),
                const SizedBox(height: 24),
                _buildFeatureGrid(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildTabBar(),
      ),
    );
  }

  // ---------------------------------------------------------
  // الهيدر: القائمة (يمين) + الترحيب + الجرس (يسار) — أيقونات 24×24
  // ---------------------------------------------------------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              // TODO: القائمة الجانبية لما تنصمم
            },
            child: Image.asset('$_assets/ic_menu.png', width: 24, height: 24),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SF Compact Bold (790) 20 — line height auto
                SizedBox(
                  height: 24,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      _userName != null ? 'السلام عليكم، $_userName' : 'السلام عليكم',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _green,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 22,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text('أهلاً بك في لبيك 🤍', style: _text(15, FontWeight.w400, _green)),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: شاشة التنبيهات لما تنصمم
            },
            child: Image.asset('$_assets/ic_bell.png', width: 24, height: 24),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // بطاقة الكعبة (362×248) + شريط "هل أنت جاهز لنسكك؟" (361×42) بأسفلها
  // ---------------------------------------------------------
  Widget _buildHeroCard() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 15),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: _radius,
          boxShadow: [BoxShadow(color: _shadow, offset: Offset(0, 4), blurRadius: 4)],
        ),
        child: ClipRRect(
          borderRadius: _radius,
          child: SizedBox(
            height: 248,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('$_assets/hero.jpg', fit: BoxFit.cover),
                Positioned(
                  left: 1,
                  right: 0,
                  bottom: 0,
                  height: 42,
                  child: _buildHeroBar(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBar() {
    return ClipRRect(
      borderRadius: _radius,
      child: Stack(
        children: [
          // التعبئة 70% + حد علوي 1 أسود 10%
          const Positioned.fill(child: ColoredBox(color: _heroBarFill)),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 1,
            child: ColoredBox(color: _topStroke),
          ),
          PositionedDirectional(
            start: 8,
            top: 9,
            child: Image.asset('$_assets/ic_pin.png', width: 24, height: 24),
          ),
          PositionedDirectional(
            start: 40,
            end: 14 + 102 + 8,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'هل أنت جاهز لنسكك؟',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _text(14, FontWeight.w700, _heroQuestion),
              ),
            ),
          ),
          PositionedDirectional(
            end: 14,
            top: 8,
            child: _pillButton(
              label: 'جاهز لوضع الميدان',
              width: 102,
              height: 26,
              onTap: () {
                // TODO: يربط بشاشة "تهيئة وضع الميدان" لما نبنيها
              },
            ),
          ),
        ],
      ),
    );
  }

  // زر أخضر صغير: radius 10 — نص Medium 12 أبيض
  Widget _pillButton({
    required String label,
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(color: _green, borderRadius: _radius),
        child: OverflowBox(
          maxHeight: 30,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: _text(12, FontWeight.w500, Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // بطاقة "مرحلة الإستعدادك للعمرة" (362×135)
  // ---------------------------------------------------------
  Widget _buildReadinessCard() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 15),
      child: Container(
        height: 135,
        decoration: const BoxDecoration(
          color: _cardFill,
          borderRadius: _radius,
          boxShadow: [BoxShadow(color: _shadow, offset: Offset(0, 4), blurRadius: 4)],
        ),
        child: Stack(
          children: [
            // SemiBold 16 (Tajawal ما فيه 600 → 700)
            PositionedDirectional(
              start: 9,
              end: 9,
              top: 11,
              height: 22,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text('مرحلة الإستعدادك للعمرة', style: _text(16, FontWeight.w700, _green)),
              ),
            ),
            // 4 خطوط: سمك 7، طول 77، مسافة 6 — الأخير 50%
            // TODO: نسبة التقدم ثابتة حسب التصميم لحين ربطها بالباك إند
            const PositionedDirectional(
              start: 15,
              end: 21,
              top: 45.5,
              child: CustomStepProgress(currentStep: 3, totalSteps: 4, thickness: 7, spacing: 6),
            ),
            PositionedDirectional(
              start: 1,
              end: 2,
              top: 57,
              height: 22,
              // Tajawal أعرض بشوي من خط Figma → يصغر بس إذا ما وسع (≈99% على 393)
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'راجع أهم ما تحتاج معرفته قبل أداء العمرة، خطوة بخطوة.',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: _text(16, FontWeight.w400, _green),
                ),
              ),
            ),
            PositionedDirectional(
              start: 13,
              end: 14 + 83 + 8,
              top: 95,
              height: 22,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'الخطوة التالية : أكمل التعلم عن الطواف',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _text(15, FontWeight.w300, _green),
                ),
              ),
            ),
            PositionedDirectional(
              end: 14,
              top: 97,
              child: _pillButton(
                label: 'تابع التعلم',
                width: 83,
                height: 21,
                onTap: () {
                  // TODO: يربط بشاشة "تعلّم المناسك" لما نبنيها
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // شبكة الميزات 2×2 — كل كرت 172×73، مسافة أفقية 13 وعمودية 16
  // ---------------------------------------------------------
  Widget _buildFeatureGrid() {
    // ملاحظة: لون عنوان "الميزانية" بـ Figma #1F3B2E والباقي #000000
    const black = Color(0xFF000000);
    final assistant = FeatureCard(
      title: 'المساعد الذكي',
      subtitle: 'إجابات موثوقة لرحلتك',
      iconAsset: '$_assets/ic_assistant.png',
      iconSize: const Size(28, 30),
      titleColor: black,
      onTap: () {}, // TODO: شاشة المساعد الذكي
    );
    final budget = FeatureCard(
      title: 'الميزانية',
      subtitle: 'خطط نفقاتك بذكاء',
      iconAsset: '$_assets/ic_budget.png',
      iconSize: const Size(28, 20.33),
      onTap: () {}, // TODO: شاشة الميزانية
    );
    final duas = FeatureCard(
      title: 'أدعية',
      subtitle: 'ادعية من القران والسنة',
      iconAsset: '$_assets/ic_duas.png',
      iconSize: const Size(28, 28),
      titleColor: black,
      onTap: () {}, // TODO: شاشة الأدعية
    );
    final tripDetails = FeatureCard(
      title: 'تفاصيل الرحلة',
      subtitle: 'عدل بياناتك بحرية تامة',
      iconAsset: '$_assets/ic_trip_details.png',
      iconSize: const Size(28, 28),
      titleColor: black,
      onTap: () {}, // TODO: شاشة تفاصيل الرحلة
    );

    return Padding(
      padding: const EdgeInsets.only(left: 19, right: 17),
      child: Column(
        children: [
          Row(children: [Expanded(child: assistant), const SizedBox(width: 13), Expanded(child: budget)]),
          const SizedBox(height: 16),
          Row(children: [Expanded(child: duas), const SizedBox(width: 13), Expanded(child: tripDetails)]),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // شريط التنقل السفلي (TabBar 395×49):
  // #F9F9F9 بشفافية 94% + background blur 20 + خط علوي (0,-0.5) أسود 30%
  // ---------------------------------------------------------
  Widget _buildTabBar() {
    const items = [
      _NavItemData('الرئيسية', 'nav_home.png'),
      _NavItemData('الدردشات', 'nav_chats.png', labelWeight: FontWeight.w500),
      _NavItemData('الأفراد', 'nav_people.png'),
      _NavItemData('الخريطة', 'nav_map.png'),
      // أيقونة المعلومات 20×20 (+ نصف سمك الخط) وأعلى بـ 0.75
      _NavItemData('مركز المساعدة', 'nav_info.png', iconSize: 21.5, iconTop: 5.25),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            boxShadow: [BoxShadow(color: _tabBarHairline, offset: Offset(0, -0.5))],
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 49,
                color: _tabBarFill,
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++) Expanded(child: _buildTabItem(items[i], i)),
                  ],
                ),
              ),
            ),
          ),
        ),
        // منطقة الـ Home Indicator (خلفية الشاشة البيضاء)
        Container(height: MediaQuery.paddingOf(context).bottom, color: Colors.white),
      ],
    );
  }

  Widget _buildTabItem(_NavItemData item, int index) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (index == 0) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('قريباً'), duration: Duration(milliseconds: 900)),
        );
      },
      child: Stack(
        children: [
          Positioned(
            top: item.iconTop,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset('$_assets/${item.asset}', width: item.iconSize, height: item.iconSize),
            ),
          ),
          // SF Compact 10 — line height auto — letter spacing -0.24
          Positioned(
            top: 34.87,
            left: 0,
            right: 0,
            child: Text(
              item.label,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 10,
                fontWeight: item.labelWeight,
                color: _green,
                letterSpacing: -0.24,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final String asset;
  final FontWeight labelWeight;
  final double iconSize;
  final double iconTop;

  const _NavItemData(
    this.label,
    this.asset, {
    this.labelWeight = FontWeight.w300,
    this.iconSize = 24,
    this.iconTop = 6,
  });
}
