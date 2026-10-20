import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/utils/json_fields.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../auth/data/token_refresher.dart';

// -------------------------------------------------------------
// واجهة الشركة على سيرفر لبيك (/company — حساب الشركة بس، ملف إبراهيم flutter_handoff_2026-10-18 §5.3):
//   GET/PUT /company/me                  → CompanyDto (اسم الشركة للترحيب، الملف الشخصي وتعديله)
//   GET  /company/home                   → { activeTrips, pilgrimsCount, supervisorsCount, groupsCount }
//   GET  /company/trips | /trips/{id}    → TripSummaryDto[] | TripDto (الوجهات بالتفاصيل بس)
//   POST /company/trips                  → TripDto
//   GET/POST /company/trips/{id}/groups  → CompanyGroupDto[] | CompanyGroupDto (بلا مشرف)
//   GET/POST /company/groups/{id}/members (+ /{userId}) → صفوف الأعضاء / بطاقة العضو / إضافة معتمر بالإيميل
//   PUT  /company/groups/{id}/supervisor → تعيين مشرف من قائمة الشركة بالإيميل
//   GET/POST /company/supervisors        → قائمة مشرفي الشركة / إضافة مشرف (كلمة مؤقتة بالإيميل)
//   GET  /notifications                  → إشعارات صاحب الحساب (أنواع 3، 4، 5 للشركة)
// -------------------------------------------------------------
class CompanyApi {
  final ApiClient _client;

  CompanyApi(this._client);

  factory CompanyApi.server() => CompanyApi(ApiClient(baseUrl: ApiConfig.baseUrl, accessToken: TokenStorage.getAccessToken, refreshToken: TokenRefresher.refresh));

  Future<Map<String, dynamic>> me() async => _map(await _client.getJson('/company/me'));

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> body) async => _map(await _client.putJson('/company/me', body: body));

  /// رفع صورة (الشعار): POST /files multipart → { url } — لسا مش بالسيرفر (404 لحد ما يضيفه إبراهيم)
  Future<String> uploadFile(String path) async {
    final data = _map(await _client.postMultipart('/files', files: {'file': path}));
    final url = data['url']?.toString() ?? '';
    if (url.isEmpty) throw const FormatException('Missing url');
    return url;
  }

  Future<Map<String, dynamic>> home() async => _map(await _client.getJson('/company/home'));

  Future<List<Map<String, dynamic>>> trips() async => _list(await _client.getJson('/company/trips'));

  Future<Map<String, dynamic>> trip(String id) async => _map(await _client.getJson('/company/trips/$id'));

  Future<Map<String, dynamic>> createTrip(Map<String, dynamic> body) async => _map(await _client.postJson('/company/trips', body: body));

  Future<List<Map<String, dynamic>>> tripGroups(String tripId) async => _list(await _client.getJson('/company/trips/$tripId/groups'));

  Future<Map<String, dynamic>> createGroup(String tripId, String name) async => _map(await _client.postJson('/company/trips/$tripId/groups', body: {'name': name}));

  Future<List<Map<String, dynamic>>> members(String groupId) async => _list(await _client.getJson('/company/groups/$groupId/members'));

  Future<Map<String, dynamic>> member(String groupId, String userId) async => _map(await _client.getJson('/company/groups/$groupId/members/$userId'));

  Future<Map<String, dynamic>> addMember(String groupId, Map<String, dynamic> body) async => _map(await _client.postJson('/company/groups/$groupId/members', body: body));

  Future<void> removeMember(String groupId, String userId) => _client.delete('/company/groups/$groupId/members/$userId');

  Future<Map<String, dynamic>> assignSupervisor(String groupId, String email) async => _map(await _client.putJson('/company/groups/$groupId/supervisor', body: {'email': email}));

  Future<List<Map<String, dynamic>>> supervisors() async => _list(await _client.getJson('/company/supervisors'));

  Future<Map<String, dynamic>> addSupervisor(Map<String, dynamic> body) async => _map(await _client.postJson('/company/supervisors', body: body));

  Future<List<Map<String, dynamic>>> notifications({int take = 50}) async => _list(await _client.getJson('/notifications', query: {'take': '$take'}));

  static Map<String, dynamic> _map(Object? data) {
    final value = unwrapData(data);
    return value is Map<String, dynamic> ? value : const {};
  }

  static List<Map<String, dynamic>> _list(Object? data) {
    final value = unwrapData(data);
    return value is List ? value.whereType<Map<String, dynamic>>().toList() : const [];
  }
}
