import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// -------------------------------------------------------------
// FeatureCard — كرت الميزة بشبكة الرئيسية (Figma: 172×73)
// الخلفية: #E9F2EF — radius 10 — حد علوي 1 أسود 10% (Inside)
// ظل (0,4) blur 4 بلون #1F3B2E بشفافية 25% — وكل الطبقة شفافيتها 85%
// الدائرة: 42×42 #4C7A75 بشفافية 25% — السهم 16×16 #1F3B2E بشفافية 50%
// -------------------------------------------------------------
class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconAsset;
  final Size iconSize;
  final Color titleColor;
  final VoidCallback? onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.iconSize,
    this.titleColor = _green,
    this.onTap,
  });

  static const _green = Color(0xFF1F3B2E);
  static const _fill = Color(0xFFE9F2EF);
  static const _topStroke = Color(0x1A000000); // أسود 10%
  static const _circleFill = Color(0x404C7A75); // #4C7A75 بشفافية 25%
  static const _shadow = Color(0x401F3B2E); // #1F3B2E بشفافية 25%
  static const _radius = BorderRadius.all(Radius.circular(10));

  static const _circleStart = 11.0;
  static const _circleSize = 42.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 73,
        child: Stack(
          children: [
            // الخلفية (شفافية الطبقة 85% بتشمل التعبئة والحد والظل)
            Positioned.fill(
              child: Opacity(
                opacity: 0.85,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    borderRadius: _radius,
                    boxShadow: [BoxShadow(color: _shadow, offset: Offset(0, 4), blurRadius: 4)],
                  ),
                  child: ClipRRect(
                    borderRadius: _radius,
                    child: const Column(
                      children: [
                        SizedBox(height: 1, width: double.infinity, child: ColoredBox(color: _topStroke)),
                        Expanded(child: SizedBox(width: double.infinity, child: ColoredBox(color: _fill))),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // دائرة الأيقونة (بداية الكرت)
            PositionedDirectional(
              start: _circleStart,
              top: 15,
              child: Container(
                width: _circleSize,
                height: _circleSize,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: _circleFill, shape: BoxShape.circle),
                child: Image.asset(iconAsset, width: iconSize.width, height: iconSize.height),
              ),
            ),

            // العنوان: Regular 13 — line height 22
            PositionedDirectional(
              start: _circleStart + _circleSize + 7,
              end: 27,
              top: 18,
              height: 24,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _style(13, FontWeight.w400, titleColor),
                ),
              ),
            ),

            // الوصف: Light 11 — line height 22 (تحت مستوى السهم، فبياخد عرض الكرت)
            PositionedDirectional(
              start: _circleStart + _circleSize + 4,
              end: 8,
              top: 40,
              height: 22,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _style(11, FontWeight.w300, _green),
                ),
              ),
            ),

            // السهم (نهاية الكرت)
            PositionedDirectional(
              end: 9,
              top: 19,
              child: Image.asset('assets/images/home/ic_chevron.png', width: 16, height: 16),
            ),
          ],
        ),
      ),
    );
  }

  static TextStyle _style(double size, FontWeight weight, Color color) {
    return GoogleFonts.tajawal(
      textStyle: const TextStyle(leadingDistribution: TextLeadingDistribution.even),
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: -0.408,
      height: 22 / size,
    );
  }
}
