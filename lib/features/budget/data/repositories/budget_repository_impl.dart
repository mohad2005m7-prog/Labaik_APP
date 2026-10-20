import 'dart:async';

import '../../domain/entities/budget.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/budget_repository.dart';
import '../sources/budget_api.dart';
import '../sources/budget_local_source.dart';

// -------------------------------------------------------------
// الميزانية: على الجهاز (لكل حساب، بتشتغل بلا نت) + السيرفر (/me/budget حتى ترجع على أي جهاز)
// - كل تغيير بينحفظ فوراً على الجهاز وبينرفع بالخلفية (PUT) — بلا نت بيضل "مش مرفوع" لحد المرة الجاية
// - فتح الشاشة: في تغييرات مش مرفوعة → بنرفعها | وإلا → اللي على السيرفر (جهاز جديد)
//   وأول مرة (السيرفر فاضي والجهاز فيه) → بنرفع اللي عالجهاز
// -------------------------------------------------------------
class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl({BudgetLocalSource? local, BudgetApi? api}) : _local = local ?? BudgetLocalSource(), _api = api ?? BudgetApi.server();

  final BudgetLocalSource _local;
  final BudgetApi _api;

  /// رقم آخر تغيير — الرفع بيعلّم "مرفوع" بس لو ما صار تغيير أجدد منه
  int _version = 0;

  Future<Budget> _save(Budget budget) async {
    await _local.save(budget);
    await _local.setDirty(true);
    unawaited(_push(budget, ++_version));
    return budget;
  }

  Future<void> _push(Budget budget, int version) async {
    try {
      await _api.put(budget);
      if (version == _version) await _local.setDirty(false);
    } catch (_) {
      // بلا نت — بنرفعها المرة الجاية
    }
  }

  Future<Budget> _fromDevice() async {
    final budget = await _local.load();
    return budget.copyWith(expenses: [...budget.expenses]..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  @override
  Future<Budget> load() async {
    final local = await _fromDevice();
    try {
      if (await _local.isDirty()) {
        await _api.put(local);
        await _local.setDirty(false);
        return local;
      }
      final server = await _api.get();
      final serverEmpty = server.total == 0 && server.expenses.isEmpty;
      if (serverEmpty && (local.total != 0 || local.expenses.isNotEmpty)) {
        await _api.put(local);
        return local;
      }
      await _local.save(server);
      return server;
    } catch (_) {
      // بلا نت (أو سيرفر أقدم بلا /me/budget) → اللي على الجهاز
      return local;
    }
  }

  @override
  Future<Budget> addFunds(double amount) async {
    final budget = await _fromDevice();
    return _save(budget.copyWith(total: budget.total + amount));
  }

  @override
  Future<Budget> setTotal(double total) async => _save((await _fromDevice()).copyWith(total: total));

  @override
  Future<Budget> addExpense({required String title, required double amount}) async {
    final now = DateTime.now();
    final expense = Expense(id: '${now.microsecondsSinceEpoch}', title: title, amount: amount, createdAt: now);
    final budget = await _fromDevice();
    return _save(budget.copyWith(expenses: [expense, ...budget.expenses]));
  }

  @override
  Future<Budget> deleteExpense(String id) async {
    final budget = await _fromDevice();
    return _save(budget.copyWith(expenses: [for (final e in budget.expenses) if (e.id != id) e]));
  }
}
