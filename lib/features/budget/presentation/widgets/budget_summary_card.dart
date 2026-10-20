import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_line.dart';
import '../../domain/entities/budget.dart';
import '../l10n/budget_format.dart';
import '../l10n/budget_text.dart';
import 'amount_pill.dart';
import 'budget_colors.dart';
import 'budget_progress_bar.dart';

// -------------------------------------------------------------
// كرت الميزانية ("Rectangle 136" — 361×204 #EEF2F2 radius 10):
// المبلغ المتبقي (خانة ذهبية) — من أصل الميزانية — الشريط — صرفت كذا — "+ إضافة مبلغ" و"تعديل الميزانية"
// كل الأرقام من ميزانية المعتمر نفسه
// -------------------------------------------------------------
class BudgetSummaryCard extends StatelessWidget {
  final FigmaCanvas c;
  final Budget budget;
  final VoidCallback onAddFunds;
  final VoidCallback onEditBudget;

  const BudgetSummaryCard({super.key, required this.c, required this.budget, required this.onAddFunds, required this.onEditBudget});

  @override
  Widget build(BuildContext context) {
    // SF Compact 350 (12 و 11) أسود
    TextStyle light(double size) => c.style(size, FigmaWeight.sfLight, Colors.black);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.box(left: 16, top: 157, width: 361, height: 204, color: BudgetColors.cardFill, radius: 10),
        c.line(BudgetText.remaining(), left: 161.5, top: 157, width: 200, height: 22, style: light(12)),
        AmountPill(c: c, amount: BudgetFormat.money(budget.remaining), right: 366, top: 186, minWidth: 118, textTop: 189),
        c.line(BudgetText.ofTotal(BudgetFormat.money(budget.total)), left: 36, top: 227, width: 330, height: 22, style: light(11)),
        BudgetProgressBar(c: c, share: budget.spentShare),
        c.line(BudgetText.spent(BudgetFormat.money(budget.spent)), left: 34.5, top: 264, width: 330, height: 22, style: light(11)),
        c.button(BudgetText.addFunds(), left: 205, top: 298, width: 171, height: 44, figmaSpacing: true, onTap: onAddFunds),
        c.button(BudgetText.editBudget(), left: 15, top: 298, width: 171, height: 44, figmaSpacing: true, onTap: onEditBudget),
      ],
    );
  }
}
