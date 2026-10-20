import 'package:flutter/material.dart';

import '../../../../core/l10n/tx.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../data/models/field_destination.dart';
import '../controllers/field_mode_controller.dart';
import '../l10n/next_destination_text.dart';
import '../widgets/field_colors.dart';
import '../widgets/field_mode_page.dart';
import '../widgets/route_path.dart';

// -------------------------------------------------------------
// شاشة "وجهتك القادمة" — مطابقة لـ Figma، نفس التصميم لكل وجهة مع فروقات صغيرة:
//   الميقات 21:1080 ("حان وقت الاستعداد للإحرام") — مكة 21:1156 — الفندق 21:1232 — المسجد الحرام 21:1306
// كل الأرقام أرقام Figma — الفروقات بين الشاشات بـ _DestinationSpec تحت
// -------------------------------------------------------------
class NextDestinationScreen extends StatelessWidget {
  final FieldDestination destination;

  const NextDestinationScreen({super.key, required this.destination});

  static const _assets = 'assets/images/field_mode';

  // أطراف سطور المعلومات (يمين) بالكرت — نفسها بكل الشاشات
  static const _arrivalRight = 317.0;
  static const _distanceRight = 321.0;
  static const _timeRight = 319.0;

  @override
  Widget build(BuildContext context) {
    final spec = _DestinationSpec.of(destination);

    return FieldModePage(
      title: spec.title(),
      backIconLeft: spec.backIconLeft,
      titleRight: spec.titleRight,
      builder: (c) {
        final bold = c.style(16, FigmaWeight.sfBold, FieldColors.green);
        final medium = c.style(16, FigmaWeight.semiBold, FieldColors.green);
        final small = c.style(14, FigmaWeight.sfRegular, FieldColors.green);

        // سطر معلومة: العنوان SF Compact 790 والقيمة بعده — line height 22 — طرفه اليمين ثابت
        Widget infoRow(String label, String value, TextStyle valueStyle, {required double right, required double top}) {
          return c.rich(
            TextSpan(
              children: [
                TextSpan(text: label, style: bold),
                TextSpan(text: value, style: valueStyle),
              ],
            ),
            left: right - 300,
            top: top,
            width: 300,
            height: 22,
          );
        }

        return [
          // عنوان الرحلة (مستطيل #1F3B2E radius 10) — SF Compact 556 أبيض
          ..._pill(c, spec.pill, spec.pillText, spec.pillLabel(), spec.pillTextSize),

          // الوصف تحت العنوان
          c.text(
            spec.introLabel(),
            left: spec.intro.left,
            top: spec.intro.top,
            width: spec.intro.width,
            height: spec.intro.height,
            style: c.style(spec.introStyle.size, spec.introStyle.weight, spec.introStyle.color),
          ),

          // الكرت: 360×264 عند x17 y223 — radius 19 — ظل
          c.box(left: 17, top: 223, width: 360, height: 264, color: FieldColors.cardFill, radius: 19, hasShadow: true),

          // نقطة وصولك (أيقونة 28 عند x325 y247)
          c.image('$_assets/ic_pushpin.png', left: 325, top: 247, width: 28, height: 28),
          infoRow(
            NextDestinationText.arrivalPointLabel(),
            spec.arrival(),
            c.style(16, spec.arrivalWeight, FieldColors.green),
            right: _arrivalRight,
            top: 250,
          ),

          // يبعد عنك (أيقونة الموقع 16.88×24 بنص مربع 24 عند x329 y283)
          c.image('$_assets/ic_distance.png', left: 332.56, top: 283, width: 16.88, height: 24),
          infoRow(NextDestinationText.distanceLabel(), spec.distance(), medium, right: _distanceRight, top: 283),

          // الوقت المتوقع (أيقونة 24 عند x329 y315)
          c.image('$_assets/ic_time.png', left: 329, top: 315, width: 24, height: 24),
          infoRow(NextDestinationText.timeLabel(), spec.time(), medium, right: _timeRight, top: 316),

          // الوجهة (يسار) ← المسار المنقّط ← موقعك الحالي (يمين)
          c.image('$_assets/${spec.icon}', left: spec.iconRect.left, top: spec.iconRect.top, width: spec.iconRect.width, height: spec.iconRect.height),
          for (final label in spec.labels)
            c.text(
              label.text(),
              left: label.rect.left,
              top: label.rect.top,
              width: label.rect.width,
              height: label.rect.height,
              align: TextAlign.center,
              style: label.poppins ? c.style(14, FigmaWeight.poppinsRegular, FieldColors.green) : small,
            ),
          ...RoutePath.build(c),
          c.image('$_assets/ic_flag.png', left: 326, top: 402, width: 24.61, height: 28),
          c.text(NextDestinationText.currentLocation(), left: 293, top: 438, width: 76, height: 22, align: TextAlign.center, style: small),

          // ماذا ستفعل عند الوصول؟
          ..._pill(c, spec.questionPill, spec.questionText, NextDestinationText.onArrivalQuestion(), spec.pillTextSize),
          c.text(
            spec.outroLabel(),
            left: spec.outro.left,
            top: spec.outro.top,
            width: spec.outro.width,
            height: spec.outro.height,
            style: c.style(16, spec.outroStyle.weight, spec.outroStyle.color),
          ),

          // ابدأ الطريق
          c.button(NextDestinationText.startRoute(), left: 16, top: spec.buttonTop, onTap: () => FieldModeController.startRoute(context, destination)),
        ];
      },
    );
  }

  // مستطيل أخضر radius 10 والنص بنص صندوقه — SF Compact 556 أبيض
  List<Widget> _pill(FigmaCanvas c, Rect box, Rect text, String value, double size) {
    return [
      c.box(left: box.left, top: box.top, width: box.width, height: box.height, color: FieldColors.green, radius: 10),
      c.text(
        value,
        left: text.left,
        top: text.top,
        width: text.width,
        height: text.height,
        align: TextAlign.center,
        style: c.style(size, FigmaWeight.semiBold, Colors.white),
      ),
    ];
  }
}

typedef _Style = ({double size, double weight, Color color});

class _Label {
  final Tx text;
  final Rect rect;
  final bool poppins; // Poppins 400 بدل SF Compact 457

  const _Label(this.text, this.rect, {this.poppins = false});
}

// الفروقات بين شاشات "وجهتك القادمة" بـ Figma
class _DestinationSpec {
  final Tx title;
  final double backIconLeft;
  final double titleRight;
  final Tx pillLabel;
  final Rect pill;
  final Rect pillText;
  final double pillTextSize;
  final Tx introLabel;
  final Rect intro;
  final _Style introStyle;
  final Tx arrival;
  final double arrivalWeight;
  final Tx distance;
  final Tx time;
  final String icon;
  final Rect iconRect;
  final List<_Label> labels;
  final Rect questionPill;
  final Rect questionText;
  final Tx outroLabel;
  final Rect outro;
  final _Style outroStyle;
  final double buttonTop;

  const _DestinationSpec({
    this.title = NextDestinationText.title,
    this.backIconLeft = 20,
    this.titleRight = 380.6,
    required this.pillLabel,
    required this.pill,
    required this.pillText,
    this.pillTextSize = 20,
    required this.introLabel,
    this.intro = const Rect.fromLTWH(27, 163, 350, 44),
    this.introStyle = (size: 16, weight: FigmaWeight.poppinsMedium, color: FieldColors.accent),
    required this.arrival,
    this.arrivalWeight = FigmaWeight.sfRegular,
    required this.distance,
    required this.time,
    required this.icon,
    required this.iconRect,
    required this.labels,
    this.questionPill = const Rect.fromLTWH(142, 511, 235, 38),
    this.questionText = const Rect.fromLTWH(158, 519, 203, 22),
    required this.outroLabel,
    required this.outro,
    this.outroStyle = (size: 16, weight: FigmaWeight.semiBold, color: FieldColors.accent),
    this.buttonTop = 633,
  });

  static const _miqatLabels = [_Label(NextDestinationText.miqatName, Rect.fromLTWH(26, 393, 93, 22)), _Label(NextDestinationText.miqatAltName, Rect.fromLTWH(44, 415, 56, 22))];

  static _DestinationSpec of(FieldDestination destination) {
    switch (destination) {
      // 21:1080
      case FieldDestination.miqat:
        return const _DestinationSpec(
          title: NextDestinationText.prepareIhramTitle,
          backIconLeft: 16,
          titleRight: 377,
          pillLabel: NextDestinationText.tripToMiqat,
          pill: Rect.fromLTWH(226, 117, 152, 38),
          pillText: Rect.fromLTWH(242, 125, 120, 22),
          pillTextSize: 16,
          introLabel: NextDestinationText.miqatIntro,
          intro: Rect.fromLTWH(58, 163, 320, 44),
          introStyle: (size: 14, weight: FigmaWeight.semiBold, color: Colors.black),
          arrival: NextDestinationText.arrivalMiqat,
          distance: NextDestinationText.distance8km,
          time: NextDestinationText.time12min,
          icon: 'ic_miqat.png',
          iconRect: Rect.fromLTWH(58, 357, 28, 28),
          labels: _miqatLabels,
          questionPill: Rect.fromLTWH(183, 511, 194, 38),
          questionText: Rect.fromLTWH(199, 519, 162, 22),
          outroLabel: NextDestinationText.onArrivalMiqat,
          outro: Rect.fromLTWH(96, 557, 281, 44),
          outroStyle: (size: 16, weight: FigmaWeight.poppinsMedium, color: Colors.black),
        );
      // 21:1156 (نفس معلومات الميقات بالكرت حسب Figma)
      case FieldDestination.mecca:
        return const _DestinationSpec(
          pillLabel: NextDestinationText.tripToMecca,
          pill: Rect.fromLTWH(229, 116, 148, 39),
          pillText: Rect.fromLTWH(245, 125, 116, 22),
          introLabel: NextDestinationText.meccaIntro,
          arrival: NextDestinationText.arrivalMiqat,
          distance: NextDestinationText.distance8km,
          time: NextDestinationText.time12min,
          icon: 'ic_miqat.png',
          iconRect: Rect.fromLTWH(58, 357, 28, 28),
          labels: _miqatLabels,
          outroLabel: NextDestinationText.onArrivalMecca,
          outro: Rect.fromLTWH(14, 557, 361, 45),
          buttonTop: 634,
        );
      // 21:1232
      case FieldDestination.hotel:
        return const _DestinationSpec(
          pillLabel: NextDestinationText.tripToHotel,
          pill: Rect.fromLTWH(206, 117, 171, 38),
          pillText: Rect.fromLTWH(222, 125, 139, 22),
          introLabel: NextDestinationText.hotelIntro,
          arrival: NextDestinationText.arrivalHotel,
          distance: NextDestinationText.distance420km,
          time: NextDestinationText.time4h30min,
          icon: 'ic_hotel_small.png',
          iconRect: Rect.fromLTWH(53, 361, 37, 37),
          labels: [_Label(NextDestinationText.hotelName, Rect.fromLTWH(25, 403, 94, 44))],
          outroLabel: NextDestinationText.onArrivalHotel,
          outro: Rect.fromLTWH(53, 557, 324, 44),
        );
      // 21:1306 (نقطة الوصول كلها Bold حسب Figma)
      case FieldDestination.haram:
        return const _DestinationSpec(
          pillLabel: NextDestinationText.tripToHaram,
          pill: Rect.fromLTWH(147, 117, 230, 38),
          pillText: Rect.fromLTWH(163, 125, 198, 22),
          introLabel: NextDestinationText.haramIntro,
          arrival: NextDestinationText.arrivalHaram,
          arrivalWeight: FigmaWeight.sfBold,
          distance: NextDestinationText.distance420km,
          time: NextDestinationText.time4h30min,
          icon: 'ic_haram_small.png',
          iconRect: Rect.fromLTWH(48, 362, 46, 46),
          labels: [_Label(NextDestinationText.haramName, Rect.fromLTWH(36, 416, 74, 22), poppins: true)],
          outroLabel: NextDestinationText.onArrivalHaram,
          outro: Rect.fromLTWH(19, 557, 353, 44),
        );
    }
  }
}
