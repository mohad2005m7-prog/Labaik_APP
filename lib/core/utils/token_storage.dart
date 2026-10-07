import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// -------------------------------------------------------------
// TokenStorage
// مسؤول عن حفظ/قراءة/حذف الـ accessToken و refreshToken محلياً
// على جهاز المستخدم، حتى تقدر أي شاشة (متل HomeScreen) تعرف
// المستخدم مسجّل دخول وتقدر تنادي الـ APIs المحمية (متل /auth/me).
// -------------------------------------------------------------
class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  static Future<void> saveTokens({
    required String? accessToken,
    String? refreshToken,
  }) async {
    if (accessToken == null || accessToken.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  // يحاول يقرأ accessToken/refreshToken من جسم رد السيرفر (JSON)
  // بيدعم أكثر من تسمية شائعة، وبيدعم إذا كان الرد ملفوف بمفتاح "data"
  static Map<String, String?> extractTokens(String responseBody) {
    try {
      if (responseBody.isEmpty) return {'accessToken': null, 'refreshToken': null};

      final decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, dynamic>) {
        return {'accessToken': null, 'refreshToken': null};
      }

      final Map<String, dynamic> json =
          (decoded['data'] is Map<String, dynamic>) ? decoded['data'] as Map<String, dynamic> : decoded;

      final accessToken = (json['accessToken'] ?? json['token'] ?? json['access_token'])?.toString();
      final refreshToken = (json['refreshToken'] ?? json['refresh_token'])?.toString();

      return {'accessToken': accessToken, 'refreshToken': refreshToken};
    } catch (_) {
      return {'accessToken': null, 'refreshToken': null};
    }
  }
}
