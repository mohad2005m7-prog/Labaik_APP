import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/stream_merge.dart';
import '../../../auth/data/auth_session.dart';
import '../../../group/data/sources/group_api.dart';
import '../../../group/data/sources/group_realtime.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/conversation_summary.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/group_message_json.dart';
import '../sources/chat_api.dart';
import '../sources/chat_local_source.dart';
import '../sources/group_chat_api.dart';

// -------------------------------------------------------------
// الدردشات من سيرفر لبيك — نوعين بنفس القائمة:
//   المجموعة: conversationId = groupId (المعتمر: مجموعته من /home — المشرف: كل مجموعاته من /supervisor/groups)
//     /groups/{id}/messages — والجديد "MessageReceived" والمحذوف "MessageDeleted"
//   الفردية (المعتمر ↔ مشرفه): /chats — والجديد "DirectMessageReceived"
// كل الأحداث على نفس الاتصال اللحظي (/hubs/events) — وكل قائمة ورسائل ناجحة بتنحفظ على الجهاز
// [companyGroupId]: الشركة بتقرأ دردشة مجموعتها بس (قراءة بلا كتابة)
// -------------------------------------------------------------
class ServerChatRepository implements ChatRepository {
  ServerChatRepository({GroupApi? groups, GroupChatApi? groupChat, ChatApi? direct, ChatLocalSource? local, this.companyGroupId})
    : _groups = groups ?? GroupApi.server(),
      _groupChat = groupChat ?? GroupChatApi.server(),
      _direct = direct ?? ChatApi.server(),
      _local = local ?? ChatLocalSource();

  /// قراءة دردشة مجموعة من حساب الشركة
  ServerChatRepository.companyReader(String groupId) : this(companyGroupId: groupId);

  final GroupApi _groups;
  final GroupChatApi _groupChat;
  final ChatApi _direct;
  final ChatLocalSource _local;
  final String? companyGroupId;

  /// نوع كل محادثة عرفناها (true = مجموعة)
  final _isGroup = <String, bool>{};

  Future<bool> _groupOf(String conversationId) async {
    if (conversationId == companyGroupId) return true;
    final known = _isGroup[conversationId];
    if (known != null) return known;
    // محادثة ما مرّت بالقائمة (من مركز المساعدة مثلاً): مجموعة لو هي وحدة من مجموعاتي
    try {
      return _isGroup[conversationId] = (await _groups.group(conversationId)) != null;
    } catch (_) {
      return _isGroup[conversationId] = false;
    }
  }

  @override
  Future<List<ConversationSummary>> conversations() async {
    final me = await AuthSession.current();
    Object? failure;
    // المجموعات: المشرف كل مجموعاته — المعتمر مجموعته
    var groups = <({String id, String name, int unread})>[];
    try {
      if (me?.isSupervisor ?? false) {
        groups = [for (final g in await _groups.supervisedGroups()) (id: g.id, name: g.name, unread: 0)];
      } else {
        final g = await _groups.myGroup();
        if (g != null) groups = [(id: g.id, name: g.name, unread: g.unreadMessages)];
      }
    } catch (e) {
      failure = e;
    }
    final lasts = await Future.wait([for (final g in groups) _groupChat.messages(g.id, take: 1).then((m) => m.lastOrNull, onError: (_) => null)]);
    final list = <ConversationSummary>[
      for (final (i, g) in groups.indexed) ConversationSummary(id: g.id, title: g.name, isGroup: true, isPinned: true, unreadCount: g.unread, lastMessage: lasts[i]),
    ];
    // الفردية (لو الخدمة مقفلة للشركة أو السيرفر أقدم بنكمل بالمجموعات)
    try {
      list.addAll(await _direct.conversations());
    } catch (e) {
      if (groups.isEmpty && !(e is ApiException && (e.isMissingOnServer || e.isForbidden))) failure ??= e;
    }
    if (list.isEmpty && failure != null) throw failure;
    for (final c in list) {
      _isGroup[c.id] = c.isGroup;
    }
    await _local.saveConversations(list);
    return list;
  }

  @override
  Future<List<ConversationSummary>> cachedConversations() => _local.conversations();

  @override
  Future<List<ChatMessage>> cached(String conversationId) => _local.messages(conversationId);

  @override
  Future<void> saveCache(String conversationId, List<ChatMessage> messages) => _local.saveMessages(conversationId, messages);

  @override
  Future<List<ChatMessage>> fetch(String conversationId, {String? afterId}) async {
    final latest = await _groupOf(conversationId) ? await _groupChat.messages(conversationId) : await _direct.messages(conversationId);
    if (afterId == null) return latest;
    final i = latest.indexWhere((m) => m.id == afterId);
    return i < 0 ? latest : latest.sublist(i + 1);
  }

  @override
  Future<ChatMessage> send(String conversationId, {required String clientId, String? text, GeoPoint? location}) async {
    if (conversationId == companyGroupId) throw const ApiException(403);
    final body = text?.trim() ?? '';
    final group = await _groupOf(conversationId);
    final ChatMessage saved;
    if (group) {
      if (body.isEmpty && location == null) throw const ApiException(400);
      saved = await _groupChat.send(conversationId, body, location: location);
    } else {
      // الفردية نص بس: الموقع بينبعت رابط خريطة
      final text = location == null ? body : [if (body.isNotEmpty) body, 'https://maps.google.com/?q=${location.latitude},${location.longitude}'].join('\n');
      if (text.isEmpty) throw const ApiException(400);
      saved = await _direct.send(conversationId, text);
    }
    return ChatMessage(
      id: saved.id,
      clientId: clientId,
      conversationId: saved.conversationId ?? conversationId,
      fromMe: true,
      senderId: saved.senderId,
      senderName: saved.senderName,
      text: saved.text,
      location: saved.location,
      sentAt: saved.sentAt,
    );
  }

  @override
  Future<ConversationSummary> startDirect(String userId) async {
    final conversation = await _direct.start(userId);
    _isGroup[conversation.id] = false;
    return conversation;
  }

  @override
  Future<void> markRead(String conversationId) async {
    if (conversationId == companyGroupId) return;
    return await _groupOf(conversationId) ? _groupChat.markRead(conversationId) : _direct.markRead(conversationId);
  }

  @override
  Future<ChatRoom> room(String conversationId) async {
    if (conversationId == companyGroupId) return const ChatRoom(isGroup: true, readOnly: true);
    if (!await _groupOf(conversationId)) return ChatRoom.direct;
    final g = await _groups.group(conversationId);
    return ChatRoom(isGroup: true, isSupervisor: g?.isLeader ?? false, onlySupervisorCanPost: g?.onlySupervisorCanPost ?? false, mutedUntil: g?.mutedUntil);
  }

  @override
  Future<void> deleteMessage(String conversationId, String messageId) async {
    // الفردية ما فيها حذف بالسيرفر
    if (!await _groupOf(conversationId)) throw const ApiException(405);
    await _groupChat.delete(conversationId, messageId);
  }

  @override
  Stream<String> deletedMessages([String? conversationId]) => GroupRealtime.events.on('MessageDeleted').expand((args) sync* {
        final id = args.firstOrNull?.toString();
        if (id != null && id.isNotEmpty) yield id;
      });

  @override
  Future<void> mute(String conversationId, String userId, {required int minutes}) => _groupChat.mute(conversationId, userId, minutes);

  @override
  Future<void> setOnlySupervisorCanPost(String conversationId, bool value) => _groupChat.setOnlySupervisorCanPost(conversationId, value);

  // (مش async* — هيك إيقاف الاستماع بيسكّر الاتصال فوراً بدل ما يستنى رسالة جاية)
  @override
  Stream<ChatMessage> incoming([String? conversationId]) {
    return Stream.fromFuture(AuthSession.userId()).asyncExpand((me) {
      Iterable<ChatMessage> parse(List<Object?> args, ChatMessage Function(Map<String, dynamic>) read) sync* {
        final json = args.firstOrNull;
        if (json is! Map<String, dynamic>) return;
        final ChatMessage message;
        try {
          message = read(json);
        } catch (_) {
          // رسالة ناقصة — بتوصل مع التحديث الدوري
          return;
        }
        if (conversationId == null || message.conversationId == conversationId) yield message;
      }

      final group = GroupRealtime.events.on('MessageReceived').expand((args) => parse(args, (j) => GroupMessageJson.fromJson(j, myUserId: me)));
      final direct = GroupRealtime.events.on('DirectMessageReceived').expand((args) => parse(args, (j) {
            final m = ChatApi.message(j, myUserId: me);
            if (m.conversationId != null) _isGroup[m.conversationId!] = false;
            return m;
          }));
      return mergeStreams([group, direct]);
    });
  }

  @override
  bool get isLive => GroupRealtime.events.isConnected;

  /// الاتصال اللحظي مشترك بين الشاشات — بيسكّر لحاله لما آخر شاشة توقف تسمع
  @override
  Future<void> dispose() async {}
}
