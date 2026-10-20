import '../../../../core/utils/json_fields.dart';
import '../../domain/entities/announcement.dart';
import '../../presentation/widgets/supervisor_format.dart';

// -------------------------------------------------------------
// إعلان من السيرفر (AnnouncementDto) → كرت "إعلانات سابقة" وتفاصيله:
// { "id", "groupId", "title", "body", "authorId", "authorName", "createdAtUtc", "isRead" }
// السيرفر ما بيحفظ نوع الإعلان (مهم) ولا المرفق — فبناخدهم من نسخة الجهاز للإعلانات اللي أرسلها المشرف من هالجهاز ([local])
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
      type: local?.type ?? AnnouncementType.normal,
      icon: local?.icon ?? AnnouncementIcon.group,
      dateLabel: SupFormat.date(at),
      timeLabel: SupFormat.longTime(at),
      attachment: local?.attachment,
    );
  }
}
