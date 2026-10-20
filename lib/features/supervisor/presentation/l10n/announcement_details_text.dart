import '../../../../core/l10n/tx.dart';

/// نصوص شاشة تفاصيل الإعلان
abstract final class AnnouncementDetailsText {
  static const title = Tx('تفاصيل الإعلان', 'Announcement details');
  static const forGroup = Tx('إعلان مهم للمجموعة', 'Important announcement for the group');
  static const targetGroup = Tx('المجموعة المستهدفة', 'Target group');
  static const sendDate = Tx('تاريخ الإرسال', 'Send date');
  static const sendTime = Tx('وقت الإرسال', 'Send time');
  static const body = Tx('نص الإعلان', 'Announcement text');
  static const back = Tx('العودة إلى الإعلانات', 'Back to announcements');
}
