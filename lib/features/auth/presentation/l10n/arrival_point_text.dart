import '../../../../core/l10n/tx.dart';

/// نصوص شاشة نقطة الوصول
abstract final class ArrivalPointText {
  static const title = Tx('ما نقطة وصولك؟', 'What is your arrival point?');
  static const description = Tx('اختر نقطة وصولك إلى السعودية.', 'Choose your arrival point in Saudi Arabia.');
  static const chooseFirst = Tx('الرجاء اختيار نقطة الوصول أولاً', 'Please choose your arrival point first');
  static const search = Tx('ابحث عن وجهتك الاولى', 'Search for your first destination');
}
