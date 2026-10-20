import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_line.dart';
import '../../../../core/widgets/figma_page.dart';
import '../controllers/budget_controller.dart';
import '../cubits/budget_cubit.dart';
import '../l10n/all_expenses_text.dart';
import '../l10n/budget_format.dart';
import '../widgets/all_expenses_list.dart';
import '../widgets/amount_pill.dart';
import '../widgets/budget_colors.dart';

// -------------------------------------------------------------
// كل المصروفات — Figma (153:2497): إجمالي المصروفات (خانة ذهبية) وكل مصروفات المعتمر (الأحدث أول)
// -------------------------------------------------------------
class AllExpensesScreen extends StatelessWidget {
  const AllExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BudgetCubit, BudgetState>(
      listenWhen: (a, b) => a.messageVersion != b.messageVersion,
      listener: BudgetController.showMessages,
      builder: (context, state) => FigmaPage(
        title: AllExpensesText.title(),
        titleRight: 346.5, // "Frame 38" عرضه 372 بهالإطار (مقاس)
        body: (c) {
          TextStyle grey12() => c.style(12, FigmaWeight.sfLight, BudgetColors.grey);
          return [
            c.line(AllExpensesText.subtitle(), left: 24.5, top: 117, width: 350, height: 22, style: c.style(14, FigmaWeight.semiBold, Colors.black)),
            c.line(AllExpensesText.recorded(), left: 165.5, top: 150, width: 200, height: 22, style: grey12()),
            AmountPill(c: c, amount: BudgetFormat.money(state.budget.spent), right: 377, top: 179, minWidth: 130, textTop: 183),
            c.line(AllExpensesText.total(), left: 166, top: 216, width: 200, height: 22, style: grey12()),
            Positioned.fill(
              child: AllExpensesList(c: c, expenses: state.budget.expenses, onLongPress: (e) => BudgetController.deleteExpense(context, e)),
            ),
          ];
        },
      ),
    );
  }
}
