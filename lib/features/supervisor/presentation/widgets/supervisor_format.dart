import '../../../../core/l10n/app_language.dart';
import '../l10n/sup_time_text.dart';

// تنسيق تاريخ ووقت الإعلان الجديد بنفس شكل Figma:
//   الكرت: "اليوم، 8:30 ص" — التفاصيل: "12 أكتوبر 2026" و "08:30 صباحًا"
class SupFormat {
  static const _ar = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  static const _en = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  static bool get _isAr => AppLanguage.code == 'ar';

  static String date(DateTime t) => '${t.day} ${(_isAr ? _ar : _en)[t.month - 1]} ${t.year}';

  static int _hour12(DateTime t) => t.hour % 12 == 0 ? 12 : t.hour % 12;

  static String _minutes(DateTime t) => t.minute.toString().padLeft(2, '0');

  /// "8:30 ص"
  static String shortTime(DateTime t) => '${_hour12(t)}:${_minutes(t)} ${(t.hour < 12 ? SupTimeText.amShort : SupTimeText.pmShort)()}';

  /// "08:30 صباحًا"
  static String longTime(DateTime t) => '${_hour12(t).toString().padLeft(2, '0')}:${_minutes(t)} ${(t.hour < 12 ? SupTimeText.amLong : SupTimeText.pmLong)()}';

  /// "اليوم، 8:30 ص"
  static String today(DateTime t) => SupTimeText.todayAt(shortTime(t));

  /// "10 أكتوبر"
  static String dayMonth(DateTime t) => '${t.day} ${(_isAr ? _ar : _en)[t.month - 1]}';

  /// كم يوم بين [t] واليوم (0 = اليوم، 1 = أمس)
  static int daysAgo(DateTime t, {DateTime? now}) {
    final n = now ?? DateTime.now();
    return DateTime(n.year, n.month, n.day).difference(DateTime(t.year, t.month, t.day)).inDays;
  }

  /// كرت الإعلان (زي Figma): "اليوم، 8:30 ص" / "أمس، 6:00 م" / "10 أكتوبر"
  static String when(DateTime t, {DateTime? now}) => switch (daysAgo(t, now: now)) {
        0 => today(t),
        1 => SupTimeText.yesterdayAt(shortTime(t)),
        _ => dayMonth(t),
      };

  /// وقت صف الدردشة (زي Figma "9:12 AM") — والأقدم من اليوم بالتاريخ
  static String chatTime(DateTime t, {DateTime? now}) =>
      daysAgo(t, now: now) == 0 ? '${_hour12(t)}:${_minutes(t)} ${t.hour < 12 ? 'AM' : 'PM'}' : '${t.day}/${t.month}';
}
