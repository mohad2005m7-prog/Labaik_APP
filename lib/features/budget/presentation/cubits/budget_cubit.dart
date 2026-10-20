import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/tx.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/budget_repository.dart';
import '../l10n/budget_amount_text.dart';
import '../l10n/budget_format.dart';
import '../l10n/budget_text.dart';

class BudgetState extends Equatable {
  final Budget budget;
  final bool loading;

  /// رسالة للمستخدم (خطأ أو تم) — [messageVersion] بيتغير كل مرة حتى نفس الرسالة تنعرض مرتين
  final Tx? message;
  final int messageVersion;

  const BudgetState({this.budget = Budget.empty, this.loading = true, this.message, this.messageVersion = 0});

  BudgetState copyWith({Budget? budget, bool? loading, Tx? message}) => BudgetState(
        budget: budget ?? this.budget,
        loading: loading ?? this.loading,
        message: message,
        messageVersion: message == null ? messageVersion : messageVersion + 1,
      );

  @override
  List<Object?> get props => [budget, loading, message, messageVersion];
}

// -------------------------------------------------------------
// الميزانية (شاشة "ميزانيتي" و"كل المصروفات" مع بعض): المبلغ والمصروفات اللي بيدخلها المعتمر
// -------------------------------------------------------------
class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit(this._repository) : super(const BudgetState());

  final BudgetRepository _repository;

  Future<void> load() async {
    final budget = await _repository.load();
    if (!isClosed) emit(state.copyWith(budget: budget, loading: false));
  }

  /// "+ إضافة المصروف" — بيرجع true لما ينضاف (حتى الشاشة تفضي الحقول)
  Future<bool> addExpense({required String title, required String amount}) async {
    final name = title.trim();
    final value = BudgetFormat.parse(amount);
    if (name.isEmpty || value == null) {
      emit(state.copyWith(message: name.isEmpty ? BudgetText.errorTitle : BudgetText.errorAmount));
      return false;
    }
    final budget = await _repository.addExpense(title: name, amount: value);
    if (!isClosed) emit(state.copyWith(budget: budget, message: BudgetText.expenseAdded));
    return true;
  }

  /// "+ إضافة مبلغ"
  Future<void> addFunds(double amount) async {
    final budget = await _repository.addFunds(amount);
    if (!isClosed) emit(state.copyWith(budget: budget, message: BudgetAmountText.fundsAdded));
  }

  /// "تعديل الميزانية"
  Future<void> setTotal(double total) async {
    final budget = await _repository.setTotal(total);
    if (!isClosed) emit(state.copyWith(budget: budget, message: BudgetAmountText.budgetSaved));
  }

  Future<void> deleteExpense(Expense expense) async {
    final budget = await _repository.deleteExpense(expense.id);
    if (!isClosed) emit(state.copyWith(budget: budget, message: BudgetAmountText.deleted));
  }
}
