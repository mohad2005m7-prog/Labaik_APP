import '../entities/announcement.dart';
import '../entities/group_member.dart';
import '../entities/supervisor_group.dart';
import '../entities/supervisor_inbox.dart';
import '../entities/supervisor_profile.dart';
import '../entities/trip_program.dart';

// -------------------------------------------------------------
// عقد بيانات واجهة المشرف (Domain) — الـ Cubits بتتعامل معه بس
// التنفيذ (SupervisorRepositoryImpl): سيرفر لبيك (المجموعة، الأعضاء، الإعلانات، الإشعارات، الدردشة) + حفظ على الجهاز + /auth/me
// اللي لسا مش بالسيرفر (الحضور، رقم المعتمر، برنامج الرحلة…) بيرجع فاضي — docs/backend_pending.md
// -------------------------------------------------------------
abstract class SupervisorRepository {
  // ---------------- محتوى المجموعات ----------------
  Future<List<SupervisorGroup>> getGroups();
  Future<List<GroupMember>> getMembers(String groupId);
  Future<List<TripDay>> getProgram(String groupId);
  Future<List<NotificationSection>> getNotifications();
  Future<List<ChatThread>> getChats();

  /// فتح شاشة الإشعارات: كلها صارت مقروءة
  Future<void> markNotificationsRead();

  /// إشعار جديد وصل لحظياً (القائمة بتعيد التحميل)
  Stream<void> notificationsChanged();

  /// رسالة جديدة بمجموعتي وصلت لحظياً
  Stream<void> chatsChanged();

  // ---------------- الإعلانات ----------------
  Future<List<Announcement>> getAnnouncements();

  /// بيرجع الإعلان زي ما انحفظ بالسيرفر
  Future<Announcement> sendAnnouncement(Announcement announcement);

  // ---------------- بيانات المشرف ----------------
  /// المحفوظ على الجهاز (سريع — بيطلع فوراً)
  Future<SupervisorProfile> cachedProfile();

  /// تحديث الاسم والإيميل من حسابه (/auth/me) — الحقول اللي عدّلها هو بتضل زي ما هي
  Future<SupervisorProfile> refreshProfile(SupervisorProfile current);
  Future<void> saveProfile(SupervisorProfile profile);

  /// نسخ صورة (من الكاميرا أو المعرض) لمكان دائم بالتطبيق — بيرجع المسار الجديد
  Future<String> storePhoto(String sourcePath);

  // ---------------- حفظ التقدم ----------------
  Future<int> lastTab();
  Future<void> saveLastTab(int tab);
  Future<AnnouncementDraft> loadDraft();
  Future<void> saveDraft(AnnouncementDraft draft);
  Future<bool> notificationsEnabled();
  Future<void> setNotificationsEnabled(bool enabled);

  /// تسجيل الخروج: مسح بيانات المشرف المحفوظة على الجهاز
  Future<void> clear();
}
