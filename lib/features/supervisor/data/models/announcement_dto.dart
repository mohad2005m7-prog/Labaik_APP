import '../../../../core/utils/json_fields.dart';
import '../../domain/entities/announcement.dart';
import '../../presentation/widgets/supervisor_format.dart';

// -------------------------------------------------------------
// إعلان من السيرفر (AnnouncementDto) → كرت "إعلانات سابقة" وتفاصيله:
// { "id", "groupId", "title", "body", "authorId", "authorName", "createdAtUtc", "isRead" }
// "importance": 2 = مهم (من السيرفر) — المرفق لسا مش بالسيرفر فبناخده من نسخة الجهاز ([local])
// -------------------------------------------------------------
abstract final class AnnouncementDto {
  static Announcement fromJson(Map<String, dynamic> json, {required String target, Announcement? local, DateTime? now}) {
    final body = json.field('body')?.toString() ?? '';
    final at = DateTime.tryParse(json.field('createdAtUtc')?.toString() ?? '')?.toLocal() ?? DateTime.now();
    return Announcement(
      id: json.requireString('id'),
      title: json.field('title')?.toString() ?? '',
      target: local?.target ?? target,
      whenLabel: SupFormat.when(at, now: now),
      summary: body.split('\n').first,
      body: body,
      type: switch (json.field('importance')) { 2 => AnnouncementType.important, 1 => AnnouncementType.normal, _ => local?.type ?? AnnouncementType.normal },
      icon: local?.icon ?? AnnouncementIcon.group,
      dateLabel: SupFormat.date(at),
      timeLabel: SupFormat.longTime(at),
      attachment: local?.attachment,
    );
  }
}
