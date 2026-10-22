import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/stream_merge.dart';
import '../../../chats/data/repositories/server_chat_repository.dart';
import '../../../chats/data/sources/group_chat_api.dart';
import '../../../chats/domain/repositories/chat_repository.dart';
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
import '../models/supervisor_server_json.dart';
import '../sources/announcements_api.dart';
import '../sources/supervisor_account_source.dart';
import '../sources/supervisor_api.dart';
import '../sources/supervisor_local_source.dart';

// -------------------------------------------------------------
// تنفيذ SupervisorRepository:
//   - مجموعاتي من /supervisor/groups (العدد والحضور ورحلتها) + "الرحلة القادمة" = أقرب نشاط من /trips/{tripId}/itinerary
//   - الأعضاء من /groups/{id}/members (الرقم، الحضور، الجنسية، الصورة) وبطاقة العضو من /groups/{id}/members/{userId}
//   - برنامج الرحلة من /trips/{tripId}/itinerary — ولو السيرفر قديم (404) بنرجع لـ /home و /locations
//   - الإعلانات (/groups/{id}/announcements)، الإشعارات (/notifications)، آخر رسالة بالدردشة (/groups/{id}/messages)
//     والجديد لحظياً من /hubs/events
//   - نوع الإعلان (مهم) بينبعت للسيرفر (importance) — المرفق لسا مش بالسيرفر (رفع الملفات) فبيضل على الجهاز
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
    SupervisorApi? supervisor,
    ChatRepository? chats,
  }) : _supervisor = supervisor ?? SupervisorApi.server(),
       _chatsOverride = chats,
       _local = local ?? SupervisorLocalSource(),
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
  final SupervisorApi _supervisor;

  /// الدردشات (مجموعاتي + المحادثات الفردية مع المعتمرين)
  final ChatRepository? _chatsOverride;
  late final ChatRepository _chatList = _chatsOverride ?? ServerChatRepository(groups: _groups, groupChat: _chat);

  /// رحلة كل مجموعة (للبرنامج)
  final _tripOf = <String, String>{};

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

  /// المجموعات اللي بشرف عليها (رقم واسم) بنفس ترتيب /supervisor/groups — آخر نسخة وصلت
  List<({String id, String name})>? _led;

  Future<List<({String id, String name})>> _ledGroups() async {
    final known = _led;
    if (known != null) return known;
    await getGroups();
    return _led ?? const [];
  }

  @override
  Future<List<SupervisorGroup>> getGroups() async {
    List<Map<String, dynamic>> rows;
    try {
      rows = await _supervisor.groups();
    } on ApiException catch (e) {
      if (!e.isMissingOnServer) rethrow;
      final legacy = await _legacyGroups();
      _led = [for (final g in legacy) (id: g.id, name: g.name)];
      return legacy;
    }
    _led = [for (final g in rows) (id: g['id'].toString(), name: g['name']?.toString() ?? '')];
    _myGroup(refresh: true).ignore();
    for (final g in rows) {
      final tripId = g['tripId']?.toString();
      if (tripId != null && tripId.isNotEmpty) _tripOf[g['id'].toString()] = tripId;
    }
    final itineraries = await Future.wait([
      for (final g in rows)
        switch (_tripOf[g['id'].toString()]) {
          final tripId? => _supervisor.itinerary(tripId).then<Map<String, dynamic>?>((v) => v, onError: (_) => null),
          null => Future<Map<String, dynamic>?>.value(null),
        },
    ]);
    return [for (final (i, g) in rows.indexed) SupervisorServerJson.group(g, itinerary: itineraries[i])];
  }

  /// سيرفر قديم بلا /supervisor/groups: مجموعتي من /home وأعدادها من الأعضاء
  Future<List<SupervisorGroup>> _legacyGroups() async {
    final group = await _myGroup(refresh: true);
    if (group == null) return const [];
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

  /// المعتمرين بس (بدون مشرف المجموعة)
  @override
  Future<List<GroupMember>> getMembers(String groupId) async {
    try {
      return [for (final m in await _supervisor.members(groupId)) if (!SupervisorServerJson.isSupervisorRow(m)) SupervisorServerJson.member(m)];
    } on ApiException catch (e) {
      if (!e.isMissingOnServer) rethrow;
    }
    final members = await _groups.members(groupId);
    return [
      for (final m in members)
        if (!m.isSupervisor && !m.isMe) GroupMember(id: m.userId, name: m.name),
    ];
  }

  /// بطاقة العضو مع الملاحظات الصحية — لو فشلت بنرجّع اللي من القائمة
  @override
  Future<GroupMember> getMember(String groupId, GroupMember member) async {
    try {
      return SupervisorServerJson.member(await _supervisor.member(groupId, member.id));
    } catch (_) {
      return member;
    }
  }

  @override
  Future<List<TripDay>> addProgramActivity(String groupId, {required DateTime day, required String title, DateTime? time, String? place}) async {
    var tripId = _tripOf[groupId];
    if (tripId == null) {
      await getGroups();
      tripId = _tripOf[groupId];
    }
    if (tripId == null) throw StateError('no trip');
    final current = await _supervisor.itinerary(tripId);
    final days = SupervisorServerJson.addActivity(current, day: day, title: title, time: time, place: place);
    return SupervisorServerJson.program(await _supervisor.replaceItinerary(tripId, days));
  }

  @override
  Future<void> addMember(String groupId, {required String email, String? fullName, String? phone}) => _supervisor.addMember(groupId, {
        'email': email.trim(),
        if (fullName != null && fullName.trim().isNotEmpty) 'fullName': fullName.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phoneNumber': phone.trim(),
      });

  @override
  Future<void> removeMember(String groupId, String memberId) => _supervisor.removeMember(groupId, memberId);

  @override
  Future<void> setAttendance(String groupId, String memberId, {required bool present}) => _supervisor.setAttendance(groupId, memberId, present: present);

  @override
  Future<List<TripDay>> getProgram(String groupId) async {
    var tripId = _tripOf[groupId];
    if (tripId == null) {
      await getGroups();
      tripId = _tripOf[groupId];
    }
    if (tripId == null) return const [];
    return SupervisorServerJson.program(await _supervisor.itinerary(tripId));
  }

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
    final list = await _chatList.conversations();
    return [
      for (final c in list)
        ChatThread(
          id: c.id,
          name: c.title,
          lastMessage: c.lastMessage == null ? '' : (c.lastMessage!.isLocation ? '📍' : c.lastMessage!.text ?? ''),
          time: c.lastMessage == null ? '' : SupFormat.chatTime(c.lastMessage!.sentAt),
          isGroup: c.isGroup,
          photoUrl: c.photoUrl,
          unread: c.unreadCount,
        ),
    ];
  }

  @override
  Stream<void> notificationsChanged() => GroupRealtime.events.on('NotificationReceived').map((_) {});

  @override
  Stream<void> chatsChanged() => mergeStreams([GroupRealtime.events.on('MessageReceived'), GroupRealtime.events.on('DirectMessageReceived'), GroupRealtime.events.on('MessageDeleted')]).map((_) {});

  /// إعلانات كل مجموعاتي (مش بس وحدة) — من الأحدث، وإعلان الشركة اللي بيطلع بكل مجموعة بينعرض مرة وحدة
  @override
  Future<List<Announcement>> getAnnouncements() async {
    final groups = await _ledGroups();
    if (groups.isEmpty) return const [];
    final mine = {for (final a in await _local.announcements()) a.id: a};
    final lists = await Future.wait([for (final g in groups) _announcements.list(g.id)]);
    final seen = <String>{};
    final rows = <(Map<String, dynamic>, String)>[
      for (final (i, items) in lists.indexed)
        for (final json in items)
          if (seen.add(json['id']?.toString() ?? '')) (json, groups[i].name),
    ];
    DateTime at(Map<String, dynamic> json) => DateTime.tryParse(json['createdAtUtc']?.toString() ?? '') ?? DateTime(0);
    rows.sort((a, b) => at(b.$1).compareTo(at(a.$1)));
    return [for (final (json, target) in rows) AnnouncementDto.fromJson(json, target: target, local: mine[json['id']?.toString()])];
  }

  /// للمجموعة اللي اختارها ([Announcement.target] = اسمها، والافتراضي أول مجموعة) —
  /// "جميع المعتمرين" (أيقونة الكتاب) = لكل مجموعة بيشرف عليها
  @override
  Future<Announcement> sendAnnouncement(Announcement announcement) async {
    final groups = await _ledGroups();
    // مش مضاف لمجموعة
    if (groups.isEmpty) throw const ApiException(404);
    final toAll = announcement.icon == AnnouncementIcon.book;
    final targets = toAll ? groups : [groups.firstWhere((g) => g.name == announcement.target, orElse: () => groups.first)];
    final posted = await Future.wait([
      for (final g in targets) _announcements.post(g.id, title: announcement.title, body: announcement.body, important: announcement.isImportant),
    ]);
    final saved = [for (final json in posted) AnnouncementDto.fromJson(json, target: toAll ? announcement.target : targets.first.name, local: announcement)];
    // النوع والمرفق (مش بالسيرفر) بيضلوا على الجهاز تحت رقم الإعلان بالسيرفر
    await _local.saveAnnouncements([...saved, ...await _local.announcements()]);
    return saved.first;
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
