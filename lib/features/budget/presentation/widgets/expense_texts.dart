import 'package:flutter/material.dart';

import '../../../../core/theme/figma_spaced_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/content_direction.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_line.dart';
import '../../domain/entities/expense.dart';
import '../l10n/budget_format.dart';
import 'budget_colors.dart';

// -------------------------------------------------------------
// نصوص صف مصروف (Figma: الاسم SF Compact 556 14 أسود — المبلغ 556 14 #717171 — الوقت 350 10 #717171)
// الاسم من البداية (يمين بالعربي) والمبلغ "−80 ر.س" بالطرف التاني — صناديق النصوص 22
// الاسم كتبه المعتمر: اتجاهه حسب لغته، والطويل بينقطع بـ "…"
// -------------------------------------------------------------
List<Widget> expenseTexts(
  FigmaCanvas c,
  Expense expense, {
  required String when,
  required double titleTop,
  required double whenTop,
  required double amountTop,
  required double titleRight,
  required double whenRight,
  required double amountLeft,
}) {
  const titleWidth = 240.0;
  return [
    c.rect(
      left: titleRight - titleWidth,
      top: titleTop + FigmaCanvas.baselineFix,
      width: titleWidth,
      height: 22,
      child: Builder(builder: (context) {
        final direction = contentDirection(expense.title) ?? Directionality.of(context);
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: FigmaSpacedText(
            expense.title,
            style: c.style(14, FigmaWeight.semiBold, Colors.black),
            letterSpacing: c.s.x(-0.408),
            width: c.s.x(titleWidth),
            direction: direction,
            align: direction == Directionality.of(context) ? TextAlign.start : TextAlign.end,
            maxLines: 1,
          ),
        );
      }),
    ),
    c.line(when, left: whenRight - 200, top: whenTop, width: 200, height: 22, style: c.style(10, FigmaWeight.sfLight, BudgetColors.grey)),
    c.line(BudgetFormat.expense(expense.amount), left: amountLeft, top: amountTop, width: 120, height: 22, style: c.style(14, FigmaWeight.semiBold, BudgetColors.grey), align: TextAlign.end),
  ];
}
