import '../../../../core/l10n/tx.dart';

/// نصوص شاشة "كل المصروفات"
abstract final class AllExpensesText {
  static const title = Tx('كل المصروفات', 'All expenses');
  static const subtitle = Tx('راجع مشترياتك واعرف وين راحت مصاريفك خلال الرحلة', 'Review your purchases and see where your money went during the trip');
  static const recorded = Tx('جميع مشترياتك المسجّلة', 'All your recorded purchases');
  static const total = Tx('إجمالي المصروفات', 'Total expenses');
}
