import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_line.dart';
import '../../../../core/widgets/figma_page.dart';
import '../controllers/budget_controller.dart';
import '../cubits/budget_cubit.dart';
import '../l10n/budget_format.dart';
import '../l10n/budget_text.dart';
import '../widgets/budget_colors.dart';
import '../widgets/budget_dialogs.dart';
import '../widgets/budget_input_field.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/recent_expenses_box.dart';

// -------------------------------------------------------------
// ميزانيتي — Figma "الميزانية" (190:1760 فاضية، 153:2386 فيها مصروفات)
// كرت الميزانية (المتبقي / من أصل / الشريط / صرفت) — "شو اشتريت؟" و"كم دفعت؟" ← "+ إضافة المصروف"
// "آخر المصروفات" (أحدث 3) و"عرض الكل" ← كل المصروفات — كل شي من بيانات المعتمر نفسه
// -------------------------------------------------------------
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _title = TextEditingController();
  final _amount = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  BudgetCubit get _cubit => context.read<BudgetCubit>();

  Future<void> _addExpense() async {
    if (await _cubit.addExpense(title: _title.text, amount: _amount.text)) {
      _title.clear();
      _amount.clear();
      if (mounted) FocusScope.of(context).unfocus();
    }
  }

  Future<void> _addFunds() async {
    final amount = await showBudgetAmountSheet(context, title: BudgetText.addFunds());
    if (amount != null) await _cubit.addFunds(amount);
  }

  Future<void> _editBudget() async {
    final total = await showBudgetAmountSheet(context, title: BudgetText.editBudget(), initial: _cubit.state.budget.total);
    if (total != null) await _cubit.setTotal(total);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BudgetCubit, BudgetState>(
      listenWhen: (a, b) => a.messageVersion != b.messageVersion,
      listener: BudgetController.showMessages,
      builder: (context, state) => FigmaPage(
        title: BudgetText.title(),
        body: (c) {
          TextStyle label(Color color) => c.style(14, FigmaWeight.semiBold, color);
          return [
            c.line(BudgetText.subtitle(), left: 75.5, top: 113, width: 300, height: 22, style: label(Colors.black)),
            Positioned.fill(child: BudgetSummaryCard(c: c, budget: state.budget, onAddFunds: _addFunds, onEditBudget: _editBudget)),
            c.line(BudgetText.whatBought(), left: 176, top: 369, width: 200, height: 22, style: label(Colors.black)),
            c.rect(left: 16, top: 399, width: 360, height: BudgetInputField.height, child: BudgetInputField(s: c.s, controller: _title, hint: BudgetText.whatBoughtHint(), textInset: 33)),
            c.line(BudgetText.howMuch(), left: 175, top: 450, width: 200, height: 22, style: label(Colors.black)),
            c.rect(left: 14, top: 483, width: 362, height: BudgetInputField.height, child: BudgetInputField(s: c.s, controller: _amount, hint: BudgetFormat.amountHint(), amount: true, textInset: 35.5)),
            c.button(BudgetText.addExpense(), left: 15, top: 547, width: 361, height: 44, figmaSpacing: true, onTap: _addExpense),
            c.line(BudgetText.latest(), left: 196, top: 608, width: 180, height: 22, style: label(Colors.black)),
            c.line(BudgetText.viewAll(), left: 16.5, top: 608, width: 150, height: 22, style: label(BudgetColors.grey), align: TextAlign.end),
            c.tapArea(left: 6, top: 600, width: 79, height: 38, onTap: () => BudgetController.openAll(context)),
            Positioned.fill(
              child: RecentExpensesBox(c: c, expenses: state.budget.expenses, onLongPress: (e) => BudgetController.deleteExpense(context, e)),
            ),
          ];
        },
      ),
    );
  }
}

