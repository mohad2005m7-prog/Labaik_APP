import 'dart:async';

import '../../../../core/network/api_config.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/token_storage.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation_summary.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_message_json.dart';
import '../sources/chat_api.dart';
import '../sources/chat_hub.dart';
import '../sources/chat_local_source.dart';

// -------------------------------------------------------------
// المحادثات: REST للقائمة والتاريخ والإرسال + SignalR للرسائل الجديدة لحظة وصولها
// كل قائمة ناجحة بتنحفظ على الجهاز — الهَب بيشتغل أول ما حدا يسمع لـ incoming وبيسكّر مع dispose
// -------------------------------------------------------------
class ChatRepositoryImpl implements ChatRepository {
  final ChatApi _api;
  final ChatLocalSource _local;
  final ChatHub _hub;

  ChatRepositoryImpl({ChatApi? api, ChatLocalSource? local, ChatHub? hub})
    : _api = api ?? ChatApi.server(),
      _local = local ?? ChatLocalSource(),
      _hub = hub ?? ChatHub(uri: ApiConfig.chatHub, accessToken: TokenStorage.getAccessToken);

  @override
  Future<List<ConversationSummary>> conversations() async {
    final list = await _api.conversations();
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
  Future<List<ChatMessage>> fetch(String conversationId, {String? afterId}) => _api.messages(conversationId, afterId: afterId);

  @override
  Future<ChatMessage> send(String conversationId, {required String clientId, String? text, GeoPoint? location}) {
    return _api.send(conversationId, clientId: clientId, text: text, location: location);
  }

  @override
  Future<ConversationSummary> startDirect(String userId) => _api.startDirect(userId);

  @override
  Future<void> markRead(String conversationId) => _api.markRead(conversationId);

  // (مش async* — هيك إيقاف الاستماع ما بيستنى رسالة جاية)
  @override
  Stream<ChatMessage> incoming([String? conversationId]) {
    _hub.start();
    return Stream.fromFuture(ChatApi.myUserId()).asyncExpand(
      (me) => _hub.messages.expand((json) sync* {
        final conversation = (json['conversationId'] ?? json['ConversationId'])?.toString();
        if (conversationId != null && conversation != null && conversation != conversationId) return;
        final ChatMessage message;
        try {
          message = ChatMessageJson.fromJson(json, myUserId: me);
        } catch (_) {
          // رسالة ناقصة من السيرفر — بنتجاهلها (بتوصل مع التحديث الدوري)
          return;
        }
        yield message;
      }),
    );
  }

  @override
  bool get isLive => _hub.isConnected;

  @override
  Future<void> dispose() => _hub.dispose();
}
