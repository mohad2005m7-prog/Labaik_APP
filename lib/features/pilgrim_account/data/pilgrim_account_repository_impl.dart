import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/token_storage.dart';
import '../../auth/data/account_registry.dart';
import '../../auth/data/auth_api_service.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../domain/entities/pilgrim_profile.dart';
import '../domain/repositories/pilgrim_account_repository.dart';

// -------------------------------------------------------------
// حساب المعتمر على الجهاز — كل شي محفوظ لكل حساب لحاله (بإيميله) فما بيختلط بحساب تاني
// ومفاتيحه غير مفاتيح المشرف (pilgrim_*) — تسجيل الخروج ما بيمسحها
// -------------------------------------------------------------
class PilgrimAccountRepositoryImpl implements PilgrimAccountRepository {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<String> _key(String name) async => 'pilgrim_$name:${await AccountRegistry.currentEmail() ?? ''}';

  @override
  Future<PilgrimProfile?> savedProfile() async {
    final raw = (await _prefs).getString(await _key('profile'));
    if (raw == null) return null;
    try {
      return PilgrimProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PilgrimProfile> loadProfile() async {
    var profile = await savedProfile() ?? PilgrimProfile.empty;
    // الاسم والإيميل لسا فاضيين → من حسابه
    if (profile.fullName.isEmpty || profile.email.isEmpty) {
      final account = await _fetchAccount();
      profile = profile.copyWith(
        fullName: profile.fullName.isEmpty ? account.name : null,
        email: profile.email.isEmpty ? (account.email ?? await AccountRegistry.currentEmail()) : null,
      );
    }
    return profile;
  }

  @override
  Future<void> saveProfile(PilgrimProfile profile) async {
    final prefs = await _prefs;
    final key = await _key('profile');
    // الصورة القديمة ما عاد إلها لزوم
    final old = prefs.getString(key);
    if (old != null) {
      try {
        final oldPhoto = (jsonDecode(old) as Map<String, dynamic>)['photo'] as String?;
        if (oldPhoto != null && oldPhoto != profile.photo) await File(oldPhoto).delete();
      } catch (_) {}
    }
    await prefs.setString(key, jsonEncode(profile.toJson()));
  }

  @override
  Future<String> storePhoto(String sourcePath) async {
    final dir = Directory('${(await getApplicationDocumentsDirectory()).path}/pilgrim');
    await dir.create(recursive: true);
    final ext = sourcePath.contains('.') ? sourcePath.substring(sourcePath.lastIndexOf('.')) : '.jpg';
    final target = '${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}$ext';
    await File(sourcePath).copy(target);
    return target;
  }

  @override
  Future<void> savePhoto(String? photo) async {
    final saved = await savedProfile() ?? PilgrimProfile.empty;
    await saveProfile(photo == null ? saved.copyWith(clearPhoto: true) : saved.copyWith(photo: photo));
  }

  @override
  Future<bool> notificationsEnabled() async => (await _prefs).getBool(await _key('notifications')) ?? true;

  @override
  Future<void> setNotificationsEnabled(bool enabled) async => (await _prefs).setBool(await _key('notifications'), enabled);

  // الاسم والإيميل من /auth/me (ولو التوكن انتهى بنجدده)
  Future<({String? name, String? email})> _fetchAccount() async {
    const none = (name: null, email: null);
    final token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) return none;
    try {
      var response = await AuthApiService.getMe(token: token).timeout(const Duration(seconds: 8));
      if (response.statusCode == 401) {
        final fresh = await AuthController.refreshAccessToken();
        if (fresh == null || fresh.isEmpty) return none;
        response = await AuthApiService.getMe(token: fresh).timeout(const Duration(seconds: 8));
      }
      if (response.statusCode != 200 || response.body.isEmpty) return none;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return none;
      final json = decoded['data'] is Map<String, dynamic> ? decoded['data'] as Map<String, dynamic> : decoded;
      String? field(List<String> keys) {
        for (final k in keys) {
          final v = json[k];
          if (v != null && '$v'.trim().isNotEmpty) return '$v'.trim();
        }
        return null;
      }

      return (name: field(['fullName', 'name', 'given_name', 'userName']), email: field(['email']));
    } catch (_) {
      return none;
    }
  }
}
