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

  /// 7 PilgrimArrived — preview = اسم المعتمر
  static String pilgrimArrived(Object name) => tr('وصل $name إلى نقطة التجمع', '$name reached the gathering point');

  /// 8 GroupMessagePosted — preview = نص الرسالة
  static const groupMessage = Tx('رسالة جديدة في المجموعة', 'New group message');

  /// 9 SupervisorMessagePosted
  static const supervisorMessage = Tx('رسالة جديدة من المشرف', 'New message from the supervisor');

  /// 10 EmergencyReported — preview = اسم المعتمر
  static String emergency(Object name) => tr('بلاغ طوارئ من $name', 'Emergency alert from $name');

  /// 11 LostChildReported — preview = الوصف
  static const lostChild = Tx('بلاغ عن طفل مفقود', 'Lost child report');

  /// 15 DirectMessageReceived — preview = نص الرسالة
  static const directMessage = Tx('رسالة خاصة جديدة', 'New direct message');

  /// 16 / 17 — preview = اسم الشركة
  static const suspended = Tx('تم إيقاف حسابك كمشرف', 'Your supervisor account was suspended');
  static const reactivated = Tx('تمت إعادة تفعيل حسابك كمشرف', 'Your supervisor account was reactivated');

  /// أي نوع تاني (أو جديد بالسيرفر)
  static const other = Tx('إشعار جديد', 'New notification');
}
