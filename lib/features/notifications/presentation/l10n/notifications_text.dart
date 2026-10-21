import '../../../../core/l10n/tx.dart';
import '../../domain/entities/app_notification.dart';

/// نصوص شاشة الإشعارات (Figma "الاشعارات" 114:10192)
abstract final class NotificationsText {
  static const title = Tx('الإشعارات', 'Notifications');

  // عناوين الأيام (Figma: "اليوم" و"الأمس 9:40")
  static const today = Tx('اليوم', 'Today');
  static String yesterdayAt(Object time) => tr('الأمس $time', 'Yesterday $time');

  // كرت "إعلان جديد للمجموعة" (Group 36809)
  static const announcementTitle = Tx('إعلان جديد للمجموعة', 'New group announcement');
  static const announcementBody = Tx('أضاف المشرف إعلانًا جديدًا يخص أفراد المجموعة.', 'Your supervisor added a new announcement for the group.');

  // باقي الأنواع (مش بـ Figma — نفس الكرت)
  static const gatheringPoint = Tx('تم تحديث نقطة التجمع', 'Gathering point updated');
  static const groupMessage = Tx('رسالة جديدة في المجموعة', 'New group message');
  static const supervisorMessage = Tx('رسالة جديدة من المشرف', 'New message from the supervisor');
  static const lostChild = Tx('بلاغ عن طفل مفقود بالقرب منك', 'Lost child reported near you');
  static const familyJoined = Tx('انضم فرد جديد لعائلتك', 'A new member joined your family');
  static const other = Tx('إشعار جديد', 'New notification');

  /// العنوان والنص حسب النوع (النص من السيرفر لما يكون في)
  static ({String title, String body}) of(NotificationKind kind, String preview) => switch (kind) {
        NotificationKind.announcement => (title: announcementTitle(), body: announcementBody()),
        NotificationKind.gatheringPoint => (title: gatheringPoint(), body: preview),
        NotificationKind.groupMessage => (title: groupMessage(), body: preview),
        NotificationKind.supervisorMessage => (title: supervisorMessage(), body: preview),
        NotificationKind.lostChild => (title: lostChild(), body: preview),
        NotificationKind.familyJoined => (title: familyJoined(), body: preview),
        NotificationKind.memberJoined || NotificationKind.other => (title: other(), body: preview),
      };

  // مش بـ Figma: لما ما في إشعارات
  static const empty = Tx('لا توجد إشعارات بعد', 'No notifications yet');

  static const _ar = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  static const _en = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  /// الأيام الأقدم: "12 أكتوبر 2026"
  static String date(DateTime t) => '${t.day} ${(AppLanguage.isArabic ? _ar : _en)[t.month - 1]} ${t.year}';
}
