import 'package:flutter/material.dart';

import '../../../../core/l10n/app_language.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_lines.dart';
import 'learning_arrow.dart';
import 'learning_colors.dart';
import 'learning_stage_spec.dart';

// -------------------------------------------------------------
// رسم عناصر مرحلة التعلم على الكانفس بأرقام Figma:
//   الشريحة: مستطيل radius 10 (#4C7A75 25%) + الأيقونة (سودا) + العنوان (SF Compact 457 14)
//   الكرت: radius 10 (#4C7A75 10%) بظل Figma + شريحته + النص (SF Compact 350 14 — والمقطع الأعرض 556)
// -------------------------------------------------------------
abstract final class LearningCardView {
  static TextStyle chipStyle(FigmaCanvas c) => c.style(14, FigmaWeight.sfRegular, Colors.black);
  static TextStyle bodyStyle(FigmaCanvas c) => c.style(14, FigmaWeight.poppinsRegular, Colors.black);
  static TextStyle boldStyle(FigmaCanvas c) => c.style(14, FigmaWeight.semiBold, Colors.black);

  /// سطر واحد بصندوق Figma (Auto width) — العنوان تحت الهيدر (SF Compact 556) والسطر تحت الشريحة (350)
  /// (بالإنجليزي: بنص الشاشة على عرض الكروت، لأنه أطول من صندوق العربي)
  static Widget line(FigmaCanvas c, LearningLine line, {required bool strong}) {
    final arabic = AppLanguage.isArabic;
    return FigmaLines.build(
      c,
      line.text(),
      left: arabic ? line.left : 16,
      top: line.top,
      width: arabic ? line.width : 361,
      align: arabic ? TextAlign.start : TextAlign.center,
      wrap: false,
      style: strong ? boldStyle(c) : bodyStyle(c),
    );
  }

  static List<Widget> chip(FigmaCanvas c, LearningChip chip) {
    final r = chip.rect;
    // مساحة العنوان لحد طرف النص: من بعد الأيقونة لو هي قبله (الشريحة اللي فوق) أو من بداية الشريحة
    // (بالإنجليزي بيصغر لو ما وسع)
    final icon = chip.icon.box;
    final textLeft = icon.right < chip.textRight ? icon.right + 4 : r.left + 8;
    return [
      c.box(left: r.left, top: r.top, width: r.width, height: r.height, color: chip.raised ? LearningColors.raisedChip : LearningColors.chip, radius: 10, hasShadow: chip.raised),
      c.image(chip.icon.asset, left: chip.icon.box.left, top: chip.icon.box.top, width: chip.icon.box.width, height: chip.icon.box.height, color: Colors.black),
      FigmaLines.build(c, chip.label(), left: textLeft, top: chip.textTop, width: chip.textRight - textLeft, wrap: false, style: chipStyle(c)),
    ];
  }

  static List<Widget> card(FigmaCanvas c, LearningCard card) {
    final r = card.rect;
    return [
      c.box(left: r.left, top: r.top, width: r.width, height: r.height, color: LearningColors.card, radius: 10, hasShadow: true),
      ...chip(c, card.chip),
      FigmaLines.build(
        c,
        card.body(),
        left: card.bodyLeft,
        top: card.bodyTop,
        width: card.bodyRight - card.bodyLeft,
        // الإنجليزي بياخد لحد آخر الكرت
        maxHeight: r.bottom - 4 - card.bodyTop,
        style: bodyStyle(c),
        boldStyle: boldStyle(c),
      ),
    ];
  }

  /// زر ذهبي (radius 10) — النص أبيض SF Compact 790 بالنص، أو طرفه عند [LearningLink.textRight] وقبله السهم
  static List<Widget> link(FigmaCanvas c, LearningLink link, VoidCallback onTap) {
    final r = link.rect;
    final style = c.style(link.textSize, link.textWeight, Colors.white);
    final textRight = link.textRight, arrow = link.arrow;
    return [
      c.box(left: r.left, top: r.top, width: r.width, height: r.height, color: LearningColors.gold, radius: 10),
      if (textRight == null)
        FigmaLines.build(c, link.label(), left: r.left + 6, top: link.textTop, width: r.width - 12, align: TextAlign.center, wrap: false, style: style)
      else
        FigmaLines.build(c, link.label(), left: (arrow?.right ?? r.left) + 6, top: link.textTop, width: textRight - (arrow?.right ?? r.left) - 6, wrap: false, style: style),
      if (arrow != null) c.rect(left: arrow.left, top: arrow.top, width: arrow.width, height: arrow.height, child: const IgnorePointer(child: LearningArrow())),
      c.tapArea(left: r.left, top: r.top, width: r.width, height: r.height, onTap: onTap),
    ];
  }
}
