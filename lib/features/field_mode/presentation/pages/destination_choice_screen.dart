import 'package:flutter/material.dart';

import '../../../../core/l10n/tx.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../data/models/field_destination.dart';
import '../controllers/field_mode_controller.dart';
import '../l10n/destination_choice_text.dart';
import '../widgets/field_colors.dart';
import '../widgets/field_mode_page.dart';

// -------------------------------------------------------------
// شاشة "أين تريد التوجه الآن؟" — مطابقة لـ Figma (21:1961، عنوانها بـ Figma "الطريق إلى مكة المكرمة")
// كرتين: الفندق / المسجد الحرام — كل كرت إله زر بيوديه على "وجهتك القادمة" تبعه
// -------------------------------------------------------------
class DestinationChoiceScreen extends StatelessWidget {
  const DestinationChoiceScreen({super.key});

  static const _assets = 'assets/images/field_mode';

  @override
  Widget build(BuildContext context) {
    return FieldModePage(
      title: DestinationChoiceText.routeMeccaTitle(),
      backIconLeft: 20,
      titleRight: 380.6,
      builder: (c) => [
        // Poppins 600 14 #1F3B2E — طرفه عند x377
        c.text(DestinationChoiceText.title(), left: 265, top: 117, width: 112, height: 22, style: c.style(14, FigmaWeight.semiBold, FieldColors.green)),

        ..._card(
          c,
          context,
          destination: FieldDestination.hotel,
          card: const Rect.fromLTWH(15, 163, 361, 194),
          icon: 'ic_hotel.png',
          iconRect: const Rect.fromLTWH(304, 187, 48, 48),
          title: DestinationChoiceText.hotel,
          titleRect: const Rect.fromLTWH(232, 200, 54, 22),
          desc: DestinationChoiceText.hotelChoiceDesc,
          descRect: const Rect.fromLTWH(74, 230, 212, 22),
          button: DestinationChoiceText.goToHotel,
          buttonRect: const Rect.fromLTWH(104, 284, 183, 41),
          buttonText: const Rect.fromLTWH(139, 294, 110, 21),
        ),
        ..._card(
          c,
          context,
          destination: FieldDestination.haram,
          card: const Rect.fromLTWH(15, 381, 361, 193),
          icon: 'ic_haram.png',
          iconRect: const Rect.fromLTWH(306, 405, 46, 46),
          title: DestinationChoiceText.haram,
          titleRect: const Rect.fromLTWH(175, 417, 114, 22),
          desc: DestinationChoiceText.haramChoiceDesc,
          descRect: const Rect.fromLTWH(149, 447, 138, 22),
          button: DestinationChoiceText.goToHaram,
          buttonRect: const Rect.fromLTWH(104, 501, 183, 41),
          buttonText: const Rect.fromLTWH(121, 511, 155, 21),
        ),
      ],
    );
  }

  // كرت: #4C7A75 10% — radius 10 — ظل | العنوان SF Compact 556 20 | الوصف SF Compact 457 14
  // الزر: 183×41 #1F3B2E radius 10 — Poppins 700 14 أبيض (line height auto) — النص بنص صندوقه بـ Figma
  List<Widget> _card(
    FigmaCanvas c,
    BuildContext context, {
    required FieldDestination destination,
    required Rect card,
    required String icon,
    required Rect iconRect,
    required Tx title,
    required Rect titleRect,
    required Tx desc,
    required Rect descRect,
    required Tx button,
    required Rect buttonRect,
    required Rect buttonText,
  }) {
    Widget text(Tx value, Rect r, TextStyle style, {TextAlign align = TextAlign.start, double dy = FigmaCanvas.baselineFix}) =>
        c.text(value(), left: r.left, top: r.top, width: r.width, height: r.height, style: style, align: align, dy: dy);

    return [
      c.box(left: card.left, top: card.top, width: card.width, height: card.height, color: FieldColors.cardFill, radius: 10, hasShadow: true),
      c.image('$_assets/$icon', left: iconRect.left, top: iconRect.top, width: iconRect.width, height: iconRect.height),
      text(title, titleRect, c.style(20, FigmaWeight.semiBold, FieldColors.green)),
      text(desc, descRect, c.style(14, FigmaWeight.sfRegular, FieldColors.green)),
      c.box(left: buttonRect.left, top: buttonRect.top, width: buttonRect.width, height: buttonRect.height, color: FieldColors.green, radius: 10),
      text(button, buttonText, c.style(14, FigmaWeight.poppinsBold, Colors.white, lineHeight: null, letterSpacing: 0), align: TextAlign.center, dy: 0),
      c.tapArea(
        left: buttonRect.left,
        top: buttonRect.top,
        width: buttonRect.width,
        height: buttonRect.height,
        onTap: () => FieldModeController.chooseDestination(context, destination),
      ),
    ];
  }
}
