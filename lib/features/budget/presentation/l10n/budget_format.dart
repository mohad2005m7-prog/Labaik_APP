import '../../../../core/l10n/tx.dart';

// -------------------------------------------------------------
// تنسيق المبالغ والأوقات زي Figma: "750 ر.س" — "1,000 ر.س" — "0.0 ر.س" — "−80 ر.س"
// "اليوم، 2:30 م" — "أمس، 6:00 م" — والأقدم بالتاريخ
// -------------------------------------------------------------
abstract final class BudgetFormat {
  static const currency = Tx('ر.س', 'SAR');

  // علامة الناقص: Figma "−" (U+2212) بخط SF Compact طولها ~7.5 — خط التطبيق ما فيه إلا شَرطة قصيرة (4.5)
  // فبنرسمها "–" (U+2013: 7.0 بـ Noto Sans Arabic)
  static const _minus = '–';

  /// الرقم: صفر = "0.0"، الصحيح بفواصل الآلاف، والكسر لخانتين
  static String number(double value) {
    final v = value.abs();
    if (v == 0) return '0.0';
    final fixed = v.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
    final parts = fixed.split('.');
    final whole = parts.first.replaceAllMapped(RegExp(r'\B(?=(\d{3})+$)'), (_) => ',');
    return parts.length > 1 ? '$whole.${parts[1]}' : whole;
  }

  /// "750 ر.س" (والسالب "−50 ر.س")
  static String money(double value) => '${value < 0 ? _minus : ''}${number(value)} ${currency()}';

  /// مبلغ مصروف بالقائمة: "−80 ر.س"
  static String expense(double amount) => '$_minus${number(amount)} ${currency()}';

  /// "0.00 ر.س" (placeholder حقل المبلغ)
  static String amountHint() => '0.00 ${currency()}';

  static String day(DateTime at) {
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day).difference(DateTime(at.year, at.month, at.day)).inDays;
    return switch (days) {
      0 => tr('اليوم', 'Today'),
      1 => tr('أمس', 'Yesterday'),
      _ => '${at.day}/${at.month}/${at.year}',
    };
  }

  /// "2:30 م"
  static String time(DateTime at) {
    final hour = at.hour % 12 == 0 ? 12 : at.hour % 12;
    final minute = at.minute.toString().padLeft(2, '0');
    final am = at.hour < 12;
    return '$hour:$minute ${am ? tr('ص', 'AM') : tr('م', 'PM')}';
  }

  /// "اليوم، 2:30 م"
  static String dayTime(DateTime at) => tr('${day(at)}، ${time(at)}', '${day(at)}, ${time(at)}');

  /// المبلغ اللي كتبه المستخدم (بأرقام عربية أو إنجليزية، "٫" أو "," أو ".") — null لو مش رقم موجب
  static double? parse(String input) {
    var s = input.trim().replaceAll(currency.ar, '').replaceAll(currency.en, '').replaceAll(' ', '');
    const eastern = '٠١٢٣٤٥٦٧٨٩', persian = '۰۱۲۳۴۵۶۷۸۹';
    for (var i = 0; i < 10; i++) {
      s = s.replaceAll(eastern[i], '$i').replaceAll(persian[i], '$i');
    }
    s = s.replaceAll('٫', '.').replaceAll('،', ',');
    // "12,5" فاصلة عشرية — "1,000" فاصلة آلاف
    s = !s.contains('.') && RegExp(r'^\d+,\d{1,2}$').hasMatch(s) ? s.replaceAll(',', '.') : s.replaceAll(',', '');
    final value = double.tryParse(s);
    return value == null || value <= 0 || value.isNaN || value.isInfinite ? null : value;
  }
}
