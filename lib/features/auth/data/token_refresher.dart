import '../../../core/utils/token_storage.dart';
import 'auth_api_service.dart';
import 'auth_session.dart';

// -------------------------------------------------------------
// تجديد الـ accessToken بالـ refreshToken المحفوظ لما ينتهي (حتى يضل المستخدم داخل حسابه)
// بطبقة الـ data حتى تستخدمه أي طلبات محمية (ApiClient) بدون ما تعتمد على شاشات الدخول
// التوكن بيعيش 15 دقيقة، والـ refreshToken بينستعمل مرة وحدة (فبنحفظ الجديد دايماً)
// -------------------------------------------------------------
abstract final class TokenRefresher {
  static Future<String?>? _running;

  /// التوكن الجديد، أو null لو ما زبط — طلبين بنفس اللحظة بيستنوا نفس التجديد (الـ refreshToken لمرة وحدة)
  static Future<String?> refresh() => _running ??= _refresh().whenComplete(() => _running = null);

  static Future<String?> _refresh() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;
    try {
      final response = await AuthApiService.refreshToken(refreshToken: refreshToken);
      if (response.statusCode != 200) return null;
      final tokens = TokenStorage.extractTokens(response.body);
      await TokenStorage.saveTokens(accessToken: tokens['accessToken'], refreshToken: tokens['refreshToken']);
      // الأدوار بتتحدّث مع تجديد التوكن
      await AuthSession.saveFromResponse(response.body);
      return tokens['accessToken'];
    } catch (_) {
      return null;
    }
  }

  /// توكن صالح للاتصال اللحظي (SignalR): لو انتهى (أو باقي أقل من دقيقة) بنجدده أول
  static Future<String?> validAccessToken() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) return token;
    final exp = (await TokenStorage.accessTokenClaims())?['exp'];
    if (exp is num) {
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
      if (expiresAt.difference(DateTime.now()) < const Duration(minutes: 1)) return await refresh() ?? token;
    }
    return token;
  }
}
