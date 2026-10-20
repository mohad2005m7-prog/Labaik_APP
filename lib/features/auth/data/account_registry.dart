import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/token_storage.dart';
import 'auth_api_service.dart';
import 'auth_session.dart';
import 'models/account_type.dart';

/// وين وصل الحساب بإعداده
enum AccountSetup {
  /// معتمر لسا بإعداد رحلته (نوع الرحلة ← ... ← الإقامة)
  tripSetup,

  /// جاهز — بيفتح على واجهته مباشرة
  done,
}

/// حساب مسجّل (نوعه + وين وصل بإعداده)
class AccountRecord {
  final AccountType? type;
  final bool setupDone;

  const AccountRecord({this.type, this.setupDone = false});

  AccountSetup get setup {
    // نوعه مش معروف = حاج (الحاج بس بيسجّل لحاله)
    if ((type == null || type == AccountType.pilgrim) && !setupDone) return AccountSetup.tripSetup;
    return AccountSetup.done;
  }

  Map<String, Object?> toJson() => {'type': type?.name, 'setupDone': setupDone};

  factory AccountRecord.fromJson(Map<String, dynamic> json) => AccountRecord(
        type: AccountType.values.asNameMap()[json['type']],
        setupDone: json['setupDone'] == true,
      );
}

// -------------------------------------------------------------
// الحسابات المسجلة — كل تغيير بينحفظ فوراً:
//   - على الجهاز: لكل حساب نوعه (معتمر / مشرف / شركة) ووين وصل بإعداده — بتضل بعد تسجيل الخروج
//   - على السيرفر: نوع الحساب مربوط بالإيميل، فبيرجع حتى لو انحذف التطبيق أو جهاز جديد
//     (السيرفر لسا ما بيدعم هالشي — أول ما يضيفه بيشتغل لحاله: التوكن أو /auth/me أو PUT /auth/account-type)
// "نوع الحساب" بيطلع بس بعد إنشاء حساب جديد وتأكيده (مش عند تسجيل الدخول)
// الحساب بيتعرّف برقم المستخدم بالتوكن وبإيميله (الاتنين)
// -------------------------------------------------------------
class AccountRegistry {
  static const _accountsKey = 'registered_accounts';
  static const _currentEmailKey = 'current_account_email';
  static const _legacyPrefix = 'account_type:';

  static const _idClaims = ['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier', 'nameid', 'sub', 'userId', 'id'];
  static const _emailClaims = ['email', 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'];
  static const _roleKeys = ['accountType', 'role', 'roles', 'userType', 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];


  /// تسجيل الدخول: بنتذكر الإيميل (احتياط لو التوكن ما فيه رقم المستخدم)
  static Future<void> signedIn(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentEmailKey, email.trim().toLowerCase());
  }

  /// إيميل الحساب المسجّل دخول حالياً (للبيانات اللي بتنحفظ لكل حساب لحاله)
  static Future<String?> currentEmail() async => (await SharedPreferences.getInstance()).getString(_currentEmailKey);

  /// حساب جديد انأكّد: التسجيل للحاج بس — أول خطوة إله إعداد رحلته
  static Future<void> registered(String email) async {
    await signedIn(email);
    if (await current() == null) await _write(const AccountRecord(type: AccountType.pilgrim));
  }

  /// الحساب المسجّل دخول حالياً — null = نوعه مش معروف
  /// [askServer]: لو الجهاز ما بيعرفه بنسأل السيرفر (/auth/me) مرة
  static Future<AccountRecord?> current({bool askServer = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final claims = await TokenStorage.accessTokenClaims();
    final keys = _accountKeys(claims, prefs);
    if (keys.isEmpty) return null;

    final accounts = _accounts(prefs);
    final saved = keys.map((k) => accounts[k]).nonNulls.firstOrNull;
    var record = saved;
    // نوع الحساب من نسخة أقدم من التطبيق (كان محفوظ لحاله لكل حساب)
    if (record == null) {
      final legacy = keys.map((k) => AccountType.values.asNameMap()[prefs.getString('$_legacyPrefix$k')]).nonNulls.firstOrNull;
      if (legacy != null) record = AccountRecord(type: legacy, setupDone: true);
    }
    // السيرفر هو الأساس لما بيبعت النوع
    final serverType = _typeIn(claims) ?? _typeInRoles((await AuthSession.current())?.roles) ?? (record == null && askServer ? await _typeFromServer() : null);
    if (serverType != null && serverType != record?.type) {
      record = AccountRecord(type: serverType, setupDone: record?.setupDone ?? true);
    }

    // بينحفظ تحت كل مفاتيح الحساب (رقمه وإيميله) — فبيتلاقى مهما كان التوكن اللي بيرجعه السيرفر
    final complete = keys.every((k) => accounts[k] != null);
    if (record != null && (!identical(record, saved) || !complete)) await _write(record, prefs: prefs, keys: keys);
    return record;
  }

  /// المعتمر خلّص إعداد رحلته
  static Future<void> finishSetup() async {
    final type = (await current())?.type ?? AccountType.pilgrim;
    await _write(AccountRecord(type: type, setupDone: true));
  }

  static Future<void> _write(AccountRecord record, {SharedPreferences? prefs, List<String>? keys}) async {
    prefs ??= await SharedPreferences.getInstance();
    keys ??= _accountKeys(await TokenStorage.accessTokenClaims(), prefs);
    if (keys.isEmpty) return;
    final accounts = _accounts(prefs);
    for (final k in keys) {
      accounts[k] = record;
    }
    await prefs.setString(_accountsKey, jsonEncode({for (final e in accounts.entries) e.key: e.value.toJson()}));
  }

  static Map<String, AccountRecord> _accounts(SharedPreferences prefs) {
    final raw = prefs.getString(_accountsKey);
    if (raw == null) return {};
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return {for (final e in json.entries) e.key: AccountRecord.fromJson(e.value as Map<String, dynamic>)};
    } catch (_) {
      return {};
    }
  }

  // مفاتيح الحساب: رقم المستخدم من التوكن، وإيميله (من التوكن أو من شاشة الدخول)
  static List<String> _accountKeys(Map<String, dynamic>? claims, SharedPreferences prefs) {
    final id = _first(claims, _idClaims);
    final email = _first(claims, _emailClaims) ?? prefs.getString(_currentEmailKey);
    return [
      if (id != null) 'id:$id',
      if (email != null && email.isNotEmpty) 'email:${email.toLowerCase()}',
    ];
  }

  static String? _first(Map<String, dynamic>? json, List<String> keys) {
    if (json == null) return null;
    for (final k in keys) {
      final v = json[k];
      if (v != null && '$v'.trim().isNotEmpty) return '$v'.trim();
    }
    return null;
  }

  // الدور من السيرفر (role / roles): SuperAdmin | CompanyAdmin | Supervisor | Pilgrim
  // (و"Admin" لحاله من النسخة القديمة للسيرفر = مشرف)
  static AccountType? _typeIn(Map<String, dynamic>? json) {
    if (json == null) return null;
    for (final k in _roleKeys) {
      final type = _typeInRoles(json[k]);
      if (type != null) return type;
    }
    return null;
  }

  static AccountType? _typeInRoles(Object? value) {
    if (value == null) return null;
    final roles = [for (final r in (value is List ? value : [value])) '$r'.trim().toLowerCase()];
    if (roles.contains('superadmin')) return AccountType.superAdmin;
    if (roles.any((r) => r == 'companyadmin' || r == 'company')) return AccountType.company;
    if (roles.any((r) => r == 'supervisor' || r == 'groupsupervisor' || r == 'admin')) return AccountType.groupSupervisor;
    if (roles.contains('pilgrim')) return AccountType.pilgrim;
    return null;
  }

  static Future<AccountType?> _typeFromServer() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) return null;
    try {
      final response = await AuthApiService.getMe(token: token).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200 || response.body.isEmpty) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      return _typeIn(decoded['data'] is Map<String, dynamic> ? decoded['data'] as Map<String, dynamic> : decoded);
    } catch (_) {
      return null;
    }
  }

}
