import '../../../../core/l10n/tx.dart';

/// نصوص شاشة الإشعارات (Figma "الاشعارات" 114:10192)
abstract final class NotificationsText {
  static const title = Tx('الإشعارات', 'Notifications');

  // عناوين الأيام (Figma: "اليوم" و"الأمس 9:40")
  static const today = Tx('اليوم', 'Today');
  static String yesterdayAt(Object time) => tr('الأمس $time', 'Yesterday $time');

  // كرت "إعلان جديد للمجموعة" (Group 36809)
  static const announcementTitle = Tx('إعلان جديد للمجموعة', 'New group announcement');
  static const announcementBody = Tx('أضاف المشرف إعلانًا جديدًا يخص أفراد المجموعة.', 'Your supervisor added a new announcement for the group.');

  // مش بـ Figma: لما ما في إشعارات
  static const empty = Tx('لا توجد إشعارات بعد', 'No notifications yet');

  static const _ar = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  static const _en = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  /// الأيام الأقدم: "12 أكتوبر 2026"
  static String date(DateTime t) => '${t.day} ${(AppLanguage.isArabic ? _ar : _en)[t.month - 1]} ${t.year}';
}
