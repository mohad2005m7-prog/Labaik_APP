import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../auth/data/token_refresher.dart';
import '../../../group/data/sources/group_api.dart';

// -------------------------------------------------------------
// إعلانات المجموعة (AnnouncementDto: id, groupId, title, body, authorId, authorName, createdAtUtc, isRead):
//   GET  /groups/{groupId}/announcements  → من الأحدث (للأعضاء)
//   POST /groups/{groupId}/announcements  { title, body } → 201 — لمشرف المجموعة بس (العضو بياخد 403)
// -------------------------------------------------------------
class AnnouncementsApi {
  final ApiClient _client;

  AnnouncementsApi(this._client);

  factory AnnouncementsApi.server() => AnnouncementsApi(ApiClient(baseUrl: ApiConfig.baseUrl, accessToken: TokenStorage.getAccessToken, refreshToken: TokenRefresher.refresh));

  Future<List<Map<String, dynamic>>> list(String groupId) async {
    final data = await _client.getJson('${GroupApi.path(groupId)}/announcements');
    return data is List ? data.whereType<Map<String, dynamic>>().toList() : const [];
  }

  Future<Map<String, dynamic>> post(String groupId, {required String title, required String body}) async {
    final data = await _client.postJson('${GroupApi.path(groupId)}/announcements', body: {'title': title, 'body': body});
    if (data is! Map<String, dynamic>) throw const FormatException('Expected the saved announcement');
    return data;
  }
}
