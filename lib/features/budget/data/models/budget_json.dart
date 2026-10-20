import '../../domain/entities/budget.dart';
import '../../domain/entities/expense.dart';

// -------------------------------------------------------------
// تحويل الميزانية لـ JSON وبالعكس (للحفظ على الجهاز، وجاهزة لـ API الميزانية لما ينضاف)
// -------------------------------------------------------------
extension ExpenseJson on Expense {
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'amount': amount, 'createdAt': createdAt.toIso8601String()};

  static Expense fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

extension BudgetJson on Budget {
  Map<String, dynamic> toJson() => {'total': total, 'expenses': [for (final e in expenses) e.toJson()]};

  static Budget fromJson(Map<String, dynamic> json) => Budget(
        total: (json['total'] as num?)?.toDouble() ?? 0,
        expenses: [for (final e in json['expenses'] as List? ?? const []) ExpenseJson.fromJson(e as Map<String, dynamic>)],
      );
}
