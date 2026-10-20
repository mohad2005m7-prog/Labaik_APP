import '../../domain/entities/budget.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/budget_repository.dart';
import '../sources/budget_local_source.dart';

// -------------------------------------------------------------
// الميزانية من الجهاز (لكل حساب) — كل تغيير بينحفظ فوراً
// -------------------------------------------------------------
class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl({BudgetLocalSource? local}) : _local = local ?? BudgetLocalSource();

  final BudgetLocalSource _local;

  Future<Budget> _save(Budget budget) async {
    await _local.save(budget);
    return budget;
  }

  @override
  Future<Budget> load() async {
    final budget = await _local.load();
    return budget.copyWith(expenses: [...budget.expenses]..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  @override
  Future<Budget> addFunds(double amount) async {
    final budget = await load();
    return _save(budget.copyWith(total: budget.total + amount));
  }

  @override
  Future<Budget> setTotal(double total) async => _save((await load()).copyWith(total: total));

  @override
  Future<Budget> addExpense({required String title, required double amount}) async {
    final now = DateTime.now();
    final expense = Expense(id: '${now.microsecondsSinceEpoch}', title: title, amount: amount, createdAt: now);
    final budget = await load();
    return _save(budget.copyWith(expenses: [expense, ...budget.expenses]));
  }

  @override
  Future<Budget> deleteExpense(String id) async {
    final budget = await load();
    return _save(budget.copyWith(expenses: [for (final e in budget.expenses) if (e.id != id) e]));
  }
}
