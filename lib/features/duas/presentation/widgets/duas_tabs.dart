import 'package:flutter/material.dart';

import '../../../../core/theme/figma_spaced_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../l10n/duas_text.dart';
import 'duas_colors.dart';

// -------------------------------------------------------------
// تبويبا الأدعية ("Group 15" — 361×50 عند y156): خلفية #84A29F والمختار مستطيل #4C7A75 180×50
// بالعربي: "أدعية مقترحة" يمين (صفحة 0) و"سجل أدعيتي" يسار (صفحة 1)
// المستطيل والألوان بيلحقوا السحب بين الصفحتين (PageController)
// -------------------------------------------------------------
class DuasTabs extends StatelessWidget {
  final FigmaCanvas c;
  final PageController controller;
  final ValueChanged<int> onSelect;

  const DuasTabs({super.key, required this.c, required this.controller, required this.onSelect});

  static const suggestedPage = 0;
  static const myDuasPage = 1;

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    final radius = BorderRadius.circular(s.x(14));
    return c.rect(
      left: 16,
      top: 156,
      width: 361,
      height: 50,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final page = (controller.hasClients && controller.position.haveDimensions ? controller.page! : controller.initialPage.toDouble()).clamp(0.0, 1.0);
          // النص بـ Figma أبعد عن نص التبويبين بـ 2.75 من نص مستطيله، وأوطى بـ 2.5 (مقاس)
          Widget label(String text, {required double start, required Color color, required int index}) => PositionedDirectional(
                start: s.x(start),
                top: 0,
                bottom: 0,
                width: s.x(180),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelect(index),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: s.y(5)),
                    child: FigmaSpacedText(
                      text,
                      style: c.style(20, FigmaWeight.semiBold, color, lineHeight: null),
                      letterSpacing: s.x(-0.408),
                      width: s.x(170),
                      align: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),
              );
          return Stack(
            children: [
              Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(color: DuasColors.tabsTrack, borderRadius: radius))),
              PositionedDirectional(
                start: s.x(181 * page),
                top: 0,
                bottom: 0,
                width: s.x(180),
                child: DecoratedBox(decoration: BoxDecoration(color: DuasColors.teal, borderRadius: radius)),
              ),
              label(DuasText.suggestedTab(), start: -2.75, color: Color.lerp(Colors.white, DuasColors.green, page)!, index: suggestedPage),
              label(DuasText.myDuasTab(), start: 181 + 2.75, color: Color.lerp(DuasColors.green, Colors.white, page)!, index: myDuasPage),
            ],
          );
        },
      ),
    );
  }
}
