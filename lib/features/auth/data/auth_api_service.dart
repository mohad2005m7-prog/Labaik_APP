import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthApiService {
  // رابط السيرفر المرفق في ملف v1.json
  static const String baseUrl = 'https://labaik-api.onrender.com/api/v1/auth';

  // 1. تسجيل حساب جديد
  static Future<http.Response> register({
    required String fullName,
    required String email,  
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'password': password,
      }),
    );
  }

  // 2. تأكيد البريد بـ رمز التحقق (OTP)
  static Future<http.Response> verifyEmail({
    required String email,
    required String code,
  }) async {
    final url = Uri.parse('$baseUrl/verify-email');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
      }),
    );
  }

  // 3. إعادة إرسال الرمز
  static Future<http.Response> resendCode({required String email}) async {
    final url = Uri.parse('$baseUrl/resend-code');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
  }

  // 4. تسجيل الدخول
  static Future<http.Response> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
  }

  // 5. طلب استعادة كلمة المرور
  static Future<http.Response> forgotPassword({required String email}) async {
    final url = Uri.parse('$baseUrl/forgot-password');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
  }

  // 6. تعيين كلمة مرور جديدة
  static Future<http.Response> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/reset-password');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
        'newPassword': newPassword,
      }),
    );
  }

  // 6.5 الدخول بـ Google: الـ ID token من google_sign_in → نفس رد /auth/login
  static Future<http.Response> google({required String idToken}) async {
    final url = Uri.parse('$baseUrl/google');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );
  }

  // 7. تحديث الـ Token
  static Future<http.Response> refreshToken({required String refreshToken}) async {
    final url = Uri.parse('$baseUrl/refresh-token');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
  }

  // 7.5 تغيير كلمة المرور وأنا داخل (الحالية + الجديدة) — بيرجع توكنات جديدة (mustChangePassword: false)
  static Future<http.Response> changePassword({required String token, required String currentPassword, required String newPassword}) async {
    final url = Uri.parse('$baseUrl/change-password');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'currentPassword': currentPassword, 'newPassword': newPassword}),
    );
  }

  // 7.6 تسجيل الخروج: إلغاء الـ refreshToken على السيرفر (ما بيحتاج accessToken)
  static Future<http.Response> logout({required String refreshToken}) async {
    final url = Uri.parse('$baseUrl/logout');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    ).timeout(const Duration(seconds: 6));
  }

  /// كود الخطأ من رد السيرفر (ProblemDetails "code": Auth.AccountDisabled، Supervisor.Suspended، ...)
  static String? errorCode(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded['code']?.toString() : null;
    } catch (_) {
      return null;
    }
  }

  // 8. جلب بيانات المستخدم الحالي
  static Future<http.Response> getMe({required String token}) async {
    final url = Uri.parse('$baseUrl/me');
    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}