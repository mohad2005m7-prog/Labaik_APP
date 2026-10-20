import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../auth/data/auth_session.dart';
import '../../../group/data/sources/group_api.dart';
import '../../../group/data/sources/group_realtime.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation_summary.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/group_message_json.dart';
import '../sources/chat_local_source.dart';
import '../sources/group_chat_api.dart';

// -------------------------------------------------------------
// تبويب الدردشات من السيرفر: محادثة مجموعتي (المحادثة = المجموعة، conversationId = groupId)
//   القائمة: مجموعتي من /home + آخر رسالة فيها — والرسائل: /groups/{id}/messages — والجديد: "MessageReceived"
// السيرفر لسا ما فيه: محادثات فردية (مؤجلة بالاتفاق)، رسائل موقع، وعدد غير المقروء — docs/backend_pending.md
// كل قائمة ورسائل ناجحة بتنحفظ على الجهاز (بتطلع فوراً المرة الجاية)
// -------------------------------------------------------------
class GroupChatRepository implements ChatRepository {
  GroupChatRepository({GroupApi? groups, GroupChatApi? api, ChatLocalSource? local})
    : _groups = groups ?? GroupApi.server(),
      _api = api ?? GroupChatApi.server(),
      _local = local ?? ChatLocalSource();

  final GroupApi _groups;
  final GroupChatApi _api;
  final ChatLocalSource _local;

  @override
  Future<List<ConversationSummary>> conversations() async {
    final group = await _groups.myGroup();
    final list = <ConversationSummary>[];
    if (group != null) {
      final last = (await _api.messages(group.id, take: 1)).lastOrNull;
      list.add(ConversationSummary(id: group.id, title: group.name, isGroup: true, isPinned: true, unreadCount: group.unreadMessages, lastMessage: last));
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
    final latest = await _api.messages(conversationId);
    if (afterId == null) return latest;
    final i = latest.indexWhere((m) => m.id == afterId);
    return i < 0 ? latest : latest.sublist(i + 1);
  }

  @override
  Future<ChatMessage> send(String conversationId, {required String clientId, String? text, GeoPoint? location}) async {
    final body = text?.trim() ?? '';
    // رسائل الموقع مش مدعومة بدردشة المجموعة على السيرفر
    if (body.isEmpty) throw const ApiException(400);
    final saved = await _api.send(conversationId, body);
    return ChatMessage(
      id: saved.id,
      clientId: clientId,
      conversationId: saved.conversationId ?? conversationId,
      fromMe: true,
      senderName: saved.senderName,
      text: saved.text ?? body,
      sentAt: saved.sentAt,
    );
  }

  /// المحادثات الفردية مؤجلة بالسيرفر
  @override
  Future<ConversationSummary> startDirect(String userId) => Future.error(const ApiException(404));

  @override
  Future<void> markRead(String conversationId) => _api.markRead(conversationId);

  // (مش async* — هيك إيقاف الاستماع بيسكّر الاتصال فوراً بدل ما يستنى رسالة جاية)
  @override
  Stream<ChatMessage> incoming([String? conversationId]) {
    return Stream.fromFuture(AuthSession.userId()).asyncExpand(
      (me) => GroupRealtime.events.on('MessageReceived').expand((args) sync* {
        final json = args.firstOrNull;
        if (json is! Map<String, dynamic>) return;
        final ChatMessage message;
        try {
          message = GroupMessageJson.fromJson(json, myUserId: me);
        } catch (_) {
          // رسالة ناقصة — بتوصل مع التحديث الدوري
          return;
        }
        if (conversationId == null || message.conversationId == conversationId) yield message;
      }),
    );
  }

  @override
  bool get isLive => GroupRealtime.events.isConnected;

  /// الاتصال اللحظي مشترك بين الشاشات — بيسكّر لحاله لما آخر شاشة توقف تسمع
  @override
  Future<void> dispose() async {}
}
