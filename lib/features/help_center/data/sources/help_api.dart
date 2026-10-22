import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/utils/json_fields.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../auth/data/token_refresher.dart';
import '../../domain/entities/lost_child_report.dart';
import '../../domain/entities/supervisor_contact.dart';
import '../models/supervisor_contact_json.dart';

// -------------------------------------------------------------
// طلبات مركز المساعدة لسيرفر لبيك (تحت /api/v1 — كلها بـ Bearer token):
//   GET  /pilgrim/supervisor                         → SupervisorDto  (أو null لو مش مربوط بمشرف)
//   POST /files               (multipart: file)      → { url }        الصورة أول (لو في)
//   POST /lost-child-reports  (JSON)                 → 201            { approxAge, description, photoUrl?, latitude, longitude, shareWithNearby }
// (رسائل المحادثة مع المشرف: features/chats — ChatApi)
// التفاصيل الكاملة للباك إند: docs/backend_help_center.md
// -------------------------------------------------------------
class HelpApi {
  final ApiClient _client;

  HelpApi(this._client);

  factory HelpApi.server() => HelpApi(ApiClient(baseUrl: ApiConfig.baseUrl, accessToken: TokenStorage.getAccessToken, refreshToken: TokenRefresher.refresh));

  Future<SupervisorContact?> mySupervisor() async {
    final data = unwrapData(await _client.getJson('/pilgrim/supervisor'));
    return data is Map<String, dynamic> ? SupervisorContactJson.fromJson(data) : null;
  }

  /// العمر والموقع مطلوبين بالسيرفر (الشاشة ما بتبعت بدونهم)
  Future<void> submitLostChild(LostChildReport report, {required bool shareWithNearby}) async {
    final location = report.location;
    final age = report.age;
    if (location == null || age == null) throw const ApiException(422);
    String? photoUrl;
    final photo = report.photoPath;
    if (photo != null) {
      final uploaded = unwrapData(await _client.postMultipart('/files', files: {'file': photo}));
      photoUrl = uploaded is Map<String, dynamic> ? uploaded['url']?.toString() : null;
    }
    await _client.postJson('/lost-child-reports', body: {
      'approxAge': age,
      'description': report.description.trim(),
      'photoUrl': ?photoUrl,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'shareWithNearby': shareWithNearby,
    });
  }
}
