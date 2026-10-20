import '../../../../core/network/api_exception.dart';
import '../../../chats/data/sources/group_chat_api.dart';
import '../../../group/data/models/home_group.dart';
import '../../../group/data/sources/group_api.dart';
import '../../../group/data/sources/group_realtime.dart';
import '../../../notifications/data/sources/notifications_api.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/supervisor_group.dart';
import '../../domain/entities/supervisor_inbox.dart';
import '../../domain/entities/supervisor_profile.dart';
import '../../domain/entities/trip_program.dart';
import '../../domain/repositories/supervisor_repository.dart';
import '../../presentation/widgets/supervisor_format.dart';
import '../models/announcement_dto.dart';
import '../models/notification_sections.dart';
import '../sources/announcements_api.dart';
import '../sources/supervisor_account_source.dart';
import '../sources/supervisor_local_source.dart';

// -------------------------------------------------------------
// تنفيذ SupervisorRepository:
//   - مجموعتي من /home (السيرفر بيرجّع مجموعة وحدة) وأعضاؤها من /groups/{id}/locations
//   - الإعلانات (/groups/{id}/announcements)، الإشعارات (/notifications)، آخر رسالة بالدردشة (/groups/{id}/messages)
//     والجديد لحظياً من /hubs/events
//   - اللي لسا مش بالسيرفر بيرجع فاضي: الحضور والغياب، رقم المعتمر وبياناته، الرحلة القادمة، برنامج الرحلة
//   - نوع الإعلان (مهم) والمرفق مش بالسيرفر: بينحفظوا على الجهاز للإعلانات اللي أرسلها المشرف من هون
//   - بيانات المشرف: المحفوظ على الجهاز + الاسم والإيميل من /auth/me — المسودة وآخر تبويب على الجهاز
// -------------------------------------------------------------
class SupervisorRepositoryImpl implements SupervisorRepository {
  SupervisorRepositoryImpl({
    SupervisorLocalSource? local,
    SupervisorAccountSource? account,
    GroupApi? groups,
    AnnouncementsApi? announcements,
    NotificationsApi? notifications,
    GroupChatApi? chat,
  }) : _local = local ?? SupervisorLocalSource(),
       _account = account ?? SupervisorAccountSource(),
       _groups = groups ?? GroupApi.server(),
       _announcements = announcements ?? AnnouncementsApi.server(),
       _notifications = notifications ?? NotificationsApi.server(),
       _chat = chat ?? GroupChatApi.server();

  final SupervisorLocalSource _local;
  final SupervisorAccountSource _account;
  final GroupApi _groups;
  final AnnouncementsApi _announcements;
  final NotificationsApi _notifications;
  final GroupChatApi _chat;

  // مجموعتي — بتتحدّث مع كل تحميل للمجموعات، والباقي بيستعمل آخر نسخة (أو نفس الطلب لو لسا ماشي)
  Future<HomeGroup?>? _group;

  Future<HomeGroup?> _myGroup({bool refresh = false}) {
    final current = _group;
    if (!refresh && current != null) return current;
    final next = _groups.myGroup();
    _group = next;
    // لو فشل، المرة الجاية بنطلب من جديد
    next.then<void>((_) {}, onError: (_) {
      if (identical(_group, next)) _group = null;
    });
    return next;
  }

  @override
  Future<List<SupervisorGroup>> getGroups() async {
    final group = await _myGroup(refresh: true);
    if (group == null) return const [];
    // الأرقام من الأعضاء نفسهم حتى تطابق قائمة الأعضاء
    final members = await getMembers(group.id);
    return [
      SupervisorGroup(
        id: group.id,
        name: group.name,
        totalPilgrims: members.length,
        presentCount: members.where((m) => m.present == true).length,
        absentCount: members.where((m) => m.present == false).length,
        nextTripTitle: '',
        nextTripDetails: '',
      ),
    ];
  }

  /// المعتمرين بس (بدون مشرف المجموعة وبدوني)
  @override
  Future<List<GroupMember>> getMembers(String groupId) async {
    final members = await _groups.members(groupId);
    return [
      for (final m in members)
        if (!m.isSupervisor && !m.isMe) GroupMember(id: m.userId, name: m.name),
    ];
  }

  /// برنامج الرحلة لسا مش بالسيرفر
  @override
  Future<List<TripDay>> getProgram(String groupId) async => const [];

  @override
  Future<List<NotificationSection>> getNotifications() async {
    final items = await _notifications.list();
    HomeGroup? group;
    try {
      group = await _myGroup();
    } catch (_) {}
    return NotificationSections.fromJson(items, groupId: group?.id, groupName: group?.name);
  }

  @override
  Future<void> markNotificationsRead() => _notifications.readAll();

  @override
  Future<List<ChatThread>> getChats() async {
    final group = await _myGroup();
    if (group == null) return const [];
    final last = (await _chat.messages(group.id, take: 1)).lastOrNull;
    return [ChatThread(id: group.id, name: group.name, lastMessage: last?.text ?? '', time: last == null ? '' : SupFormat.chatTime(last.sentAt))];
  }

  @override
  Stream<void> notificationsChanged() => GroupRealtime.events.on('NotificationReceived').map((_) {});

  @override
  Stream<void> chatsChanged() => GroupRealtime.events.on('MessageReceived').map((_) {});

  @override
  Future<List<Announcement>> getAnnouncements() async {
    final group = await _myGroup();
    if (group == null) return const [];
    final mine = {for (final a in await _local.announcements()) a.id: a};
    final items = await _announcements.list(group.id);
    return [for (final json in items) AnnouncementDto.fromJson(json, target: group.name, local: mine[json['id']?.toString()])];
  }

  @override
  Future<Announcement> sendAnnouncement(Announcement announcement) async {
    final group = await _myGroup();
    // مش مضاف لمجموعة
    if (group == null) throw const ApiException(404);
    final json = await _announcements.post(group.id, title: announcement.title, body: announcement.body);
    final saved = AnnouncementDto.fromJson(json, target: group.name, local: announcement);
    // النوع والمرفق (مش بالسيرفر) بيضلوا على الجهاز تحت رقم الإعلان بالسيرفر
    await _local.saveAnnouncements([saved, ...await _local.announcements()]);
    return saved;
  }

  @override
  Future<SupervisorProfile> cachedProfile() async => await _local.profile() ?? SupervisorProfile.empty;

  @override
  Future<SupervisorProfile> refreshProfile(SupervisorProfile current) async {
    final account = await _account.fetch();
    // الحقول الفاضية بس بتتعبّى من الحساب — اللي عدّله المشرف بنفسه بيضل
    final updated = current.copyWith(
      fullName: current.fullName.isEmpty ? account.name : null,
      email: current.email.isEmpty ? account.email : null,
      phone: current.phone.isEmpty ? account.phone : null,
    );
    if (updated != current) await _local.saveProfile(updated);
    return updated;
  }

  @override
  Future<void> saveProfile(SupervisorProfile profile) async {
    final old = await _local.profile();
    if (old?.photo != profile.photo) await _local.deletePhoto(old?.photo);
    await _local.saveProfile(profile);
  }

  @override
  Future<String> storePhoto(String sourcePath) => _local.storePhoto(sourcePath);

  @override
  Future<int> lastTab() => _local.lastTab();

  @override
  Future<void> saveLastTab(int tab) => _local.saveLastTab(tab);

  @override
  Future<AnnouncementDraft> loadDraft() => _local.draft();

  @override
  Future<void> saveDraft(AnnouncementDraft draft) => _local.saveDraft(draft);

  @override
  Future<bool> notificationsEnabled() => _local.notificationsEnabled();

  @override
  Future<void> setNotificationsEnabled(bool enabled) => _local.setNotificationsEnabled(enabled);

  @override
  Future<void> clear() => _local.clear();
}
