import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/json_fields.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../auth/data/token_refresher.dart';
import '../../domain/entities/family_circle.dart';
import '../../domain/entities/family_member.dart';
import '../models/family_json.dart';

// -------------------------------------------------------------
// طلبات دائرة العائلة لسيرفر لبيك (تحت /api/v1 — كلها بـ Bearer token):
//   GET    /family-circle                          → FamilyCircleDto | null
//   POST   /family-circle                          → FamilyCircleDto        (إنشاء — أو دائرتي لو موجودة)
//   GET    /family-circles/lookup?code=A7K9P2      → { id, name, membersCount } | null
//   POST   /family-circles/{id}/join               → FamilyCircleDto
//   GET    /family-circle/members                  → [FamilyMemberDto]
//   PUT    /family-circle/location-sharing         → 204   body: { enabled }
//   POST   /family-circle/location                 → 204   body: { latitude, longitude }
//   DELETE /family-circle/members/{userId}         → 204   (صاحب الدائرة بس)
// التفاصيل الكاملة للباك إند: docs/backend_help_center.md
// -------------------------------------------------------------
class FamilyApi {
  final ApiClient _client;

  FamilyApi(this._client);

  factory FamilyApi.server() => FamilyApi(ApiClient(baseUrl: ApiConfig.baseUrl, accessToken: TokenStorage.getAccessToken, refreshToken: TokenRefresher.refresh));

  Future<FamilyCircle?> myCircle() async {
    final data = unwrapData(await _client.getJson('/family-circle'));
    return data is Map<String, dynamic> ? FamilyJson.circle(data) : null;
  }

  Future<FamilyCircle> createCircle() async {
    final data = unwrapData(await _client.postJson('/family-circle'));
    if (data is! Map<String, dynamic>) throw const FormatException('Expected the circle');
    return FamilyJson.circle(data);
  }

  Future<FamilyCircleSummary?> findCircle(String code) async {
    final data = unwrapData(await _client.getJson('/family-circles/lookup', query: {'code': code}));
    return data is Map<String, dynamic> ? FamilyJson.summary(data) : null;
  }

  Future<FamilyCircle> joinCircle(String circleId) async {
    final data = unwrapData(await _client.postJson('/family-circles/${Uri.encodeComponent(circleId)}/join'));
    if (data is! Map<String, dynamic>) throw const FormatException('Expected the circle');
    return FamilyJson.circle(data);
  }

  Future<List<FamilyMember>> members() async {
    final data = unwrapData(await _client.getJson('/family-circle/members'));
    if (data is! List) return const [];
    return [for (final item in data.whereType<Map<String, dynamic>>()) FamilyJson.member(item)];
  }

  Future<void> setLocationSharing(bool enabled) => _client.putJson('/family-circle/location-sharing', body: {'enabled': enabled});

  Future<void> sendLocation(GeoPoint point) => _client.postJson('/family-circle/location', body: {'latitude': point.latitude, 'longitude': point.longitude});

  Future<void> removeMember(String userId) => _client.delete('/family-circle/members/${Uri.encodeComponent(userId)}');
}
