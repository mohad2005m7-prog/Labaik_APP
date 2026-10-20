import 'package:flutter/material.dart';

import '../../../../core/l10n/tx.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../l10n/sup_tab_bar_text.dart';
import 'supervisor_colors.dart';
import 'supervisor_widgets.dart';

// -------------------------------------------------------------
// شريط التنقل السفلي للمشرف (TabBar 49 بـ Figma): #F9F9F9 94% + خط علوي (0,-0.5) أسود 30%
// الترتيب من البداية (يمين بالعربي): الرئيسية، الدردشات، المجموعة، الإعلانات، الملف الشخصي
// التبويب المختار: أيقونة معبّاة (مظللة) ونص أعرض — زي "الرئيسية" بـ Figma
// 5 أعمدة متساوية جوّا هامش 6 من الجهتين (حتى ما يقرب "الملف الشخصي" من حافة الشاشة المدوّرة)
// بدون blur (كان ثقيل وما إله فرق فوق الخلفية البيضا)
// -------------------------------------------------------------
class SupervisorTabBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const SupervisorTabBar({super.key, required this.index, required this.onTap});

  static const _fill = Color(0xFFF9F9F9);
  static const _hairline = Color(0x4D000000);

  // (النص، الأيقونة، أعلى الأيقونة بـ Figma)
  static const _items = [
    (SupTabBarText.home, 'tab_home', 6.0),
    (SupTabBarText.chats, 'tab_chats', 6.0),
    (SupTabBarText.group, 'tab_group', 6.0),
    (SupTabBarText.announcements, 'tab_megaphone', 6.0),
    (SupTabBarText.profile, 'tab_profile', 8.0),
  ];

  /// كل أيقونات الشريط (العادية والمعبّاة) — بتنفك مسبقاً حتى التبديل يكون فوري
  static Iterable<String> get iconAssets => [
        for (final (_, icon, _) in _items) ...['$supAssets/$icon.png', '$supAssets/${icon}_filled.png'],
      ];

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    final systemBottom = MediaQuery.paddingOf(context).bottom;
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(color: _fill, boxShadow: [BoxShadow(color: _hairline, offset: Offset(0, s.y(-0.5)))]),
        child: Padding(
          padding: EdgeInsets.only(bottom: systemBottom),
          child: SizedBox(
            height: s.y(49),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: s.x(6)),
              child: Row(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Expanded(child: _TabItem(s: s, item: _items[i], active: i == index, onTap: () => onTap(i))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final DesignScale s;
  final (Tx, String, double) item;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({required this.s, required this.item, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (label, icon, iconTop) = item;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        children: [
          // الأيقونة 24 بمكانها النسبي بـ Figma (حجمها بيتحجّم أفقياً)
          Positioned(
            top: s.y(iconTop + 12) - s.x(12),
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: Image.asset('$supAssets/${active ? '${icon}_filled' : icon}.png', key: ValueKey(active), width: s.x(24), height: s.x(24)),
              ),
            ),
          ),
          // SF Compact 10 — line height auto — letter spacing -0.24 — أعلاه 34.87 + 0.8 (نفس رئيسية المعتمر)
          Positioned(
            top: s.y(34.87 + 0.8),
            left: s.x(2),
            right: s.x(2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label(),
                maxLines: 1,
                style: figmaText(s, size: 10, weight: active ? FigmaWeight.semiBold : FigmaWeight.sfLight, color: SupColors.green, lineHeight: null, letterSpacing: -0.24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
