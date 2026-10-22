import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/json_fields.dart';
import '../../domain/entities/chat_message.dart';

// -------------------------------------------------------------
// رسالة دردشة المجموعة من السيرفر (ChatMessageDto) — من REST أو من حدث "MessageReceived":
// { "id", "groupId", "senderId", "senderName", "senderPhotoUrl"?, "body" (حتى 2000 حرف), "sentAtUtc" (ISO 8601 UTC),
//   "kind" (1 نص | 2 موقع), "latitude"?, "longitude"?, "isDeleted" }
// المحذوفة (المشرف أو كاتبها حذفها) بترجع من السيرفر بـ body فاضي — ما بنعرضها (بدل فقاعة فاضية)
// المحادثة = المجموعة نفسها (conversationId = groupId) — ورسالتي = senderId هو رقمي
// -------------------------------------------------------------
abstract final class GroupMessageJson {
  static bool isDeleted(Map<String, dynamic> json) => json.field('isDeleted') == true;

  static ChatMessage fromJson(Map<String, dynamic> json, {String? myUserId}) {
    final id = json.requireString('id');
    final senderId = json.field('senderId')?.toString();
    final name = json.field('senderName')?.toString().trim();
    final body = json.field('body')?.toString();
    final photo = json.field('senderPhotoUrl')?.toString().trim();
    final lat = json.field('latitude'), lng = json.field('longitude');
    return ChatMessage(
      id: id,
      clientId: id,
      conversationId: json.field('groupId')?.toString(),
      fromMe: senderId != null && senderId == myUserId,
      senderId: senderId,
      senderName: name == null || name.isEmpty ? null : name,
      senderPhotoUrl: photo == null || photo.isEmpty ? null : photo,
      text: body == null || body.isEmpty ? null : body,
      location: json.optionalInt('kind') == 2 && lat is num && lng is num ? GeoPoint(lat.toDouble(), lng.toDouble()) : null,
      sentAt: DateTime.tryParse(json.field('sentAtUtc')?.toString() ?? '')?.toLocal() ?? DateTime.now(),
    );
  }
}
