import '../../../../core/l10n/tx.dart';

/// نصوص شاشة "ميزانيتي"
abstract final class BudgetText {
  static const title = Tx('ميزانيتي', 'My budget');
  static const subtitle = Tx('رتّب مصروفك وخليك عارف وين بروح.', 'Organize your spending and know where it goes.');
  static const remaining = Tx('المبلغ المتبقي', 'Remaining amount');
  static const addFunds = Tx(' + إضافة مبلغ', '+ Add amount');
  static const editBudget = Tx('تعديل الميزانية', 'Edit budget');
  static const whatBought = Tx('شو اشتريت؟', 'What did you buy?');
  static const whatBoughtHint = Tx('مثال: وجبة غداء', 'e.g. Lunch');
  static const howMuch = Tx('كم دفعت؟', 'How much did you pay?');
  static const addExpense = Tx(' + إضافة المصروف', '+ Add expense');
  static const latest = Tx('آخر المصروفات', 'Latest expenses');
  static const viewAll = Tx('عرض الكل', 'View all');
  static const expenseAdded = Tx('تمت إضافة المصروف', 'Expense added');
  static const errorTitle = Tx('يرجى كتابة شو اشتريت', 'Please enter what you bought');
  static const errorAmount = Tx('يرجى كتابة المبلغ اللي دفعته', 'Please enter the amount you paid');

  static String ofTotal(String amount) => tr('من أصل $amount', 'of $amount');
  static String spent(String amount) => tr('صرفت $amount من ميزانيتك', 'You spent $amount of your budget');
}
