import '../../../../core/l10n/tx.dart';

/// نصوص بطاقة باب المسجد الحرام
abstract final class GateText {
  static String number(Object number) => tr('باب رقم $number', 'Gate $number');
  static const go = Tx('اتجه إلى هذا الباب', 'Go to this gate');
  static const current = Tx('وجهتك الحالية', 'Your destination');
  static const crowdLow = Tx('ازدحام خفيف', 'Light crowd');
  static const crowdMedium = Tx('ازدحام متوسط', 'Moderate crowd');
  static const crowdHigh = Tx('ازدحام شديد', 'Heavy crowd');
  static const close = Tx('إغلاق', 'Close');
}
