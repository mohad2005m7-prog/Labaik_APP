import '../../../../core/l10n/tx.dart';

/// نصوص شاشة "كيف ستصل إلى السعودية؟"
abstract final class ArrivalMethodText {
  static const title = Tx('كيف ستصل إلى السعودية؟', 'How will you arrive in Saudi Arabia?');
  static const description = Tx('اختر وسيلة السفر التي ستستخدمها للوصول إلى السعودية.', 'Choose the means of travel you will use to reach Saudi Arabia.');
  static const chooseFirst = Tx('الرجاء اختيار وسيلة السفر أولاً', 'Please choose a means of travel first');
  static const airplane = Tx('طائرة', 'Airplane');
  static const bus = Tx('حافلة', 'Bus');
  static const privateCar = Tx('سيارة خاصة', 'Private Car');
}
