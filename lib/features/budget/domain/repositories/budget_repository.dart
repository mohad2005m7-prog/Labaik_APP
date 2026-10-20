import '../entities/budget.dart';

// -------------------------------------------------------------
// ميزانية المعتمر (محفوظة لحسابه): المبلغ، إضافة عليه، تعديله، والمصروفات
// السيرفر لسا ما فيه endpoints للميزانية — فالتطبيق بيحفظ على الجهاز،
// ولما تنضاف بس بتتغير الـ implementation (الشاشات والـ Cubit ما بتتغير)
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
