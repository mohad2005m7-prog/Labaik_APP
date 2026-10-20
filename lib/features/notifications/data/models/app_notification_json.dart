import '../../../../core/utils/json_fields.dart';
import '../../domain/entities/app_notification.dart';

// -------------------------------------------------------------
// NotificationDto من السيرفر (الـ enums أرقام):
// { "id", "type" (1 AnnouncementPosted · 2 MemberJoinedGroup), "groupId", "referenceId", "preview", "createdAtUtc", "isRead" }
// null = نوع ما بنعرفه (ممكن ينضاف أنواع جديدة بدون إصدار جديد من الـ API — بنتجاهلها)
// -------------------------------------------------------------
abstract final class AppNotificationJson {
  static AppNotification? fromJson(Map<String, dynamic> json) {
    final kind = switch (json.optionalInt('type')) {
      1 => NotificationKind.announcement,
      2 => NotificationKind.memberJoined,
      _ => null,
    };
    if (kind == null) return null;
    String? text(String name) {
      final value = json.field(name)?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    return AppNotification(
      id: json.requireString('id'),
      kind: kind,
      groupId: text('groupId'),
      referenceId: text('referenceId'),
      preview: text('preview') ?? '',
      createdAt: DateTime.tryParse(text('createdAtUtc') ?? '')?.toLocal() ?? DateTime.now(),
      isRead: json.field('isRead') == true,
    );
  }
}
