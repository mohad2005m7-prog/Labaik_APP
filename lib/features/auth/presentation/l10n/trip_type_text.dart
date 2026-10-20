import '../../../../core/l10n/tx.dart';

/// نصوص شاشة نوع الرحلة
abstract final class TripTypeText {
  static const title = Tx('نوع الرحلة', 'Trip Type');
  static const chooseFirst = Tx('يرجى اختيار نوع الرحلة للمتابعة', 'Please choose a trip type to continue');
  static const umrah = Tx('عمرة', 'Umrah');
  static const hajj = Tx('حج', 'Hajj');
}
