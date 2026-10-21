import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/utils/json_fields.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../auth/data/auth_session.dart';
import '../../../auth/data/token_refresher.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation_summary.dart';

// -------------------------------------------------------------
// الدردشة الفردية بين المعتمر ومشرفه (سيرفر لبيك /chats — للطرفين بس):
//   GET  /chats                              → ConversationDto[] { id, otherUserId, otherName, otherPhotoUrl?, lastMessage?, lastMessageAtUtc?, unreadCount }
//   POST /chats/direct { userId }            → ConversationDto (200 موجودة / 201 جديدة) — 403 Chat.NotAllowed لغير مشرفي/معتمريّ
//   GET  /chats/{id}/messages?before=&take=  → DirectMessageDto[] { id, conversationId, senderId, senderName?, body, sentAtUtc, isRead } من الأحدث للأقدم
//   POST /chats/{id}/messages { body }       → 201 DirectMessageDto
//   POST /chats/{id}/messages/read           → 204
// الجديد لحظياً: "DirectMessageReceived" على /hubs/events (نفس اتصال المجموعة)
// -------------------------------------------------------------
class ChatApi {
  final ApiClient _client;

  ChatApi(this._client);

  factory ChatApi.server() => ChatApi(ApiClient(baseUrl: ApiConfig.baseUrl, accessToken: TokenStorage.getAccessToken, refreshToken: TokenRefresher.refresh));

  static String _path(String conversationId) => '/chats/${Uri.encodeComponent(conversationId)}';

  Future<List<ConversationSummary>> conversations() async {
    final data = unwrapData(await _client.getJson('/chats'));
    if (data is! List) return const [];
    return [for (final item in data.whereType<Map<String, dynamic>>()) conversation(item)];
  }

  /// محادثتي مع [userId] (مشرفي أو معتمر بمجموعتي) — السيرفر بيعملها لو مش موجودة
  Future<ConversationSummary> start(String userId) async {
    final data = unwrapData(await _client.postJson('/chats/direct', body: {'userId': userId}));
    if (data is! Map<String, dynamic>) throw const FormatException('Expected the conversation');
    return conversation(data);
  }

  /// الأحدث [take] رسالة (أو الأقدم من [before]) — مرتبة من الأقدم للأحدث
  Future<List<ChatMessage>> messages(String conversationId, {DateTime? before, int take = 50}) async {
    final data = unwrapData(await _client.getJson('${_path(conversationId)}/messages', query: {
      'take': '$take',
      if (before != null) 'before': before.toUtc().toIso8601String(),
    }));
    if (data is! List) return const [];
    final me = await AuthSession.userId();
    return [for (final item in data.whereType<Map<String, dynamic>>()) message(item, myUserId: me)].reversed.toList();
  }

  Future<ChatMessage> send(String conversationId, String body) async {
    final data = unwrapData(await _client.postJson('${_path(conversationId)}/messages', body: {'body': body}));
    if (data is! Map<String, dynamic>) throw const FormatException('Expected the saved message');
    return message(data, myUserId: await AuthSession.userId());
  }

  Future<void> markRead(String conversationId) => _client.postJson('${_path(conversationId)}/messages/read');

  /// ConversationDto → صف بقائمة الدردشات (العنوان = اسم الطرف التاني)
  static ConversationSummary conversation(Map<String, dynamic> json) {
    final id = json.requireString('id');
    final last = json.field('lastMessage')?.toString();
    final at = DateTime.tryParse(json.field('lastMessageAtUtc')?.toString() ?? '')?.toLocal();
    final photo = json.field('otherPhotoUrl')?.toString().trim();
    return ConversationSummary(
      id: id,
      title: json.field('otherName')?.toString() ?? '',
      photoUrl: photo == null || photo.isEmpty ? null : photo,
      otherUserId: json.field('otherUserId')?.toString(),
      unreadCount: json.optionalInt('unreadCount') ?? 0,
      lastMessage: last == null || last.isEmpty || at == null ? null : ChatMessage(id: '$id-last', clientId: '$id-last', conversationId: id, fromMe: false, text: last, sentAt: at),
    );
  }

  /// DirectMessageDto → رسالة (رسالتي = senderId هو رقمي)
  static ChatMessage message(Map<String, dynamic> json, {String? myUserId}) {
    final id = json.requireString('id');
    final senderId = json.field('senderId')?.toString();
    final name = json.field('senderName')?.toString().trim();
    final body = json.field('body')?.toString();
    return ChatMessage(
      id: id,
      clientId: id,
      conversationId: json.field('conversationId')?.toString(),
      fromMe: senderId != null && senderId == myUserId,
      senderId: senderId,
      senderName: name == null || name.isEmpty ? null : name,
      text: body == null || body.isEmpty ? null : body,
      sentAt: DateTime.tryParse(json.field('sentAtUtc')?.toString() ?? '')?.toLocal() ?? DateTime.now(),
    );
  }
}
