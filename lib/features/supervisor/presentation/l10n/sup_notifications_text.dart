import '../../../../core/l10n/tx.dart';

/// نصوص شاشة الإشعارات
abstract final class SupNotificationsText {
  static const title = Tx('الإشعارات', 'Notifications');

  // عناوين الأوقات (زي Figma "اليوم" و"الأمس 9:40")
  static const today = Tx('اليوم', 'Today');
  static String yesterdayAt(Object time) => tr('الأمس $time', 'Yesterday $time');

  // السيرفر بيبعت نوع الإشعار ونص قصير (preview) — الجملة من التطبيق (حسب ملف السيرفر)
  /// 1 AnnouncementPosted — preview = عنوان الإعلان
  static const newAnnouncement = Tx('إعلان جديد', 'New announcement');

  /// 2 MemberJoinedGroup — preview = اسم العضو
  static String memberJoined(Object name) => tr('انضم $name إلى مجموعتك', '$name joined your group');
}
