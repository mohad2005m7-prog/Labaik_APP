import '../../../../core/l10n/tx.dart';

/// نصوص شاشة برنامج الرحلة
abstract final class TripProgramText {
  static const title = Tx('برنامج الرحلة', 'Trip program');
  static String day(Object n) => tr('اليوم ($n)', 'Day ($n)');
}
