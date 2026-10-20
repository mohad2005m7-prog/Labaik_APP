import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../controllers/help_center_controller.dart';
import '../l10n/help_center_text.dart';
import '../widgets/help_card.dart';
import '../widgets/help_colors.dart';
import '../../../pilgrim_tabs/presentation/controllers/pilgrim_tabs_controller.dart';
import '../../../pilgrim_tabs/presentation/widgets/pilgrim_tab_bar.dart';
import '../widgets/help_text.dart';

// -------------------------------------------------------------
// "مركز المساعدة" (Figma 112:3793) — تبويب بشريط التنقل:
// كيف بنقدر نساعدك؟ + 5 كروت (أرقامها من Figma نفسه) + شريط التنقل ("مركز المساعدة" مختار)
// -------------------------------------------------------------
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _icons = 'assets/images/help';

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    final c = FigmaCanvas(s);
    TextStyle style(double size, double weight, Color color) => c.style(size, weight, color);
    final title = style(14, FigmaWeight.semiBold, HelpColors.green);
    final sub = style(12, FigmaWeight.sfRegular, HelpColors.green);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: s.y(DesignScale.designSafeHeight),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // "Frame 17": العنوان (SF Compact 790 20 #1F3B2E) — والشرح (SF Compact 556 14 أسود)
                c.text(HelpCenterText.title(), left: 40.5, top: 58, width: 336, height: 29, dy: 0, style: c.style(19.8, FigmaWeight.sfBold, HelpColors.green, lineHeight: null, letterSpacing: 0)),
                HelpText.line(c, HelpCenterText.subtitle(), right: 377, top: 104, boxWidth: 226, room: 361, style: style(14, FigmaWeight.semiBold, Colors.black)),

                // تائه ؟ تواصل مع مشرفك (Poppins 600 14 / Poppins 400 12)
                ...HelpCard.build(
                  c,
                  card: const Rect.fromLTWH(16, 142, 361, 68),
                  icon: '$_icons/ic_phone.png',
                  iconBox: const Rect.fromLTWH(337, 164, 24, 24),
                  title: (text: HelpCenterText.lostTitle(), right: 328, top: 154, width: 135, style: title),
                  subtitle: (text: HelpCenterText.lostSub(), right: 328, top: 184, width: 165, style: style(12, FigmaWeight.poppinsRegular, HelpColors.green)),
                  textRoom: 270,
                  chevronTop: 167.5,
                  onTap: () => HelpCenterController.toQuickContact(context),
                ),

                // رجّعني للفندق ("Frame 2147227385" عمودي بفراغ 8)
                ...HelpCard.build(
                  c,
                  card: const Rect.fromLTWH(205, 234, 172, 68),
                  icon: '$_icons/ic_hotel.png',
                  iconBox: const Rect.fromLTWH(330, 244, 24, 24),
                  title: (text: HelpCenterText.hotelTitle(), right: 323, top: 242, width: 77, style: title),
                  subtitle: (text: HelpCenterText.hotelSub(), right: 323, top: 271, width: 75, style: sub),
                  textRoom: 110,
                  onTap: () => HelpCenterController.toHotel(context),
                ),

                // رؤية العائلة
                ...HelpCard.build(
                  c,
                  card: const Rect.fromLTWH(16, 234, 173, 68),
                  icon: '$_icons/ic_family.png',
                  iconBox: const Rect.fromLTWH(140, 247, 24, 18),
                  title: (text: HelpCenterText.familyTitle(), right: 128, top: 242, width: 59, style: title),
                  subtitle: (text: HelpCenterText.familySub(), right: 166, top: 272, width: 107, style: sub),
                  textRoom: 107,
                  onTap: () => HelpCenterController.toFamily(context),
                ),

                // الإبلاغ عن طفل مفقود
                ...HelpCard.build(
                  c,
                  card: const Rect.fromLTWH(16, 326, 361, 68),
                  icon: '$_icons/ic_child.png',
                  iconBox: const Rect.fromLTWH(337, 348, 24, 24),
                  title: (text: HelpCenterText.childTitle(), right: 313, top: 334, width: 120, style: title),
                  subtitle: (text: HelpCenterText.childSub(), right: 313, top: 364, width: 134, style: sub),
                  textRoom: 255,
                  chevronTop: 351.5,
                  onTap: () => HelpCenterController.toLostChild(context),
                ),

                // اسأل عن التطبيق والمناسك
                ...HelpCard.build(
                  c,
                  card: const Rect.fromLTWH(16, 418, 361, 68),
                  icon: '$_icons/ic_question.png',
                  iconBox: const Rect.fromLTWH(337, 440, 24, 24),
                  title: (text: HelpCenterText.askTitle(), right: 328, top: 426, width: 154, style: title),
                  subtitle: (text: HelpCenterText.askSub(), right: 328, top: 456, width: 116, style: sub),
                  textRoom: 270,
                  chevronTop: 443.5,
                  onTap: () => HelpCenterController.toAssistant(context),
                ),

                Positioned.fill(
                  child: PilgrimTabBar(c: c, selected: PilgrimTab.help, onTab: (tab) => PilgrimTabsController.open(context, tab)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
