import '../../../../core/l10n/tx.dart';

/// نصوص إشعارات الشركة (Figma 751:4011)
abstract final class CompanyNotificationsText {
  static const title = Tx('الإشعارات', 'Notifications');
  static const today = Tx('اليوم', 'Today');
  static String yesterdayAt(Object time) => tr('الأمس $time', 'Yesterday $time');

  // مش بـ Figma: ما في إشعارات
  static const empty = Tx('لا توجد إشعارات بعد', 'No notifications yet');

  // عناوين الإشعار حسب نوعه (NotificationType) — زي Figma
  static const groupCreated = Tx('تم إنشاء مجموعة جديدة', 'New group created');
  static const supervisorActivated = Tx('تم تفعيل حساب مشرف', 'Supervisor activated');
  static const groupWithoutSupervisor = Tx('مجموعة بدون مشرف', 'Group without a supervisor');
  static const memberAdded = Tx('أضاف المشرف معتمراً للمجموعة', 'A supervisor added a pilgrim');
  static const memberRemoved = Tx('أزال المشرف معتمراً من المجموعة', 'A supervisor removed a pilgrim');
  static const other = Tx('إشعار جديد', 'New notification');

  static String titleFor(int type) => switch (type) {
        3 => groupCreated(),
        4 => supervisorActivated(),
        5 => groupWithoutSupervisor(),
        13 => memberAdded(),
        14 => memberRemoved(),
        _ => other(),
      };

  static const _ar = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  static const _en = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  /// الأيام الأقدم: "12 أكتوبر 2026"
  static String date(DateTime t) => '${t.day} ${(AppLanguage.isArabic ? _ar : _en)[t.month - 1]} ${t.year}';
}
