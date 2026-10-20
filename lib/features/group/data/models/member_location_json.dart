import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/json_fields.dart';
import '../../domain/entities/group_member.dart';

// -------------------------------------------------------------
// صف من GET /groups/{groupId}/locations (MemberLocationDto):
// { "userId", "fullName", "role" (1 Leader · 2 Member), "isSharing", "latitude", "longitude",
//   "accuracyMeters", "updatedAtUtc", "isStale" }
// الإحداثيات null لمن ما بيشارك — والموقع "قديم" (isStale) بعد 15 دقيقة: بيطلع "آخر ظهور" (ملف السيرفر)
// السيرفر ما فيه "متصل الآن" منفصل: المتصل = بيشارك وموقعه مش قديم
// -------------------------------------------------------------
extension MemberLocationJson on GroupMember {
  static GroupMember fromJson(Map<String, dynamic> json, {String? myUserId}) {
    final userId = json.requireString('userId');
    final sharing = json.field('isSharing') == true;
    final lat = json.field('latitude'), lng = json.field('longitude');
    final location = sharing && lat is num && lng is num ? GeoPoint(lat.toDouble(), lng.toDouble()) : null;
    final updatedAt = DateTime.tryParse(json.field('updatedAtUtc')?.toString() ?? '')?.toLocal();
    final stale = json.field('isStale') != false;
    final online = sharing && location != null && !stale;
    return GroupMember(
      userId: userId,
      name: json.field('fullName')?.toString().trim() ?? '',
      isMe: myUserId != null && userId == myUserId,
      isOnline: online,
      lastSeenAt: online ? null : updatedAt,
      sharesLocation: sharing,
      location: location,
      locationUpdatedAt: updatedAt,
      isSupervisor: json.optionalInt('role') == 1,
    );
  }
}
