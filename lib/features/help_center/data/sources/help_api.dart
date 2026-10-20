import '../../../../core/network/api_client.dart';
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
//   POST /lost-child-reports  (multipart/form-data)  → 201            approxAge, description, latitude, longitude, shareWithNearby, photo
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

  Future<void> submitLostChild(LostChildReport report, {required bool shareWithNearby}) async {
    await _client.postMultipart(
      '/lost-child-reports',
      fields: {
        if (report.age != null) 'approxAge': '${report.age}',
        'description': report.description.trim(),
        if (report.location != null) 'latitude': '${report.location!.latitude}',
        if (report.location != null) 'longitude': '${report.location!.longitude}',
        'shareWithNearby': '$shareWithNearby',
      },
      files: {if (report.photoPath != null) 'photo': report.photoPath!},
    );
  }
}
