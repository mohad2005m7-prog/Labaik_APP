import '../entities/budget.dart';

// -------------------------------------------------------------
// ميزانية المعتمر (محفوظة لحسابه): المبلغ، إضافة عليه، تعديله، والمصروفات
// على الجهاز وعلى السيرفر (/me/budget) — البيانات بتنحفظ على الجهاز أول وبتنرفع،
// فالشاشات والـ Cubit ما بتعرف إذا في نت أو لأ
// -------------------------------------------------------------
abstract class BudgetRepository {
  Future<Budget> load();

  /// "+ إضافة مبلغ": بيزيد على الميزانية
  Future<Budget> addFunds(double amount);

  /// "تعديل الميزانية": المبلغ الكامل الجديد
  Future<Budget> setTotal(double total);

  /// "+ إضافة المصروف"
  Future<Budget> addExpense({required String title, required double amount});

  Future<Budget> deleteExpense(String id);
}
