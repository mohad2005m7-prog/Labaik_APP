import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/json_fields.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../auth/data/token_refresher.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation_summary.dart';
import '../models/chat_message_json.dart';
import '../models/conversation_summary_json.dart';

// -------------------------------------------------------------
// طلبات المحادثات لسيرفر لبيك (تحت /api/v1 — كلها بـ Bearer token):
//   GET  /chats                                      → [ConversationDto]  (محادثات المستخدم: المشرف، المجموعة، الأفراد)
//   GET  /chats/{conversationId}/messages?afterId=   → [MessageDto]
//   POST /chats/{conversationId}/messages            → MessageDto     body: { clientId, text, latitude, longitude }
//   POST /chats/{conversationId}/read                → 204
//   POST /chats/direct                               → ConversationDto  body: { userId }
// التفاصيل الكاملة للباك إند: docs/backend_help_center.md
// -------------------------------------------------------------
class ChatApi {
  final ApiClient _client;

  ChatApi(this._client);

  factory ChatApi.server() => ChatApi(ApiClient(baseUrl: ApiConfig.baseUrl, accessToken: TokenStorage.getAccessToken, refreshToken: TokenRefresher.refresh));

  static const _idClaims = ['sub', 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier', 'nameid', 'userId', 'id'];

  /// رقم المستخدم من الـ JWT (لتمييز رسائله لو السيرفر ما بعت isMine)
  static Future<String?> myUserId() async {
    final claims = await TokenStorage.accessTokenClaims();
    if (claims == null) return null;
    for (final key in _idClaims) {
      final value = claims[key];
      if (value != null) return value.toString();
    }
    return null;
  }

  static String _path(String conversationId) => '/chats/${Uri.encodeComponent(conversationId)}';

  Future<List<ConversationSummary>> conversations() async {
    final data = unwrapData(await _client.getJson('/chats'));
    if (data is! List) return const [];
    final me = await myUserId();
    return [for (final item in data.whereType<Map<String, dynamic>>()) ConversationSummaryJson.fromJson(item, myUserId: me)];
  }

  Future<List<ChatMessage>> messages(String conversationId, {String? afterId}) async {
    final data = unwrapData(await _client.getJson('${_path(conversationId)}/messages', query: {'afterId': ?afterId}));
    if (data is! List) return const [];
    final me = await myUserId();
    return [for (final item in data.whereType<Map<String, dynamic>>()) ChatMessageJson.fromJson(item, myUserId: me)];
  }

  Future<ChatMessage> send(String conversationId, {required String clientId, String? text, GeoPoint? location}) async {
    final data = unwrapData(await _client.postJson('${_path(conversationId)}/messages', body: {'clientId': clientId, 'text': text, 'latitude': location?.latitude, 'longitude': location?.longitude}));
    if (data is! Map<String, dynamic>) throw const FormatException('Expected the saved message');
    // رسالتي أكيد — حتى لو السيرفر ما رجّع isMine أو clientId
    final saved = ChatMessageJson.fromJson(data);
    return ChatMessage(
      id: saved.id,
      clientId: clientId,
      conversationId: saved.conversationId ?? conversationId,
      fromMe: true,
      text: saved.text ?? text,
      location: saved.location ?? location,
      sentAt: saved.sentAt,
    );
  }

  Future<ConversationSummary> startDirect(String userId) async {
    final data = unwrapData(await _client.postJson('/chats/direct', body: {'userId': userId}));
    if (data is! Map<String, dynamic>) throw const FormatException('Expected the conversation');
    return ConversationSummaryJson.fromJson(data, myUserId: await myUserId());
  }

  Future<void> markRead(String conversationId) => _client.postJson('${_path(conversationId)}/read');
}
