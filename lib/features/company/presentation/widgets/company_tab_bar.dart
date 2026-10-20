import 'package:flutter/material.dart';

import '../../../../core/l10n/tx.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../l10n/company_tab_bar_text.dart';
import 'company_colors.dart';

/// تبويبات الشركة بالترتيب من البداية (يمين بالعربي)
enum CompanyTab { home, trips, groups, profile }

// -------------------------------------------------------------
// "نافبار الشركة" (395×70 من y765 بإطارات الشركة): #F5F5F5 94% + خط علوي 0.5 أسود 30%
// التبويب المختار أيقونته مليانة (الرئيسية / الرحلات) ونصه أتقل
// أماكن الأيقونات والنصوص مقاسة من لقطات Figma (الأعمدة مش متساوية بالظبط بالتصميم)
// -------------------------------------------------------------
class CompanyTabBar extends StatelessWidget {
  final FigmaCanvas c;
  final CompanyTab selected;
  final ValueChanged<CompanyTab> onTab;

  const CompanyTabBar({super.key, required this.c, required this.selected, required this.onTab});

  static const top = 765.0;
  static const height = 70.0;

  // النصوص SF Compact 11.5 — حبرها من y806
  static const _labelTop = 804.0;

  // (التبويب، مركز الأيقونة x/y، حجمها، مركز النص، الأيقونة، المليانة، النص)
  static const _items = [
    (CompanyTab.home, 355.0, 788.5, 24.0, 355.0, 'tab_home', 'tab_home_filled', CompanyTabBarText.home),
    (CompanyTab.trips, 257.5, 787.5, 24.0, 257.25, 'tab_trips', 'tab_trips_filled', CompanyTabBarText.trips),
    (CompanyTab.groups, 155.5, 787.25, 24.0, 154.75, 'tab_groups', null, CompanyTabBarText.groups),
    (CompanyTab.profile, 48.75, 788.75, 24.0, 49.75, 'tab_profile', null, CompanyTabBarText.profile),
  ];

  /// كل أيقونات الشريط — بتنفك مسبقاً حتى التبديل يكون فوري
  static Iterable<String> get iconAssets => [
        for (final (_, _, _, _, _, icon, filled, _) in _items) ...['$companyAssets/$icon.png', if (filled != null) '$companyAssets/$filled.png'],
      ];

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    TextStyle label(double weight) => c.style(11.5, weight, CompanyColors.green, lineHeight: null, letterSpacing: -0.24);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.rect(
          left: 0,
          top: top,
          width: FigmaCanvas.frameWidth,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(color: CompanyColors.navFill, boxShadow: [BoxShadow(color: CompanyColors.navHairline, offset: Offset(0, s.y(-0.5)))]),
          ),
        ),
        for (final (tab, iconX, iconY, size, labelX, icon, filled, text) in _items) ..._item(tab, iconX, iconY, size, labelX, icon, filled, text, label),
      ],
    );
  }

  List<Widget> _item(CompanyTab tab, double iconX, double iconY, double size, double labelX, String icon, String? filled, Tx text, TextStyle Function(double) label) {
    final active = tab == selected;
    // الأيقونة المليانة الجاهزة بلونها (ما بتتلوّن) — والباقي بيتلوّن أخضر
    final asset = active && filled != null ? filled : icon;
    return [
      c.image('$companyAssets/$asset.png', left: iconX - size / 2, top: iconY - size / 2, width: size, height: size, color: asset == 'tab_home_filled' ? null : CompanyColors.green),
      c.text(text(), left: labelX - 39, top: _labelTop, width: 78, height: 14, dy: 0, align: TextAlign.center, style: label(active ? FigmaWeight.semiBold : FigmaWeight.sfLight)),
      c.tapArea(left: (iconX - 39.3).clamp(0, FigmaCanvas.frameWidth - 78.6), top: top, width: 78.6, height: height, onTap: () => onTab(tab)),
    ];
  }
}
