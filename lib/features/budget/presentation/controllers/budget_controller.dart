import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/budget_repository.dart';
import '../cubits/budget_cubit.dart';
import '../pages/all_expenses_screen.dart';
import '../pages/budget_screen.dart';
import '../widgets/budget_dialogs.dart';

// -------------------------------------------------------------
// التنقل بشاشات الميزانية (بروتوتايب Figma):
// الرئيسية (كرت "الميزانية") → ميزانيتي → "عرض الكل" → كل المصروفات
// الشاشتين بيشاركوا نفس الـ Cubit (أي تغيير بيبين بالتنتين)
// -------------------------------------------------------------
class BudgetController {
  static final BudgetRepository _repository = BudgetRepositoryImpl();

  static Future<void> open(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => BudgetCubit(_repository)..load(), child: const BudgetScreen())),
      );

  static Future<void> openAll(BuildContext context) {
    final cubit = context.read<BudgetCubit>();
    return Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: cubit, child: const AllExpensesScreen())));
  }

  /// ضغطة مطوّلة على مصروف: حذفه بعد التأكيد
  static Future<void> deleteExpense(BuildContext context, Expense expense) async {
    final cubit = context.read<BudgetCubit>();
    if (await confirmDeleteExpense(context, expense.title)) await cubit.deleteExpense(expense);
  }

  /// رسائل الـ Cubit بتنعرض بس من الشاشة اللي فوق
  static void showMessages(BuildContext context, BudgetState state) {
    final message = state.message;
    if (message == null || !(ModalRoute.of(context)?.isCurrent ?? true)) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message()), duration: const Duration(milliseconds: 1600)));
  }
}
