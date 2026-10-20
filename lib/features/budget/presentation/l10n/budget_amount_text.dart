import '../../../../core/l10n/tx.dart';

/// نصوص نافذة المبلغ ("+ إضافة مبلغ" / "تعديل الميزانية") وحذف مصروف
abstract final class BudgetAmountText {
  static const save = Tx('حفظ', 'Save');
  static const cancel = Tx('إلغاء', 'Cancel');
  static const errorAmount = Tx('يرجى كتابة مبلغ صحيح', 'Please enter a valid amount');
  static const fundsAdded = Tx('تمت إضافة المبلغ للميزانية', 'Amount added to your budget');
  static const budgetSaved = Tx('تم تعديل الميزانية', 'Budget updated');
  static const deleteQuestion = Tx('حذف المصروف؟', 'Delete this expense?');
  static const delete = Tx('حذف', 'Delete');
  static const deleted = Tx('تم حذف المصروف', 'Expense deleted');
}
