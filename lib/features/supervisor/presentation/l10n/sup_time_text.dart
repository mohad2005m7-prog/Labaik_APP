import '../../../../core/l10n/tx.dart';

/// نصوص الأوقات بشاشات المشرف (ص/م، اليوم الساعة...)
abstract final class SupTimeText {
  static const amShort = Tx('ص', 'AM');
  static const pmShort = Tx('م', 'PM');
  static const amLong = Tx('صباحًا', 'AM');
  static const pmLong = Tx('مساءً', 'PM');
  static String todayAt(Object time) => tr('اليوم، $time', 'Today, $time');

  /// "أمس، 6:00 م" (زي كرت الإعلان بـ Figma)
  static String yesterdayAt(Object time) => tr('أمس، $time', 'Yesterday, $time');
}
