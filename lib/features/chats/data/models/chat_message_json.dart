import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/json_fields.dart';
import '../../domain/entities/chat_message.dart';

// -------------------------------------------------------------
// MessageDto من السيرفر (camelCase أو PascalCase):
// { "id", "conversationId", "clientId", "senderId", "senderName", "senderPhotoUrl", "isMine",
//   "text", "latitude", "longitude", "sentAt" (ISO 8601 UTC) }
// [myUserId]: رقم المستخدم من الـ JWT — لو السيرفر ما بعت isMine بنقارنه بـ senderId
// -------------------------------------------------------------
extension ChatMessageJson on ChatMessage {
  static ChatMessage fromJson(Map<String, dynamic> json, {String? myUserId}) {
    String? text(String name) {
      final value = json.field(name)?.toString();
      return value == null || value.isEmpty ? null : value;
    }

    final id = json.requireString('id');
    final isMine = json.field('isMine');
    final senderId = text('senderId');
    final lat = json.field('latitude'), lng = json.field('longitude');
    final status = text('status');
    return ChatMessage(
      id: id,
      clientId: text('clientId') ?? id,
      conversationId: text('conversationId'),
      fromMe: isMine is bool ? isMine : (senderId != null && senderId == myUserId),
      senderName: text('senderName'),
      senderPhotoUrl: text('senderPhotoUrl'),
      text: text('text'),
      location: lat is num && lng is num ? GeoPoint(lat.toDouble(), lng.toDouble()) : null,
      sentAt: DateTime.tryParse(text('sentAt') ?? '')?.toLocal() ?? DateTime.now(),
      // بالكاش المحلي بس: اللي ما وصل للسيرفر بيرجع "لم تُرسل" (إعادة المحاولة بالضغط)
      status: status == null || status == ChatMessageStatus.sent.name ? ChatMessageStatus.sent : ChatMessageStatus.failed,
    );
  }

  /// للكاش المحلي
  Map<String, dynamic> toJson() => {
    'id': id,
    'clientId': clientId,
    'conversationId': conversationId,
    'isMine': fromMe,
    'senderName': senderName,
    'senderPhotoUrl': senderPhotoUrl,
    'text': text,
    'latitude': location?.latitude,
    'longitude': location?.longitude,
    'sentAt': sentAt.toUtc().toIso8601String(),
    'status': status.name,
  };
}
