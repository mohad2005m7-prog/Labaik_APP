import '../../../../core/l10n/tx.dart';

/// نصوص قائمة الاختيار (مش مصممة بـ Figma)
abstract final class TripPickerText {
  /// اختيار اللي كتبه بالبحث لما مش موجود بالقائمة
  static String useTyped(String text) => tr('استخدام «$text»', 'Use “$text”');
}
