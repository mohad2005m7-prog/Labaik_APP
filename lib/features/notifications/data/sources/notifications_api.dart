import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../auth/data/token_refresher.dart';

// -------------------------------------------------------------
// إشعاراتي — للمعتمر والمشرف (NotificationDto: id, type, groupId, referenceId, preview, createdAtUtc, isRead):
//   GET  /notifications?before=&take=  → من الأحدث (before = createdAtUtc لأقدم إشعار وصل، take 1..100)
//   POST /notifications/read-all       → 204
// الجديد بيوصل لحظياً عبر "NotificationReceived" على /hubs/events
// -------------------------------------------------------------
class NotificationsApi {
  final ApiClient _client;

  NotificationsApi(this._client);

  factory NotificationsApi.server() => NotificationsApi(ApiClient(baseUrl: ApiConfig.baseUrl, accessToken: TokenStorage.getAccessToken, refreshToken: TokenRefresher.refresh));

  Future<List<Map<String, dynamic>>> list({int take = 50}) async {
    final data = await _client.getJson('/notifications', query: {'take': '$take'});
    return data is List ? data.whereType<Map<String, dynamic>>().toList() : const [];
  }

  Future<void> readAll() => _client.postJson('/notifications/read-all');
}
