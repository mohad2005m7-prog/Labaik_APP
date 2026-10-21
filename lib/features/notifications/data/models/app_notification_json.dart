import '../../../../core/utils/json_fields.dart';
import '../../domain/entities/app_notification.dart';

// -------------------------------------------------------------
// NotificationDto من السيرفر (الـ enums أرقام):
// { "id", "type" (1 إعلان · 2 انضمام عضو · 6 نقطة تجمع · 8/9 رسالة · 11 طفل مفقود · 12 انضمام للعائلة), "groupId", "referenceId", "preview", "createdAtUtc", "isRead" }
// أي نوع جديد بالسيرفر → NotificationKind.other (ما بنخفي إشعار) — null بس لو ما في type
// -------------------------------------------------------------
abstract final class AppNotificationJson {
  static AppNotification? fromJson(Map<String, dynamic> json) {
    final type = json.optionalInt('type');
    if (type == null) return null;
    final kind = switch (type) {
      1 => NotificationKind.announcement,
      2 => NotificationKind.memberJoined,
      6 => NotificationKind.gatheringPoint,
      8 => NotificationKind.groupMessage,
      9 => NotificationKind.supervisorMessage,
      11 => NotificationKind.lostChild,
      12 => NotificationKind.familyJoined,
      _ => NotificationKind.other,
    };
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
