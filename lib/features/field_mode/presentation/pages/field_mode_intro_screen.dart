import 'package:flutter/material.dart';

import '../../../../core/l10n/tx.dart';
import '../../../../core/theme/figma_text.dart';
import '../controllers/field_mode_controller.dart';
import '../l10n/field_intro_text.dart';
import '../widgets/field_colors.dart';
import '../widgets/field_mode_page.dart';

// -------------------------------------------------------------
// شاشة "تهيئة وضع الميدان" — مطابقة لـ Figma (21:823، 393×852)
// كل الأرقام أرقام Figma (شوف FigmaCanvas) — الخطوط Noto Sans Arabic بأوزان FigmaWeight
// -------------------------------------------------------------
class FieldModeIntroScreen extends StatelessWidget {
  const FieldModeIntroScreen({super.key});

  static const _assets = 'assets/images/field_mode';

  @override
  Widget build(BuildContext context) {
    return FieldModePage(
      title: FieldIntroText.title(),
      builder: (c) {
        final itemTitle = c.style(16, FigmaWeight.poppinsMedium, FieldColors.green);
        final itemDesc = c.style(14, FigmaWeight.poppinsRegular, FieldColors.accent);

        // بند: أيقونة 24 عند x337 — العنوان طرفه عند x329 — الوصف طرفه عند x361 تحته بـ 32
        List<Widget> item(String icon, Tx title, Tx desc, double top) => [
          c.image('$_assets/$icon', left: 337, top: top, width: 24, height: 24),
          c.text(title(), left: 129, top: top, width: 200, height: 22, style: itemTitle),
          c.text(desc(), left: 61, top: top + 32, width: 300, height: 22, style: itemDesc),
        ];

        return [
          // الرسمة: 291×177 عند x51 y117 — radius 19
          c.image('$_assets/illustration.png', left: 51, top: 117, width: 291, height: 177, radius: 19),

          // الوصف: SF Compact 556 18 بالنص (361×44 عند x16 y310) — نفس كسر السطر تبع Figma
          c.text(
            FieldIntroText.body(),
            left: 16,
            top: 310,
            width: 361,
            height: 44,
            align: TextAlign.center,
            dy: 0,
            style: c.style(18, FigmaWeight.semiBold, FieldColors.green),
          ),

          // الكرت: 360×293 عند x17 y378 — radius 10 — ظل
          c.box(left: 17, top: 378, width: 360, height: 293, color: FieldColors.cardFill, radius: 10, hasShadow: true),

          // عنوان الكرت: 216×38 عند x145 y394 — Poppins 500 16 أبيض بالنص
          c.box(left: 145, top: 394, width: 216, height: 38, color: FieldColors.green, radius: 10),
          c.text(
            FieldIntroText.cardTitle(),
            left: 145,
            top: 402,
            width: 216,
            height: 22,
            align: TextAlign.center,
            style: c.style(16, FigmaWeight.poppinsMedium, Colors.white),
          ),

          ...item('ic_location.png', FieldIntroText.locationTitle, FieldIntroText.locationDesc, 451),
          ...item('ic_steps.png', FieldIntroText.stepsTitle, FieldIntroText.stepsDesc, 517),
          ...item('ic_rounds.png', FieldIntroText.roundsTitle, FieldIntroText.roundsDesc, 579),

          // الزر: 361×50 عند x17 y703
          c.button(FieldIntroText.button(), left: 17, top: 703, onTap: () => FieldModeController.start(context)),

          // الملاحظة: Poppins 500 14 #4C7A75 بالنص — صندوقها x57..338
          c.text(
            FieldIntroText.note(),
            left: 57,
            top: 769,
            width: 281,
            height: 22,
            align: TextAlign.center,
            style: c.style(14, FigmaWeight.poppinsMedium, FieldColors.accent),
          ),
        ];
      },
    );
  }
}
