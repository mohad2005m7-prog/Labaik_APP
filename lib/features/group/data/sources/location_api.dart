import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../auth/data/token_refresher.dart';

// -------------------------------------------------------------
// مشاركة موقعي (مفتاح واحد — بيشوفه أعضاء مجموعتي):
//   GET  /location/me       → { isSharing, latitude, longitude, accuracyMeters, updatedAtUtc, isStale }
//   PUT  /location/sharing  { isSharing }  → الحالة (الإيقاف بيمسح موقعي)
//   POST /location          { latitude, longitude, accuracyMeters? } → 204 (و409 قبل تفعيل المشاركة)
// -------------------------------------------------------------
class LocationApi {
  final ApiClient _client;

  LocationApi(this._client);

  factory LocationApi.server() => LocationApi(ApiClient(baseUrl: ApiConfig.baseUrl, accessToken: TokenStorage.getAccessToken, refreshToken: TokenRefresher.refresh));

  Future<bool> isSharing() async {
    final data = await _client.getJson('/location/me');
    return data is Map<String, dynamic> && data['isSharing'] == true;
  }

  Future<void> setSharing(bool sharing) => _client.putJson('/location/sharing', body: {'isSharing': sharing});

  Future<void> send(GeoPoint point, {double? accuracyMeters}) =>
      _client.postJson('/location', body: {'latitude': point.latitude, 'longitude': point.longitude, 'accuracyMeters': ?accuracyMeters});
}
