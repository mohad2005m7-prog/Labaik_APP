import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/utils/json_fields.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../auth/data/token_refresher.dart';

// -------------------------------------------------------------
// بيانات المشرف من سيرفر لبيك (ملف إبراهيم flutter_handoff_2026-10-18):
//   GET /supervisor/groups                      → SupervisorGroupDto[] { id, name, tripId?, tripName?, departureDate?, pilgrimCount, presentCount, absentCount }
//   GET/PUT /trips/{tripId}/itinerary           → { tripId, tripName, days: [{ date, title?, activities: [{ title, timeUtc?, place? }] }] }
//   GET /groups/{id}/members                    → GroupMemberRowDto[] (المشرف أول — بلا ملاحظات صحية)
//   GET /groups/{id}/members/{userId}           → GroupMemberDetailsDto (مع healthNotes و notes)
//   PUT /groups/{id}/attendance/{userId}        → { status: 1 حاضر | 2 غائب }
// -------------------------------------------------------------
class SupervisorApi {
  final ApiClient _client;

  SupervisorApi(this._client);

  factory SupervisorApi.server() => SupervisorApi(ApiClient(baseUrl: ApiConfig.baseUrl, accessToken: TokenStorage.getAccessToken, refreshToken: TokenRefresher.refresh));

  Future<List<Map<String, dynamic>>> groups() async => _list(await _client.getJson('/supervisor/groups'));

  Future<Map<String, dynamic>> itinerary(String tripId) async => _map(await _client.getJson('/trips/$tripId/itinerary'));

  /// PUT /trips/{tripId}/itinerary { days } — استبدال البرنامج كله (الشركة أو مشرف الرحلة)
  Future<Map<String, dynamic>> replaceItinerary(String tripId, List<Map<String, dynamic>> days) async => _map(await _client.putJson('/trips/$tripId/itinerary', body: {'days': days}));

  Future<List<Map<String, dynamic>>> members(String groupId) async => _list(await _client.getJson('/groups/$groupId/members'));

  Future<Map<String, dynamic>> member(String groupId, String userId) async => _map(await _client.getJson('/groups/$groupId/members/$userId'));

  Future<void> setAttendance(String groupId, String userId, {required bool present}) => _client.putJson('/groups/$groupId/attendance/$userId', body: {'status': present ? 1 : 2});

  static Map<String, dynamic> _map(Object? data) {
    final v = unwrapData(data);
    return v is Map<String, dynamic> ? v : const {};
  }

  static List<Map<String, dynamic>> _list(Object? data) {
    final v = unwrapData(data);
    return v is List ? v.whereType<Map<String, dynamic>>().toList() : const [];
  }
}
