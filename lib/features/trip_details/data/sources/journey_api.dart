import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../auth/data/token_refresher.dart';

// -------------------------------------------------------------
// رحلة المعتمر على السيرفر:
//   POST /journeys        → 201 { id }  (الرحلة كاملة من إعداد الحساب)
//   GET  /journeys/me     → JourneyDto  (404 = ما عنده رحلة)
//   PUT  /journeys/{id}   → JourneyDto  (تعديل — 409 بعد بدء الرحلة، ونوع الرحلة ما بيتعدّل)
// -------------------------------------------------------------
class JourneyApi {
  final ApiClient _client;

  JourneyApi(this._client);

  factory JourneyApi.server() => JourneyApi(ApiClient(baseUrl: ApiConfig.baseUrl, accessToken: TokenStorage.getAccessToken, refreshToken: TokenRefresher.refresh));

  /// رقم الرحلة الجديدة
  Future<String> create(Map<String, Object?> body) async {
    final data = await _client.postJson('/journeys', body: body);
    final id = data is Map<String, dynamic> ? data['id']?.toString() : null;
    if (id == null || id.isEmpty) throw const FormatException('Expected the journey id');
    return id;
  }

  /// رحلتي — null لو ما عندي رحلة
  Future<Map<String, dynamic>?> mine() async {
    try {
      final data = await _client.getJson('/journeys/me');
      return data is Map<String, dynamic> ? data : null;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> update(String id, Map<String, Object?> body) {
    final request = {...body}..remove('pilgrimageType');
    return _client.putJson('/journeys/${Uri.encodeComponent(id)}', body: request);
  }
}
