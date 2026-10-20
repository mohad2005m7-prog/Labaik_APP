import '../../../../core/l10n/tx.dart';

/// أسماء الأدعية المقترحة (القائمة وعنوان شاشة كل دعاء)
abstract final class SuggestedDuaText {
  static const _titles = [
    Tx('الدعاء الأول', 'First dua'),
    Tx('الدعاء الثاني', 'Second dua'),
    Tx('الدعاء الثالث', 'Third dua'),
    Tx('الدعاء الرابع', 'Fourth dua'),
    Tx('الدعاء الخامس', 'Fifth dua'),
    Tx('الدعاء السادس', 'Sixth dua'),
    Tx('الدعاء السابع', 'Seventh dua'),
    Tx('الدعاء الثامن', 'Eighth dua'),
    Tx('الدعاء التاسع', 'Ninth dua'),
    Tx('الدعاء العاشر', 'Tenth dua'),
  ];

  /// [number]: 1 … 10
  static String title(int number) => number >= 1 && number <= _titles.length ? _titles[number - 1]() : tr('الدعاء $number', 'Dua $number');
}
