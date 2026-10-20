import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/app_preferences.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/entities/supervisor_profile.dart';
import '../models/supervisor_json.dart';

// -------------------------------------------------------------
// حفظ تقدم المشرف على الجهاز (SharedPreferences + مجلد صور التطبيق):
//   بياناته (الاسم/الإيميل/الهاتف/الصورة)، الإعلانات اللي أرسلها، مسودة الإعلان الجديد، وآخر تبويب فتحه
// -------------------------------------------------------------
class SupervisorLocalSource {
  static const _profileKey = 'sup_profile';
  static const _announcementsKey = 'sup_announcements';
  static const _draftKey = 'sup_announcement_draft';
  static const _lastTabKey = 'sup_last_tab';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<SupervisorProfile?> profile() async {
    final raw = (await _prefs).getString(_profileKey);
    if (raw == null) return null;
    try {
      return SupervisorProfileJson.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(SupervisorProfile profile) async => (await _prefs).setString(_profileKey, jsonEncode(profile.toJson()));

  Future<List<Announcement>> announcements() async {
    final raw = (await _prefs).getString(_announcementsKey);
    if (raw == null) return [];
    try {
      return [for (final j in jsonDecode(raw) as List) AnnouncementJson.fromJson(j as Map<String, dynamic>)];
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAnnouncements(List<Announcement> items) async => (await _prefs).setString(_announcementsKey, jsonEncode([for (final a in items) a.toJson()]));

  Future<AnnouncementDraft> draft() async {
    final raw = (await _prefs).getString(_draftKey);
    if (raw == null) return AnnouncementDraft.empty;
    try {
      return AnnouncementDraftJson.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return AnnouncementDraft.empty;
    }
  }

  Future<void> saveDraft(AnnouncementDraft draft) async {
    final prefs = await _prefs;
    if (draft.isEmpty) {
      await prefs.remove(_draftKey);
    } else {
      await prefs.setString(_draftKey, jsonEncode(draft.toJson()));
    }
  }

  Future<int> lastTab() async => (await _prefs).getInt(_lastTabKey) ?? 0;

  Future<void> saveLastTab(int tab) async => (await _prefs).setInt(_lastTabKey, tab);

  Future<bool> notificationsEnabled() => AppPreferences.getNotificationsEnabled();

  Future<void> setNotificationsEnabled(bool enabled) => AppPreferences.setNotificationsEnabled(enabled);

  /// الصور (صورة المشرف ومرفقات الإعلانات) بتنتسخ لمجلد التطبيق حتى ما تنحذف مع كاش الكاميرا/المعرض
  Future<String> storePhoto(String sourcePath) async {
    final dir = Directory('${(await getApplicationDocumentsDirectory()).path}/supervisor');
    await dir.create(recursive: true);
    final dot = sourcePath.lastIndexOf('.');
    final ext = dot == -1 ? '.jpg' : sourcePath.substring(dot);
    final target = File('${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}$ext');
    await File(sourcePath).copy(target.path);
    return target.path;
  }

  /// حذف صورة قديمة من مجلد التطبيق (بعد ما يغيّرها)
  Future<void> deletePhoto(String? path) async {
    if (path == null || path.startsWith('assets/') || path.startsWith('http')) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  Future<void> clear() async {
    final prefs = await _prefs;
    for (final key in [_profileKey, _announcementsKey, _draftKey, _lastTabKey]) {
      await prefs.remove(key);
    }
    try {
      final dir = Directory('${(await getApplicationDocumentsDirectory()).path}/supervisor');
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {}
  }
}
