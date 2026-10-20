import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/token_storage.dart';

// -------------------------------------------------------------
// بيانات المستخدم من رد الدخول (login / verify-email / google / refresh-token):
//   { "accessToken", "refreshToken", "tokenType", "expiresIn", "user": { "id", "email", "fullName", "roles" } }
// roles: [] = حاج — فيها "Supervisor" = مشرف — فيها "Admin" = مسؤول (نفس صلاحيات المشرف)
// بتتحدّث بس مع الدخول أو تجديد التوكن (ملف السيرفر) — وبتنمسح مع تسجيل الخروج
// -------------------------------------------------------------
class AuthUser {
  final String id;
  final String email;
  final String fullName;
  final List<String> roles;

  const AuthUser({required this.id, required this.email, required this.fullName, this.roles = const []});

  /// "إنشاء مجموعة" للمشرف والمسؤول بس
  bool get isSupervisor => roles.any((r) => r.toLowerCase() == 'supervisor' || r.toLowerCase() == 'admin');

  static AuthUser? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final id = json['id']?.toString();
    if (id == null || id.isEmpty) return null;
    final roles = json['roles'];
    final role = json['role']?.toString();
    return AuthUser(
      id: id,
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      roles: [
        if (roles is List) for (final r in roles) r.toString(),
        if (role != null && role.isNotEmpty) role,
      ],
    );
  }

  Map<String, Object?> toJson() => {'id': id, 'email': email, 'fullName': fullName, 'roles': roles};
}

abstract final class AuthSession {
  static const _key = 'auth_user';

  /// بنحفظ "user" من جسم رد الدخول (لو موجود)
  static Future<void> saveFromResponse(String body) async {
    try {
      final decoded = jsonDecode(body);
      final root = decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic> ? decoded['data'] : decoded;
      final user = AuthUser.fromJson(root is Map<String, dynamic> ? root['user'] : null);
      if (user != null) await (await SharedPreferences.getInstance()).setString(_key, jsonEncode(user.toJson()));
    } catch (_) {
      // رد مش JSON — بنضل على المحفوظ
    }
  }

  static Future<AuthUser?> current() async {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    if (raw == null) return null;
    try {
      return AuthUser.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  /// رقم المستخدم: "sub" بالتوكن (أو المحفوظ من رد الدخول)
  static Future<String?> userId() async {
    final sub = (await TokenStorage.accessTokenClaims())?['sub']?.toString();
    if (sub != null && sub.isNotEmpty) return sub;
    return (await current())?.id;
  }

  /// حساب انعمل بكلمة مرور مؤقتة (شركة / مشرف / معتمر أضافته الشركة): لازم يغيّرها قبل أي إشي تاني
  /// السيرفر بيحطها بالتوكن (pwd_change) — وكل الطلبات التانية بترجع 403 Auth.PasswordChangeRequired لحد ما يغيّرها
  static Future<bool> mustChangePassword() async => (await TokenStorage.accessTokenClaims())?['pwd_change']?.toString() == 'true';

  static Future<void> clear() async => (await SharedPreferences.getInstance()).remove(_key);
}
