import 'package:equatable/equatable.dart';

import 'expense.dart';

// -------------------------------------------------------------
// ميزانية الرحلة: المبلغ اللي حطه المعتمر + مصروفاته (الأحدث أول)
// كل الأرقام بالشاشة محسوبة من هون (ولا رقم ثابت)
// -------------------------------------------------------------
class Budget extends Equatable {
  /// الميزانية الكاملة ("من أصل")
  final double total;
  final List<Expense> expenses;

  const Budget({this.total = 0, this.expenses = const []});

  static const empty = Budget();

  /// "صرفت" — مجموع المصروفات
  double get spent => expenses.fold(0, (sum, e) => sum + e.amount);

  /// "المبلغ المتبقي" — بيصير سالب لو صرف أكتر من ميزانيته
  double get remaining => total - spent;

  /// نسبة المصروف من الميزانية (0…1) — للشريط
  double get spentShare => total <= 0 ? (spent > 0 ? 1 : 0) : (spent / total).clamp(0.0, 1.0);

  Budget copyWith({double? total, List<Expense>? expenses}) => Budget(total: total ?? this.total, expenses: expenses ?? this.expenses);

  @override
  List<Object> get props => [total, expenses];
}
