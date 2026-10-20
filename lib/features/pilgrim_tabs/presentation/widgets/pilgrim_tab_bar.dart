import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../auth/presentation/l10n/home_text.dart';
import '../controllers/pilgrim_tabs_controller.dart';
import 'group_filled_icon.dart';
import 'info_filled_icon.dart';

// -------------------------------------------------------------
// شريط التنقل بتبويبات المعتمر (مكوّن Figma "ناف بار" 395×70 من y752 — "الدردشات" و"الأفراد" و"مركز المساعدة"):
// #F5F5F5 + خط علوي 0.5 أسود 30% — التبويب المختار أيقونته مليانة ونصه أتقل
// أماكن الأيقونات والنصوص مقاسة من لقطات Figma (الأعمدة مش متساوية بالظبط بالتصميم)
// "الدردشات" نصه أتقل بالحالتين زي Figma
// -------------------------------------------------------------
class PilgrimTabBar extends StatelessWidget {
  final FigmaCanvas c;
  final PilgrimTab selected;
  final ValueChanged<PilgrimTab> onTab;

  /// أعلى الشريط بإطار Figma (752 — وبالإطارات الأطول مثل "لائحة أفراد المجموعة" 884: 784)
  final double barTop;

  const PilgrimTabBar({super.key, required this.c, required this.selected, required this.onTab, this.barTop = top});

  static const top = 752.0;
  static const height = 70.0;
  static const _home = 'assets/images/home';
  static const _green = Color(0xFF1F3B2E);
  static const _fill = Color(0xF0F5F5F5);
  static const _hairline = Color(0x4D000000);

  // النصوص SF Compact 11.5 (مقاسة من لقطة Figma) — حبرها من y795
  static const _labelTop = 793.0;

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    final dy = barTop - top;
    TextStyle label(double weight) => c.style(11.5, weight, _green, lineHeight: null, letterSpacing: -0.24);
    final chats = selected == PilgrimTab.chats, people = selected == PilgrimTab.people, help = selected == PilgrimTab.help;
    // (التبويب، مركز الأيقونة x/y، حجمها، مركز النص، الأيقونة (null = مرسومة: المعلومات/الأفراد المليانة)، النص، الوزن)
    final items = [
      (PilgrimTab.home, 360.75, 776.5, 24.0, 357.25, 'assets/images/supervisor/tab_home.png', HomeText.navHome(), FigmaWeight.sfLight),
      (PilgrimTab.chats, 284.0, 775.75, 25.0, 284.25, chats ? 'assets/images/supervisor/tab_chats_filled.png' : '$_home/nav_chats.png', HomeText.navChats(), FigmaWeight.semiBold),
      (PilgrimTab.people, people ? 204.75 : 205.0, people ? 778.85 : 776.0, people ? 24.1 : 25.0, 205.0, people ? null : '$_home/nav_people.png', HomeText.navPeople(), people ? FigmaWeight.semiBold : FigmaWeight.sfLight),
      (PilgrimTab.map, 126.25, 777.25, 22.0, 125.25, '$_home/nav_map.png', HomeText.navMap(), FigmaWeight.sfLight),
      (PilgrimTab.help, 46.25, 777.25, help ? 19.0 : 21.5, 45.0, help ? null : '$_home/nav_info.png', HomeText.navHelp(), help ? FigmaWeight.semiBold : FigmaWeight.sfLight),
    ];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.rect(
          left: 0,
          top: barTop,
          width: FigmaCanvas.frameWidth,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _fill,
              boxShadow: [BoxShadow(color: _hairline, offset: Offset(0, s.y(-0.5)))],
            ),
          ),
        ),
        for (final (tab, iconX, iconY, size, labelX, asset, text, weight) in items) ...[
          if (asset == null)
            c.rect(
              left: iconX - size / 2,
              top: iconY + dy - size / 2,
              width: size,
              height: size,
              child: Center(
                child: tab == PilgrimTab.people ? GroupFilledIcon(width: s.x(size), color: _green) : InfoFilledIcon(size: s.x(size), color: _green),
              ),
            )
          else
            // الأيقونات المليانة جاهزة بلونها (نقاطها البيضا بتختفي لو تلوّنت)
            c.image(asset, left: iconX - size / 2, top: iconY + dy - size / 2, width: size, height: size, color: asset.endsWith('_filled.png') ? null : _green),
          c.text(text, left: labelX - 39, top: _labelTop + dy, width: 78, height: 14, dy: 0, align: TextAlign.center, style: label(weight)),
          c.tapArea(left: (iconX - 39.3).clamp(0, FigmaCanvas.frameWidth - 78.6), top: barTop, width: 78.6, height: height, onTap: () => onTab(tab)),
        ],
      ],
    );
  }
}
