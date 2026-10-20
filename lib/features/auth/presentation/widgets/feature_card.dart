import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';

// -------------------------------------------------------------
// مواقع عناصر الكرت (من حواف الكرت، أرقام Figma) — بتختلف شوي من كرت لكرت
// start = من جهة البداية (يمين بالعربي) — end = من جهة النهاية (يسار)
// -------------------------------------------------------------
class FeatureCardLayout {
  final double circleStart;
  final double circleTop;
  final double iconDx; // إزاحة الأيقونة أفقياً عن مركز الدائرة (يمين = موجب)
  final double titleStart;
  final double subtitleStart;
  final double subtitleTop;
  final double chevronEnd;
  final double chevronTop;

  const FeatureCardLayout({
    required this.circleStart,
    required this.circleTop,
    this.iconDx = 0,
    required this.titleStart,
    required this.subtitleStart,
    required this.subtitleTop,
    required this.chevronEnd,
    required this.chevronTop,
  });
}

// -------------------------------------------------------------
// FeatureCard — كرت الميزة بشبكة الرئيسية (Figma: 172×73)
// الخلفية: #E9F2EF — radius 10 — حد علوي 1 أسود 10% (Inside)
// ظل (0,4) blur 4 بلون #1F3B2E بشفافية 25% — وكل الطبقة شفافيتها 85%
// الدائرة: 42×42 #4C7A75 بشفافية 25% — السهم 16×16 #1F3B2E بشفافية 50%
// كل الأرقام أرقام Figma وبتتحجّم لشاشة الجهاز عن طريق scale
// -------------------------------------------------------------
class FeatureCard extends StatelessWidget {
  final DesignScale scale;
  final String title;
  final String subtitle;
  final String iconAsset;
  final Size iconSize;
  final Color titleColor;
  final FeatureCardLayout layout;
  final VoidCallback? onTap;

  const FeatureCard({
    super.key,
    required this.scale,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.iconSize,
    required this.layout,
    this.titleColor = _green,
    this.onTap,
  });

  static const _green = Color(0xFF1F3B2E);
  static const _fill = Color(0xFFE9F2EF);
  static const _topStroke = Color(0x1A000000); // أسود 10%
  static const _circleFill = Color(0x404C7A75); // #4C7A75 بشفافية 25%
  static const _shadow = Color(0x401F3B2E); // #1F3B2E بشفافية 25%
  static const _circleSize = 42.0;
  static const _chevronSize = 16.0;

  // Figma بيرسم العنوان والوصف أوطى بحوالي 1.2 من صناديقهم (مقاس بالمقارنة)
  static const _baselineFix = 1.2;
  static const _titleTop = 18.0 + _baselineFix; // صندوق العنوان بـ Figma: top 18 ارتفاع 24

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final l = layout;
    final radius = BorderRadius.circular(s.x(10));
    final subtitleTop = l.subtitleTop + _baselineFix;
    // إذا الوصف بنفس مستوى السهم (كرت "أدعية") بيوقف قبل السهم وبيصغر شوي
    // (Flutter ما بيطبّق letter spacing على العربي فالنص أعرض من Figma بـ 0.408 لكل حرف)
    final overlapsChevron = subtitleTop < l.chevronTop + _chevronSize;
    final subtitleEnd = overlapsChevron ? l.chevronEnd + _chevronSize + 2 : 4.0;
    // العناصر المربعة: حجمها بيتحجّم أفقياً ومركزها بنفس مكانه النسبي عمودياً
    double centeredTop(double top, double size) => s.y(top + size / 2) - s.x(size / 2);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: s.y(73),
        child: Stack(
          children: [
            // الخلفية (شفافية الطبقة 85% بتشمل التعبئة والحد والظل)
            Positioned.fill(
              child: Opacity(
                opacity: 0.85,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    // blur 4 بـ Figma = sigma 2 → blurRadius 2.6 بـ Flutter
                    boxShadow: [BoxShadow(color: _shadow, offset: Offset(0, s.y(4)), blurRadius: s.x(2.6))],
                  ),
                  child: ClipRRect(
                    borderRadius: radius,
                    child: Column(
                      children: [
                        SizedBox(height: s.y(1), width: double.infinity, child: const ColoredBox(color: _topStroke)),
                        const Expanded(child: SizedBox(width: double.infinity, child: ColoredBox(color: _fill))),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // دائرة الأيقونة (بداية الكرت)
            PositionedDirectional(
              start: s.x(l.circleStart),
              top: centeredTop(l.circleTop, _circleSize),
              child: Container(
                width: s.x(_circleSize),
                height: s.x(_circleSize),
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: _circleFill, shape: BoxShape.circle),
                child: Transform.translate(
                  offset: Offset(s.x(l.iconDx), 0),
                  child: Image.asset(iconAsset, width: s.x(iconSize.width), height: s.x(iconSize.height)),
                ),
              ),
            ),

            // العنوان: Regular 13 — line height 22
            PositionedDirectional(
              start: s.x(l.titleStart),
              end: s.x(l.chevronEnd + _chevronSize + 2),
              top: s.y(_titleTop),
              height: s.y(24),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                // بيصغر بس إذا ما وسع (مثلاً "Smart Assistant" بالإنجليزي)
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: _style(13, FigmaWeight.poppinsRegular, titleColor),
                  ),
                ),
              ),
            ),

            // الوصف: Light 11 — line height 22
            PositionedDirectional(
              start: s.x(l.subtitleStart),
              end: s.x(subtitleEnd),
              top: s.y(subtitleTop),
              height: s.y(22),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    style: _style(11, FigmaWeight.poppinsLight, _green),
                  ),
                ),
              ),
            ),

            // السهم (نهاية الكرت)
            PositionedDirectional(
              end: s.x(l.chevronEnd),
              top: centeredTop(l.chevronTop, _chevronSize),
              // السهم "<" بالعربي — بالإنجليزي بينقلب ">" (لأنه بنهاية الكرت يمين)
              child: Transform.flip(
                flipX: Directionality.of(context) == TextDirection.ltr,
                child: Image.asset(
                  'assets/images/home/ic_chevron.png',
                  width: s.x(_chevronSize),
                  height: s.x(_chevronSize),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Noto Sans Arabic بأوزان FigmaWeight (شوف core/theme/figma_text.dart)
  TextStyle _style(double size, double weight, Color color) {
    return figmaText(scale, size: size, weight: weight, color: color);
  }
}
