import 'dart:convert';

import '../../../../core/utils/token_storage.dart';
import '../../../auth/data/auth_api_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

// -------------------------------------------------------------
// بيانات حساب المشرف من الباك إند (/auth/me) — نفس طريقة رئيسية المعتمر:
// لو التوكن انتهى بنجدده بالـ refreshToken ونعيد الطلب
// -------------------------------------------------------------
class SupervisorAccountSource {
  /// (الاسم، الإيميل، الهاتف) — أي واحد ممكن يكون null، والكل null لو ما زبط الطلب
  Future<({String? name, String? email, String? phone})> fetch() async {
    const none = (name: null, email: null, phone: null);
    final token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) return none;
    try {
      var response = await AuthApiService.getMe(token: token);
      if (response.statusCode == 401) {
        final newToken = await AuthController.refreshAccessToken();
        if (newToken == null || newToken.isEmpty) return none;
        response = await AuthApiService.getMe(token: newToken);
      }
      if (response.statusCode != 200 || response.body.isEmpty) return none;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return none;
      final json = decoded['data'] is Map<String, dynamic> ? decoded['data'] as Map<String, dynamic> : decoded;

      String? field(List<String> keys) {
        for (final k in keys) {
          final v = json[k];
          if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
        }
        return null;
      }

      return (
        name: field(['fullName', 'name', 'given_name', 'userName']),
        email: field(['email']),
        phone: field(['phone', 'phoneNumber']),
      );
    } catch (_) {
      return none;
    }
  }
}
