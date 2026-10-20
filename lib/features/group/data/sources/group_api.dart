import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../auth/data/auth_session.dart';
import '../../../auth/data/token_refresher.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/group_preview.dart';
import '../models/home_group.dart';
import '../models/member_location_json.dart';
import 'group_realtime.dart';

// -------------------------------------------------------------
// طلبات المجموعة لسيرفر لبيك (تحت /api/v1 — بـ Bearer token):
//   GET /home                        → "group": مجموعتي (null = الشركة لسا ما ضافتني لمجموعة)
//   GET /groups/{groupId}/locations  → كل الأعضاء (المشرف أول)، والإحداثيات لمن بيشارك بس
// نقاط /groups/{groupId} للأعضاء بس — غير العضو بياخد 404
// -------------------------------------------------------------
class GroupApi {
  final ApiClient _client;

  GroupApi(this._client);

  factory GroupApi.server() => GroupApi(ApiClient(baseUrl: ApiConfig.baseUrl, accessToken: TokenStorage.getAccessToken, refreshToken: TokenRefresher.refresh));

  static String path(String groupId) => '/groups/${Uri.encodeComponent(groupId)}';

  /// مجموعتي — ولو تغيّرت عن آخر مرة الاتصال اللحظي بيرجع يشترك (السيرفر بيشترك بمجموعاتي لحظة الاتصال بس)
  Future<HomeGroup?> myGroup() async {
    final group = HomeGroup.fromHome(await _client.getJson('/home'));
    await GroupRealtime.groupSeen(group?.id);
    return group;
  }

  /// "تأكد من مجموعتك": GET /groups/{code} → GroupSummaryDto (رمز غلط = 404)
  Future<GroupPreview> preview(String code) async {
    final data = await _client.getJson('/groups/${Uri.encodeComponent(code)}');
    if (data is! Map<String, dynamic>) throw const FormatException('Expected the group');
    return GroupPreview.fromJson(data, code);
  }

  /// الانضمام بالرمز: POST /groups/{code}/join
  /// ⚠️ السيرفر حالياً بيسمح فيه للـ Admin بس — الحاج بياخد 403 (الشركة هي اللي بتضيف الأعضاء)
  Future<void> join(String code) => _client.postJson('/groups/${Uri.encodeComponent(code)}/join');

  Future<List<GroupMember>> members(String groupId) async {
    final data = await _client.getJson('${path(groupId)}/locations');
    if (data is! List) return const [];
    final me = await AuthSession.userId();
    return [for (final item in data.whereType<Map<String, dynamic>>()) MemberLocationJson.fromJson(item, myUserId: me)];
  }
}
