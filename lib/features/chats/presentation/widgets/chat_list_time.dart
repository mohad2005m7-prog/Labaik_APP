import '../l10n/conversation_text.dart';

// -------------------------------------------------------------
// وقت آخر رسالة بقائمة المحادثات — زي iOS و Figma ("9:12 AM"):
// اليوم → "9:12 AM" — مبارح → "Yesterday" — هالأسبوع → "Monday" — أقدم → "12/10/26"
// -------------------------------------------------------------
abstract final class ChatListTime {
  static const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  static String format(DateTime? time, {DateTime? now}) {
    if (time == null) return '';
    final today = now ?? DateTime.now();
    final days = DateTime(today.year, today.month, today.day).difference(DateTime(time.year, time.month, time.day)).inDays;
    if (days <= 0) {
      final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
      return '$hour:${time.minute.toString().padLeft(2, '0')} ${time.hour < 12 ? 'AM' : 'PM'}';
    }
    if (days == 1) return ConversationText.yesterday();
    if (days < 7) return _weekdays[time.weekday - 1];
    return '${time.day}/${time.month}/${time.year % 100}';
  }
}
