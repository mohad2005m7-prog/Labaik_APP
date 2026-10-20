import '../../../../core/utils/json_fields.dart';
import '../../domain/entities/supervisor_inbox.dart';
import '../../presentation/l10n/sup_notifications_text.dart';
import '../../presentation/widgets/supervisor_format.dart';

// -------------------------------------------------------------
// إشعارات السيرفر (NotificationDto — من الأحدث) → أقسام شاشة الإشعارات حسب اليوم ("اليوم"، "الأمس"، التاريخ)
// { "id", "type" (1 AnnouncementPosted · 2 MemberJoinedGroup), "groupId", "referenceId", "preview", "createdAtUtc", "isRead" }
// الجملة من التطبيق حسب النوع، وأي نوع ما بنعرفه بنتجاهله (ممكن ينضاف أنواع جديدة بدون إصدار جديد)
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
          final group = groupName != null && json.field('groupId')?.toString() == groupId ? groupName : '';
          item = SupervisorNotification(title: SupNotificationsText.memberJoined(preview), body: group);
        default:
          continue;
      }
      final at = DateTime.tryParse(json.field('createdAtUtc')?.toString() ?? '')?.toLocal() ?? DateTime.now();
      sections.putIfAbsent(SupFormat.daysAgo(at, now: now), () => (_label(at, now), [])).$2.add(item);
    }
    return [for (final s in sections.values) NotificationSection(label: s.$1, items: s.$2)];
  }

  // زي Figma: "اليوم" و"الأمس 9:40" — والأقدم بالتاريخ
  static String _label(DateTime at, DateTime? now) => switch (SupFormat.daysAgo(at, now: now)) {
        0 => SupNotificationsText.today(),
        1 => SupNotificationsText.yesterdayAt('${at.hour % 12 == 0 ? 12 : at.hour % 12}:${at.minute.toString().padLeft(2, '0')}'),
        _ => SupFormat.date(at),
      };
}
