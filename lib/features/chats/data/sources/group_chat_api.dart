import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../auth/data/auth_session.dart';
import '../../../auth/data/token_refresher.dart';
import '../../../group/data/sources/group_api.dart';
import '../../domain/entities/chat_message.dart';
import '../models/group_message_json.dart';

// -------------------------------------------------------------
// دردشة المجموعة (للأعضاء بس — غير العضو بياخد 404):
//   GET  /groups/{groupId}/messages?before=&take=  → من الأحدث للأقدم (before = sentAtUtc لأقدم رسالة وصلت، take 1..100)
//   POST /groups/{groupId}/messages  { body }       → 201 ChatMessageDto
// الإرسال عبر REST (حتى يوصل تأكيد 201) — والرسالة بترجع كمان عبر "MessageReceived" (التكرار بينشال بالـ id)
// -------------------------------------------------------------
class GroupChatApi {
  final ApiClient _client;

  GroupChatApi(this._client);

  factory GroupChatApi.server() => GroupChatApi(ApiClient(baseUrl: ApiConfig.baseUrl, accessToken: TokenStorage.getAccessToken, refreshToken: TokenRefresher.refresh));

  /// الأحدث [take] رسالة (أو الأقدم من [before]) — مرتبة من الأقدم للأحدث
  Future<List<ChatMessage>> messages(String groupId, {DateTime? before, int take = 50}) async {
    final data = await _client.getJson('${GroupApi.path(groupId)}/messages', query: {
      'take': '$take',
      if (before != null) 'before': before.toUtc().toIso8601String(),
    });
    if (data is! List) return const [];
    final me = await AuthSession.userId();
    return [for (final item in data.whereType<Map<String, dynamic>>()) GroupMessageJson.fromJson(item, myUserId: me)].reversed.toList();
  }

  /// كل الرسائل لحد هلق صارت مقروءة إلي (POST /groups/{id}/messages/read → 204)
  Future<void> markRead(String groupId) => _client.postJson('${GroupApi.path(groupId)}/messages/read');

  Future<ChatMessage> send(String groupId, String body) async {
    final data = await _client.postJson('${GroupApi.path(groupId)}/messages', body: {'body': body});
    if (data is! Map<String, dynamic>) throw const FormatException('Expected the saved message');
    return GroupMessageJson.fromJson(data, myUserId: await AuthSession.userId());
  }
}
