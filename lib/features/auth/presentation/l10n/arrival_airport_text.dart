import '../../../../core/l10n/tx.dart';

/// نصوص شاشة مطار الوصول
abstract final class ArrivalAirportText {
  static const title = Tx('ما مطار وصولك؟', 'What is your arrival airport?');
  static const description = Tx('اختر المطار الذي ستصل إليه في السعودية.', 'Choose the airport you will arrive at in Saudi Arabia.');
  static const chooseFirst = Tx('الرجاء اختيار مطار الوصول أولاً', 'Please choose your arrival airport first');
  static const search = Tx('ابحث عن مطار وصولك', 'Search for your arrival airport');
  static const international = Tx('المطارات الدولية الرئيسية', 'Main International Airports');
  static const regional = Tx('المطارات الإقليمية والمحلية', 'Regional and Domestic Airports');
}
