import '../../../../core/utils/geo_utils.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/conversation_summary.dart';
import '../../domain/repositories/chat_repository.dart';
import '../sources/chat_local_source.dart';

// -------------------------------------------------------------
// محادثات على الجهاز بس (بدون سيرفر) — للأقسام المفصولة مؤقتاً عن السيرفر (BackendMode):
// "بدء محادثة" مع فرد بيفتح المحادثة، ورسايلك بتنحفظ بالجهاز وبتضل لما ترجع لها
// (ما في رد من الطرف التاني لأنه ما في سيرفر يوصلها له)
// -------------------------------------------------------------
class LocalChatRepository implements ChatRepository {
  final ChatLocalSource _local;

  LocalChatRepository({ChatLocalSource? local}) : _local = local ?? ChatLocalSource();

  static String conversationFor(String userId) => 'local_$userId';

  @override
  Future<List<ConversationSummary>> conversations() async => const [];

  @override
  Future<List<ConversationSummary>> cachedConversations() async => const [];

  @override
  Future<List<ChatMessage>> cached(String conversationId) => _local.messages(conversationId);

  @override
  Future<void> saveCache(String conversationId, List<ChatMessage> messages) => _local.saveMessages(conversationId, messages);

  @override
  Future<List<ChatMessage>> fetch(String conversationId, {String? afterId}) async {
    final all = await _local.messages(conversationId);
    if (afterId == null) return all;
    final index = all.indexWhere((m) => m.id == afterId);
    return index < 0 ? all : all.sublist(index + 1);
  }

  @override
  Future<ChatMessage> send(String conversationId, {required String clientId, String? text, GeoPoint? location}) async {
    final message = ChatMessage(id: clientId, clientId: clientId, conversationId: conversationId, fromMe: true, text: text, location: location, sentAt: DateTime.now());
    final all = await _local.messages(conversationId);
    await _local.saveMessages(conversationId, [...all.where((m) => m.clientId != clientId), message]);
    return message;
  }

  @override
  Future<ConversationSummary> startDirect(String userId) async => ConversationSummary(id: conversationFor(userId), title: '');

  @override
  Future<ChatRoom> room(String conversationId) async => ChatRoom.direct;

  @override
  Future<void> deleteMessage(String conversationId, String messageId) async {}

  @override
  Stream<String> deletedMessages([String? conversationId]) => const Stream.empty();

  @override
  Future<void> mute(String conversationId, String userId, {required int minutes}) async {}

  @override
  Future<void> setOnlySupervisorCanPost(String conversationId, bool value) async {}

  @override
  Future<void> markRead(String conversationId) async {}

  @override
  Stream<ChatMessage> incoming([String? conversationId]) => const Stream.empty();

  @override
  bool get isLive => true;

  @override
  Future<void> dispose() async {}
}
