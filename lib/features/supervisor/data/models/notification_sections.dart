import '../../../../core/utils/json_fields.dart';
import '../../domain/entities/supervisor_inbox.dart';
import '../../presentation/l10n/sup_notifications_text.dart';
import '../../presentation/widgets/supervisor_format.dart';

// -------------------------------------------------------------
// إشعارات السيرفر (NotificationDto — من الأحدث) → أقسام شاشة الإشعارات حسب اليوم ("اليوم"، "الأمس"، التاريخ)
// { "id", "type" (1 إعلان · 2 انضمام عضو · 7 وصول معتمر · 8/9 رسالة مجموعة · 10 طوارئ · 11 طفل مفقود · 15 رسالة خاصة · 16/17 إيقاف/تفعيل حسابي), "groupId", "referenceId", "preview", "createdAtUtc", "isRead" }
// الجملة من التطبيق حسب النوع، وأي نوع جديد بيطلع "إشعار جديد" مع نصه (ما بنخفي إشعار)
// [groupName]: اسم مجموعتي (تحت "انضم … إلى مجموعتك")
// -------------------------------------------------------------
abstract final class NotificationSections {
  static List<NotificationSection> fromJson(List<Map<String, dynamic>> items, {String? groupId, String? groupName, DateTime? now}) {
    // حسب اليوم (الإشعارات جاية من الأحدث) — والعنوان من أحدث إشعار فيه ("الأمس 9:40")
    final sections = <int, (String, List<SupervisorNotification>)>{};
    for (final json in items) {
      final preview = json.field('preview')?.toString().trim() ?? '';
      final SupervisorNotification item;
      switch (json.optionalInt('type')) {
        case 1:
          item = SupervisorNotification(title: SupNotificationsText.newAnnouncement(), body: preview);
        case 2:
          item = SupervisorNotification(title: SupNotificationsText.memberJoined(preview), body: _group(json, groupId, groupName));
        case 7:
          item = SupervisorNotification(title: SupNotificationsText.pilgrimArrived(preview), body: _group(json, groupId, groupName));
        case 8:
          item = SupervisorNotification(title: SupNotificationsText.groupMessage(), body: preview);
        case 9:
          item = SupervisorNotification(title: SupNotificationsText.supervisorMessage(), body: preview);
        case 10:
          item = SupervisorNotification(title: SupNotificationsText.emergency(preview), body: _group(json, groupId, groupName), important: true);
        case 11:
          item = SupervisorNotification(title: SupNotificationsText.lostChild(), body: preview, important: true);
        case 15:
          item = SupervisorNotification(title: SupNotificationsText.directMessage(), body: preview);
        case 16:
          item = SupervisorNotification(title: SupNotificationsText.suspended(), body: preview, important: true);
        case 17:
          item = SupervisorNotification(title: SupNotificationsText.reactivated(), body: preview);
        default:
          item = SupervisorNotification(title: SupNotificationsText.other(), body: preview);
      }
      final at = DateTime.tryParse(json.field('createdAtUtc')?.toString() ?? '')?.toLocal() ?? DateTime.now();
      sections.putIfAbsent(SupFormat.daysAgo(at, now: now), () => (_label(at, now), [])).$2.add(item);
    }
    return [for (final s in sections.values) NotificationSection(label: s.$1, items: s.$2)];
  }

  /// اسم مجموعتي لو الإشعار عنها
  static String _group(Map<String, dynamic> json, String? groupId, String? groupName) => groupName != null && json.field('groupId')?.toString() == groupId ? groupName : '';

  // زي Figma: "اليوم" و"الأمس 9:40" — والأقدم بالتاريخ
  static String _label(DateTime at, DateTime? now) => switch (SupFormat.daysAgo(at, now: now)) {
        0 => SupNotificationsText.today(),
        1 => SupNotificationsText.yesterdayAt('${at.hour % 12 == 0 ? 12 : at.hour % 12}:${at.minute.toString().padLeft(2, '0')}'),
        _ => SupFormat.date(at),
      };
}
