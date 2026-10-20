import '../../../../core/utils/json_fields.dart';
import '../../domain/entities/chat_message.dart';

// -------------------------------------------------------------
// رسالة دردشة المجموعة من السيرفر (ChatMessageDto) — من REST أو من حدث "MessageReceived":
// { "id", "groupId", "senderId", "senderName", "body" (حتى 2000 حرف), "sentAtUtc" (ISO 8601 UTC) }
// المحادثة = المجموعة نفسها (conversationId = groupId) — ورسالتي = senderId هو رقمي
// -------------------------------------------------------------
abstract final class GroupMessageJson {
  static ChatMessage fromJson(Map<String, dynamic> json, {String? myUserId}) {
    final id = json.requireString('id');
    final senderId = json.field('senderId')?.toString();
    final name = json.field('senderName')?.toString().trim();
    final body = json.field('body')?.toString();
    return ChatMessage(
      id: id,
      clientId: id,
      conversationId: json.field('groupId')?.toString(),
      fromMe: senderId != null && senderId == myUserId,
      senderName: name == null || name.isEmpty ? null : name,
      text: body == null || body.isEmpty ? null : body,
      sentAt: DateTime.tryParse(json.field('sentAtUtc')?.toString() ?? '')?.toLocal() ?? DateTime.now(),
    );
  }
}
