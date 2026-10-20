import '../../../../core/l10n/tx.dart';

/// نصوص شاشة موعد الوصول
abstract final class DepartureText {
  static const title = Tx('متى ستنطلق في رحلتك إلى مكة؟', 'When will you set off for Makkah?');
  static const description = Tx(
    'يرجى إدخال تاريخ ووقت انطلاقك لنتمكن من تنبيهك بخطوات الإحرام في الوقت المناسب.',
    'Please enter your departure date and time so we can remind you of the ihram steps at the right time.',
  );
  static const arrivalDate = Tx('تاريخ الوصول', 'Arrival date');
  static const chooseArrivalDate = Tx('اختر تاريخ الوصول', 'Choose the arrival date');
  static const chooseArrivalTime = Tx('اختر وقت الوصول', 'Choose the arrival time');
  static const expectedArrivalTime = Tx('وقت الوصول المتوقع', 'Expected arrival time');
  static const canChangeLater = Tx('يمكنك تعديل الموعد لاحقًا إذا تغيّرت خطتك.', 'You can change the time later if your plans change.');
  static const arrivalNotDecided = Tx('لم أحدد موعد الوصول بعد', "I haven't set an arrival time yet");

  /// أسماء الأشهر (يناير ← ديسمبر) لعجلة اختيار التاريخ
  static const months = [
    Tx('يناير', 'January'),
    Tx('فبراير', 'February'),
    Tx('مارس', 'March'),
    Tx('أبريل', 'April'),
    Tx('مايو', 'May'),
    Tx('يونيو', 'June'),
    Tx('يوليو', 'July'),
    Tx('أغسطس', 'August'),
    Tx('سبتمبر', 'September'),
    Tx('أكتوبر', 'October'),
    Tx('نوفمبر', 'November'),
    Tx('ديسمبر', 'December'),
  ];
}
