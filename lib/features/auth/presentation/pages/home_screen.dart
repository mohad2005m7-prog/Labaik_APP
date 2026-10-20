import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../assistant/presentation/controllers/assistant_controller.dart';
import '../../../budget/presentation/controllers/budget_controller.dart';
import '../../../duas/presentation/controllers/duas_controller.dart';
import '../../../family/presentation/controllers/family_controller.dart';
import '../../../group/presentation/controllers/group_controller.dart';
import '../../../learning/presentation/controllers/learning_controller.dart';
import '../../../notifications/presentation/controllers/notifications_controller.dart';
import '../../../field_mode/presentation/pages/field_mode_intro_screen.dart';
import '../../../pilgrim_tabs/presentation/controllers/pilgrim_tabs_controller.dart';
import '../../../pilgrim_account/presentation/controllers/pilgrim_account_controller.dart';
import '../../../trip_details/presentation/controllers/trip_details_controller.dart';
import '../../data/auth_api_service.dart';
import '../controllers/auth_controller.dart';
import '../l10n/home_text.dart';
import '../widgets/custom_step_progress.dart';
import '../widgets/feature_card.dart';

// -------------------------------------------------------------
// شاشة الرئيسية (Home) — مطابقة لـ Figma "الرئيسية 1" (393×852)
// أول شاشة بعد تسجيل الدخول (أو بعد إنهاء سلسلة إعداد الحساب)
// كل المقاسات أرقام Figma وبتتحجّم لشاشة الجهاز عن طريق DesignScale
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

  static const _assets = 'assets/images/home';

  String? _userName;
  late DesignScale _s;

  // عدد مراحل التعلم اللي خلصها المعتمر (شريط "مرحلة الإستعدادك للعمرة" والخطوة التالية)
  var _learned = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadLearning();
    // لو كنت موافق على مشاركة موقعي مع عائلتي بيرجع يتبعت
    FamilyController.resumeLocationSharing();
    // ولو أنا بمجموعة والموقع مسموح، موقعي بيوصل لمجموعتي (تلقائي)
    GroupController.resumeLocationSharing();
  }

  Future<void> _loadLearning() async {
    final done = await LearningController.progress.completed();
    if (mounted) setState(() => _learned = done);
  }

  /// "تابع التعلم" → أول مرحلة ما خلصت — ولما يرجع للرئيسية الشريط بيتحدّث
  Future<void> _continueLearning() async {
    await LearningController.resume(context);
    await _loadLearning();
  }

  Future<void> _openSettings() async {
    await PilgrimAccountController.openSettings(context);
    final name = await PilgrimAccountController.savedName();
    if (mounted && name != null && name.isNotEmpty) setState(() => _userName = name);
  }

  Future<void> _loadCurrentUser() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) return;

    try {
      var response = await AuthApiService.getMe(token: token);
      // التوكن انتهى → بنجدده بالـ refreshToken ونعيد الطلب (المستخدم بيضل داخل حسابه)
      if (response.statusCode == 401) {
        final newToken = await AuthController.refreshAccessToken();
        if (newToken == null || newToken.isEmpty) return;
        response = await AuthApiService.getMe(token: newToken);
      }
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

  BorderRadius get _radius => BorderRadius.circular(_s.x(10));

  // ظل Figma (0,4) blur 4 أسود 25% — blur الـ Figma = sigma 2 → blurRadius 2.6 بـ Flutter
  BoxShadow get _cardShadow => BoxShadow(color: _shadow, offset: Offset(0, _s.y(4)), blurRadius: _s.x(2.6));

  // نصوص Figma (Poppins) — line height 22 و letter spacing -0.408
  // Noto Sans Arabic بأوزان FigmaWeight (شوف core/theme/figma_text.dart)
  TextStyle _text(double size, double weight, Color color) {
    return figmaText(_s, size: size, weight: weight, color: color);
  }

  // أيقونة مربعة بمكان Figma: الحجم بيتحجّم أفقياً ومركزها عمودياً
  Widget _icon(String asset, double size) {
    return SizedBox(
      width: _s.x(size),
      height: _s.y(size),
      child: Center(child: Image.asset('$_assets/$asset', width: _s.x(size), height: _s.x(size))),
    );
  }

  @override
  Widget build(BuildContext context) {
    _s = DesignScale.of(context);
    final systemBottom = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        // المحتوى بيمرّ تحت شريط التنقل الشفاف (blur)
        extendBody: true,
        body: SafeArea(
          bottom: false,
          // الصفحة بتنسحب دايماً (حتى لو المحتوى قدّ الشاشة) مع ارتداد ناعم
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            // آخر الكروت بيوقف قبل شريط التنقل بـ 24 (زي Figma)
            padding: EdgeInsets.only(top: _s.y(8), bottom: _s.y(49) + systemBottom + _s.y(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                SizedBox(height: _s.y(30)),
                _buildHeroCard(),
                SizedBox(height: _s.y(24)),
                _buildReadinessCard(),
                SizedBox(height: _s.y(24)),
                _buildFeatureGrid(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildTabBar(systemBottom),
      ),
    );
  }

  // ---------------------------------------------------------
  // الهيدر: القائمة (يمين) + الترحيب + الجرس (يسار) — أيقونات 24×24
  // ---------------------------------------------------------
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _s.x(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // القائمة → إعدادات المعتمر (ولما يرجع: الاسم اللي عدّله بيبيّن بالترحيب)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _openSettings,
            child: _icon('ic_menu.png', 24),
          ),
          SizedBox(width: _s.x(8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SF Compact Bold (790) 20 — line height auto → FigmaWeight.sfBold
                // Figma بيرسمه أوطى بـ 1 (مقاس بالمقارنة) → translate
                SizedBox(
                  height: _s.y(24),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Transform.translate(
                      offset: Offset(0, _s.y(1)),
                      child: Text(
                        _userName != null ? HomeText.greetingName(_userName!) : HomeText.greeting(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: figmaText(_s, size: 20, weight: FigmaWeight.sfBold, color: _green, lineHeight: null, letterSpacing: 0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: _s.y(8)),
                SizedBox(
                  height: _s.y(22),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(HomeText.welcome(), style: _text(15, FigmaWeight.poppinsRegular, _green)),
                  ),
                ),
              ],
            ),
          ),
          // الجرس → الإشعارات (Figma 114:10192 — من السيرفر)
          GestureDetector(
            onTap: () => NotificationsController.open(context),
            child: _icon('ic_bell.png', 24),
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
      padding: EdgeInsets.only(left: _s.x(16), right: _s.x(15)),
      child: DecoratedBox(
        decoration: BoxDecoration(borderRadius: _radius, boxShadow: [_cardShadow]),
        child: ClipRRect(
          borderRadius: _radius,
          child: SizedBox(
            height: _s.y(248),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('$_assets/hero.jpg', fit: BoxFit.cover),
                Positioned(
                  left: _s.x(1),
                  right: 0,
                  bottom: 0,
                  height: _s.y(42),
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _s.y(1),
            child: const ColoredBox(color: _topStroke),
          ),
          // الأيقونة بـ Figma top 9 من 42 = بالنص
          PositionedDirectional(
            start: _s.x(8),
            top: 0,
            bottom: 0,
            child: Center(child: Image.asset('$_assets/ic_pin.png', width: _s.x(24), height: _s.x(24))),
          ),
          // Figma بيرسمه أوطى بـ 1 من مركز الشريط (مقاس) → top/bottom +1
          PositionedDirectional(
            start: _s.x(40),
            end: _s.x(14 + 102 + 8),
            top: _s.y(1),
            bottom: _s.y(-1),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                HomeText.readyQuestion(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _text(14, FigmaWeight.poppinsBold, _heroQuestion),
              ),
            ),
          ),
          PositionedDirectional(
            end: _s.x(14),
            top: _s.y(8),
            child: _pillButton(
              label: HomeText.fieldMode(),
              width: 102,
              height: 26,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FieldModeIntroScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // زر أخضر صغير: radius 10 — نص Medium 12 أبيض (width/height أرقام Figma)
  Widget _pillButton({
    required String label,
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _s.x(width),
        height: _s.y(height),
        decoration: BoxDecoration(color: _green, borderRadius: _radius),
        child: OverflowBox(
          maxHeight: _s.y(30),
          child: Center(
            // بيصغر بس إذا النص ما وسع الزر (مثلاً بالإنجليزي)
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: _text(12, FigmaWeight.poppinsMedium, Colors.white),
              ),
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
      padding: EdgeInsets.only(left: _s.x(16), right: _s.x(15)),
      child: Container(
        height: _s.y(135),
        decoration: BoxDecoration(color: _cardFill, borderRadius: _radius, boxShadow: [_cardShadow]),
        child: Stack(
          children: [
            // SemiBold 16 — صندوق Figma top 11، والنص بيترسم أوطى بـ 1 (مقاس مع رندر Figma)
            PositionedDirectional(
              start: _s.x(9),
              end: _s.x(9),
              top: _s.y(11 + 1),
              height: _s.y(22),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(HomeText.stageTitle(), style: _text(16, FigmaWeight.semiBold, _green)),
              ),
            ),
            // 4 خطوط (مرحلة لكل خط): سمك 7، طول 77، مسافة 6 — بـ Figma مرسومة من y465 لـ 472
            // المليان = المراحل اللي خلصها المعتمر (LearningController — محفوظ لكل حساب)
            PositionedDirectional(
              start: _s.x(15),
              end: _s.x(21),
              top: _s.y(42),
              child: CustomStepProgress(
                currentStep: _learned,
                totalSteps: 4,
                thickness: _s.y(7),
                spacing: _s.x(6),
              ),
            ),
            PositionedDirectional(
              start: _s.x(1),
              end: _s.x(2),
              top: _s.y(57 + 1), // صندوق Figma top 57 + تصحيح 1 (مقاس مع رندر Figma)
              height: _s.y(22),
              // بيصغر بس إذا ما وسع النص
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  HomeText.stageDescription(),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: _text(16, FigmaWeight.poppinsRegular, _green),
                ),
              ),
            ),
            PositionedDirectional(
              start: _s.x(13),
              end: _s.x(14 + 83 + 8),
              top: _s.y(95),
              height: _s.y(22),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                // بيصغر بس إذا ما وسع النص (مثلاً بالإنجليزي)
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    HomeText.nextStep(_learned),
                    maxLines: 1,
                    style: _text(15, FigmaWeight.poppinsLight, _green),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              end: _s.x(14),
              top: _s.y(97),
              child: _pillButton(
                label: HomeText.continueLearning(),
                width: 83,
                height: 21,
                onTap: _continueLearning,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // شبكة الميزات 2×2 — كل كرت 172×73، مسافة أفقية 13 وعمودية 16
  // مواقع العناصر جوّا كل كرت منقولة من Figma كرت كرت (مش موحّدة بالتصميم)
  // ---------------------------------------------------------
  Widget _buildFeatureGrid() {
    // ملاحظة: لون عنوان "الميزانية" بـ Figma #1F3B2E والباقي #000000
    const black = Color(0xFF000000);
    final assistant = FeatureCard(
      scale: _s,
      title: HomeText.assistant(),
      subtitle: HomeText.assistantSub(),
      iconAsset: '$_assets/ic_assistant.png',
      iconSize: const Size(28, 30),
      titleColor: black,
      layout: const FeatureCardLayout(
        circleStart: 8, circleTop: 16, titleStart: 56,
        subtitleStart: 50, subtitleTop: 40, chevronEnd: 11, chevronTop: 27,
      ),
      onTap: () => AssistantController.open(context),
    );
    final budget = FeatureCard(
      scale: _s,
      title: HomeText.budget(),
      subtitle: HomeText.budgetSub(),
      iconAsset: '$_assets/ic_budget.png',
      iconSize: const Size(28, 20.33),
      layout: const FeatureCardLayout(
        circleStart: 11, circleTop: 15, titleStart: 60,
        subtitleStart: 57, subtitleTop: 40, chevronEnd: 9, chevronTop: 19,
      ),
      onTap: () => BudgetController.open(context),
    );
    final duas = FeatureCard(
      scale: _s,
      title: HomeText.duas(),
      subtitle: HomeText.duasSub(),
      iconAsset: '$_assets/ic_duas.png',
      iconSize: const Size(28, 28),
      titleColor: black,
      layout: const FeatureCardLayout(
        circleStart: 10, circleTop: 15, iconDx: 1, titleStart: 61,
        subtitleStart: 53, subtitleTop: 37, chevronEnd: 11, chevronTop: 28,
      ),
      onTap: () => DuasController.open(context),
    );
    final tripDetails = FeatureCard(
      scale: _s,
      title: HomeText.tripDetails(),
      subtitle: HomeText.tripDetailsSub(),
      iconAsset: '$_assets/ic_trip_details.png',
      iconSize: const Size(28, 28),
      titleColor: black,
      layout: const FeatureCardLayout(
        circleStart: 10, circleTop: 15, titleStart: 63,
        subtitleStart: 52, subtitleTop: 40, chevronEnd: 4, chevronTop: 19,
      ),
      onTap: () => TripDetailsController.open(context),
    );

    return Padding(
      padding: EdgeInsets.only(left: _s.x(19), right: _s.x(17)),
      child: Column(
        children: [
          // كرت "الميزانية" بـ Figma أوطى بـ 1 من "المساعد الذكي" (583 مقابل 582)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: assistant),
              SizedBox(width: _s.x(13)),
              Expanded(child: Padding(padding: EdgeInsets.only(top: _s.y(1)), child: budget)),
            ],
          ),
          // الصف الأول 582→656 (مع إزاحة الميزانية) والصف الثاني من 672
          SizedBox(height: _s.y(16)),
          Row(children: [Expanded(child: duas), SizedBox(width: _s.x(13)), Expanded(child: tripDetails)]),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // شريط التنقل السفلي (TabBar 395×49):
  // #F9F9F9 بشفافية 94% + background blur 20 + خط علوي (0,-0.5) أسود 30%
  // ---------------------------------------------------------
  Widget _buildTabBar(double systemBottom) {
    // SF Compact Light (350) → FigmaWeight.sfLight — Medium (556) → FigmaWeight.semiBold
    final items = [
      _NavItemData(HomeText.navHome(), 'nav_home.png'),
      _NavItemData(HomeText.navChats(), 'nav_chats.png', labelWeight: FigmaWeight.semiBold),
      _NavItemData(HomeText.navPeople(), 'nav_people.png'),
      _NavItemData(HomeText.navMap(), 'nav_map.png'),
      // أيقونة المعلومات 20×20 (+ نصف سمك الخط) وأعلى بـ 0.75
      _NavItemData(HomeText.navHelp(), 'nav_info.png', iconSize: 21.5, iconTop: 5.25),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: _tabBarHairline, offset: Offset(0, _s.y(-0.5)))],
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _s.x(10), sigmaY: _s.x(10)),
              child: Container(
                height: _s.y(49),
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
        // منطقة شريط النظام تحت (خلفية الشاشة البيضاء)
        Container(height: systemBottom, color: Colors.white),
      ],
    );
  }

  Widget _buildTabItem(_NavItemData item, int index) {
    // مركز الأيقونة بمكانه النسبي بـ Figma، وحجمها بيتحجّم أفقياً
    final iconTop = _s.y(item.iconTop + item.iconSize / 2) - _s.x(item.iconSize / 2);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (index == 0) return;
        // الدردشات / الأفراد / الخريطة / مركز المساعدة (نفس ترتيب الشريط)
        PilgrimTabsController.open(context, const [PilgrimTab.home, PilgrimTab.chats, PilgrimTab.people, PilgrimTab.map, PilgrimTab.help][index]);
      },
      child: Stack(
        children: [
          Positioned(
            top: iconTop,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                '$_assets/${item.asset}',
                width: _s.x(item.iconSize),
                height: _s.x(item.iconSize),
              ),
            ),
          ),
          // SF Compact 10 — line height auto — letter spacing -0.24
          // Figma: top 34.87 — والنص بيترسم أوطى بـ 0.8 (مقاس مع رندر Figma)
          Positioned(
            top: _s.y(34.87 + 0.8),
            left: 0,
            right: 0,
            child: Text(
              item.label,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: figmaText(_s, size: 10, weight: item.labelWeight, color: _green, lineHeight: null, letterSpacing: -0.24),
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
  final double labelWeight;
  final double iconSize;
  final double iconTop;

  const _NavItemData(
    this.label,
    this.asset, {
    this.labelWeight = FigmaWeight.sfLight,
    this.iconSize = 24,
    this.iconTop = 6,
  });
}
