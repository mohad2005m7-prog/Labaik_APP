import '../entities/pilgrim_profile.dart';

// -------------------------------------------------------------
// حساب المعتمر (الإعدادات وتعديل البيانات) — منفصل عن حساب المشرف
// -------------------------------------------------------------
abstract class PilgrimAccountRepository {
  /// البيانات المحفوظة لهاد الحساب، والناقص منها (الاسم/الإيميل) من حسابه بالسيرفر
  Future<PilgrimProfile> loadProfile();

  /// المحفوظ على الجهاز بس (بدون سيرفر) — null = ما حفظ شي
  Future<PilgrimProfile?> savedProfile();

  Future<void> saveProfile(PilgrimProfile profile);

  /// بينسخ الصورة المختارة لمجلد التطبيق (حتى ما تروح لو انحذفت من المعرض) وبيرجع مسارها
  Future<String> storePhoto(String sourcePath);

  /// بيحفظ الصورة لحالها فوراً (null = حذفها) — باقي البيانات بتضل زي ما هي محفوظة
  Future<void> savePhoto(String? photo);

  Future<bool> notificationsEnabled();

  Future<void> setNotificationsEnabled(bool enabled);
}
