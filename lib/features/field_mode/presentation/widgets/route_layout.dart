import 'package:flutter/material.dart';

import '../../../../core/l10n/tx.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../l10n/route_text.dart';
import 'field_colors.dart';
import 'field_mode_page.dart';

// -------------------------------------------------------------
// تصميم شاشات "الطريق إلى ..." بـ Figma (21:1380 / 21:1499 / 21:1729 / 21:1657 / 21:1859):
// شريحتين فوق (المسافة والوقت) — مكان الخريطة — صندوق الإرشاد — سطر "تابع المسار" — زرين
// الميقات ومكة: خريطة حية بمكان صورة Figma، والحالة القريبة (21:1448 / 21:1580) بتغيّر نص الإرشاد.
// الفندق والمسجد الحرام: مكان الخريطة فاضي لحد ما تنعمل خرائطهم.
// -------------------------------------------------------------

/// ستايل نص بأرقام Figma
typedef FigmaTextStyle = ({double size, double weight, Color color});

/// بيانات الطريق الحية (من موقع المستخدم) بدل أرقام Figma الثابتة
class RouteLiveInfo {
  final String distance; // شريحة المسافة
  final String time; // شريحة الوقت
  final String step; // نص صندوق الإرشاد
  final bool near; // الحالة القريبة بـ Figma
  final String? hint; // سطر "تابع المسار ..." لو بيتغيّر (مثلاً اسم نقطة التجمع) — null = نص Figma

  const RouteLiveInfo({required this.distance, required this.time, required this.step, required this.near, this.hint});
}

/// الفروقات بين شاشات الطريق بـ Figma
class RouteSpec {
  final Tx title;
  final double backIconLeft;
  final double titleRight;

  // الشريحتين: المسافة (يمين) والوقت (يسار)
  final Rect distanceChip;
  final Rect timeChip;
  final Rect distanceIcon; // حدود أيقونة الموقع المرسومة فعلياً
  final Rect timeIcon;
  final bool largeIcons; // 28 بدل 24
  final Tx distanceLabel;
  final Rect distanceText;
  final Tx timeLabel;
  final Rect timeText;
  final FigmaTextStyle chipStyle;
  final bool chipPoppins; // نص الشريحتين Poppins 500 (الأرقام بـ Poppins)

  final Rect map;

  // صندوق الإرشاد
  final Rect stepBox;
  final bool darkStepBox; // أخضر غامق ونص أبيض (بدون ظل)
  final Rect stepText;
  // نص الإرشاد كمفاتيح ترجمة متتالية — weight = وزن مختلف لجزء من النص (null = نفس الوزن)
  final List<({Tx text, double? weight})> stepRuns;
  final bool stepTextShadow;
  // نصوص الإرشاد الحية: قبل ما نعرف موقع المستخدم — والحالة القريبة ({distance} = المسافة المتبقية)
  final Tx? stepNoDistance;
  final Tx? nearStep;
  final double nearStepBoxRadius; // Figma 21:1580: صندوق مكة بالحالة القريبة radius 19

  final Tx hintLabel;
  final Rect hint;
  final FigmaTextStyle hintStyle;

  final Tx arrivedLabel;
  final Offset arrivedButton;
  final Offset lostButton;
  final Color lostBorderColor;
  final double lostBorderWidth;

  // شاشة "الطريق إلى نقطة التجمع" (111:6809): الشريحتين radius 19 بدون ظل، صندوق الإرشاد radius 19، وأيقوناتها صور Figma
  final double chipRadius;
  final bool chipShadow;
  final double stepBoxRadius;
  final String? distanceAsset; // مسار كامل بدل أيقونة وضع الميدان
  final String? timeAsset;

  const RouteSpec({
    required this.title,
    this.backIconLeft = 20,
    this.titleRight = 380.6,
    required this.distanceChip,
    required this.timeChip,
    required this.distanceIcon,
    required this.timeIcon,
    this.largeIcons = true,
    this.distanceLabel = RouteText.chip8km,
    required this.distanceText,
    this.timeLabel = RouteText.chip12min,
    required this.timeText,
    this.chipStyle = (size: 16, weight: FigmaWeight.semiBold, color: FieldColors.green),
    this.chipPoppins = false,
    this.map = const Rect.fromLTWH(16, 177, 361, 389),
    this.stepBox = const Rect.fromLTWH(16, 582, 361, 59),
    this.darkStepBox = false,
    required this.stepText,
    required this.stepRuns,
    this.stepTextShadow = false,
    this.stepNoDistance,
    this.nearStep,
    this.nearStepBoxRadius = 10,
    required this.hintLabel,
    required this.hint,
    this.hintStyle = (size: 16, weight: FigmaWeight.semiBold, color: FieldColors.accent),
    required this.arrivedLabel,
    this.arrivedButton = const Offset(17, 703),
    this.lostButton = const Offset(15, 769),
    this.lostBorderColor = FieldColors.green,
    this.lostBorderWidth = 1,
    this.chipRadius = 10,
    this.chipShadow = true,
    this.stepBoxRadius = 10,
    this.distanceAsset,
    this.timeAsset,
  });
}

class RouteLayout extends StatelessWidget {
  final RouteSpec spec;
  final VoidCallback onArrived;
  final VoidCallback onLost;
  final RouteLiveInfo? live; // null = نصوص Figma الثابتة
  final Widget? map; // null = مكان الخريطة فاضي

  const RouteLayout({super.key, required this.spec, required this.onArrived, required this.onLost, this.live, this.map});

  static const _assets = 'assets/images/field_mode';

  @override
  Widget build(BuildContext context) {
    return FieldModePage(
      title: spec.title(),
      backIconLeft: spec.backIconLeft,
      titleRight: spec.titleRight,
      builder: (c) => content(c, spec: spec, onArrived: onArrived, onLost: onLost, live: live, map: map),
    );
  }

  /// محتوى الشاشة تحت الهيدر (بيتعاد استعماله بهيدر تاني — مثل "الطريق إلى نقطة التجمع" بـ FigmaPage)
  static List<Widget> content(FigmaCanvas c, {required RouteSpec spec, required VoidCallback onArrived, required VoidCallback onLost, RouteLiveInfo? live, Widget? map}) {
    final chip = c.style(spec.chipStyle.size, spec.chipStyle.weight, spec.chipStyle.color);
    final chipDy = spec.chipPoppins ? 0.5 : FigmaCanvas.baselineFix;
    final stepColor = spec.darkStepBox ? Colors.white : FieldColors.green;
    // نص الإرشاد: SF Compact 556 14 — letter spacing 0 — وبشاشة الميقات عليه ظل (0,4) blur 4
    final stepStyle = c
        .style(14, FigmaWeight.semiBold, stepColor, letterSpacing: 0)
        .copyWith(
          shadows: spec.stepTextShadow ? [Shadow(color: const Color(0x40000000), offset: Offset(0, c.s.y(4)), blurRadius: c.s.x(2.6))] : null,
        );

    Widget rectBox(Rect r, {Color? color, bool shadow = false, double radius = 10}) =>
        c.box(left: r.left, top: r.top, width: r.width, height: r.height, color: color ?? FieldColors.cardFill, radius: radius, hasShadow: shadow);

    // نص الإرشاد: الحي (سطر واحد بنفس ستايل Figma) أو أجزاء Figma الثابتة
    final List<({String text, double? weight})> stepRuns = live == null ? [for (final run in spec.stepRuns) (text: run.text(), weight: run.weight)] : [(text: live.step, weight: null)];
    final stepRadius = live?.near == true ? spec.nearStepBoxRadius : spec.stepBoxRadius;

    Widget icon(String name, Rect r) => c.image(name.contains('/') ? name : '$_assets/$name', left: r.left, top: r.top, width: r.width, height: r.height);

    Widget text(String value, Rect r, TextStyle style, {TextAlign align = TextAlign.start, bool poppinsLatin = false, double dy = FigmaCanvas.baselineFix}) =>
        c.text(value, left: r.left, top: r.top, width: r.width, height: r.height, style: style, align: align, poppinsLatin: poppinsLatin, dy: dy);

    return [
      // الشريحتين: #4C7A75 10% — radius 10 — ظل
      rectBox(spec.distanceChip, shadow: spec.chipShadow, radius: spec.chipRadius),
      rectBox(spec.timeChip, shadow: spec.chipShadow, radius: spec.chipRadius),
      icon(spec.distanceAsset ?? (spec.largeIcons ? 'ic_distance_large.png' : 'ic_distance.png'), spec.distanceIcon),
      // نص الشريحتين مع أرقام Poppins بيترسم أوطى شوي (مقاس بالمقارنة) فالتصحيح أقل

      text(live?.distance ?? spec.distanceLabel(), spec.distanceText, chip, poppinsLatin: spec.chipPoppins, dy: chipDy),
      icon(spec.timeAsset ?? (spec.largeIcons ? 'ic_time_large.png' : 'ic_time.png'), spec.timeIcon),
      text(live?.time ?? spec.timeLabel(), spec.timeText, chip, poppinsLatin: spec.chipPoppins, dy: chipDy),

      // الخريطة بمكان صورة Figma (أو فاضي للشاشات اللي لسا ما إلها خريطة)
      c.rect(left: spec.map.left, top: spec.map.top, width: spec.map.width, height: spec.map.height, child: map ?? const SizedBox.expand()),

      // صندوق الإرشاد
      spec.darkStepBox ? rectBox(spec.stepBox, color: FieldColors.green, radius: stepRadius) : rectBox(spec.stepBox, shadow: true, radius: stepRadius),
      c.rich(
        TextSpan(
          children: [
            for (final run in stepRuns)
              TextSpan(
                text: run.text,
                style: run.weight == null ? stepStyle : stepStyle.copyWith(fontVariations: [FontVariation('wght', run.weight!)]),
              ),
          ],
        ),
        left: spec.stepText.left,
        top: spec.stepText.top,
        width: spec.stepText.width,
        height: spec.stepText.height,
        align: TextAlign.center,
      ),

      // تابع المسار الحالي ...
      text(live?.hint ?? spec.hintLabel(), spec.hint, c.style(spec.hintStyle.size, spec.hintStyle.weight, spec.hintStyle.color), align: TextAlign.center),

      // وصلت إلى ... / انا ضائع
      c.button(spec.arrivedLabel(), left: spec.arrivedButton.dx, top: spec.arrivedButton.dy, onTap: onArrived),
      c.button(RouteText.lost(), left: spec.lostButton.dx, top: spec.lostButton.dy, outlined: true, borderColor: spec.lostBorderColor, borderWidth: spec.lostBorderWidth, onTap: onLost),
    ];
  }
}
