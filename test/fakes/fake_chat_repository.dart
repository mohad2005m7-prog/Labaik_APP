import 'dart:async';
import 'dart:convert';

import 'package:labaik/core/network/api_exception.dart';
import 'package:labaik/core/utils/geo_utils.dart';
import 'package:labaik/features/chats/domain/entities/chat_message.dart';
import 'package:labaik/features/chats/domain/entities/chat_room.dart';
import 'package:labaik/features/chats/domain/entities/conversation_summary.dart';
import 'package:labaik/features/chats/domain/repositories/chat_repository.dart';

/// JWT بـ sub (التوقيع مش مهم للتطبيق)
String fakeJwt(String sub) {
  String part(Map<String, Object> m) => base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${part({'alg': 'none'})}.${part({'sub': sub, 'email': 'p@example.com'})}.sig';
}

/// سيرفر محادثات وهمي للاختبارات: بيسجّل الإرسال والقراءة، و[live] بيبعت رسائل "لحظية"
class FakeChat implements ChatRepository {
  final sent = <({String conversationId, String clientId, String? text, GeoPoint? location})>[];
  final read = <String>[];
  final live = StreamController<ChatMessage>.broadcast();
  List<ConversationSummary> list = [];
  List<ChatMessage> server = [];
  bool failSend = false;
  ChatRoom roomValue = ChatRoom.direct;
  final deletedIds = <String>[];
  final mutes = <(String, int)>[];
  final locks = <bool>[];
  final deletions = StreamController<String>.broadcast();

  @override
  Future<List<ConversationSummary>> conversations() async => list;
  @override
  Future<List<ConversationSummary>> cachedConversations() async => const [];
  @override
  Future<List<ChatMessage>> cached(String conversationId) async => const [];
  @override
  Future<void> saveCache(String conversationId, List<ChatMessage> messages) async {}
  @override
  Future<List<ChatMessage>> fetch(String conversationId, {String? afterId}) async => server;

  @override
  Future<ChatMessage> send(String conversationId, {required String clientId, String? text, GeoPoint? location}) async {
    if (failSend) throw const ApiException(null);
    sent.add((conversationId: conversationId, clientId: clientId, text: text, location: location));
    return ChatMessage(id: 's${sent.length}', clientId: clientId, conversationId: conversationId, fromMe: true, text: text, location: location, sentAt: DateTime.now());
  }

  @override
  Future<ChatRoom> room(String conversationId) async => roomValue;

  @override
  Future<void> deleteMessage(String conversationId, String messageId) async => deletedIds.add(messageId);

  @override
  Stream<String> deletedMessages([String? conversationId]) => deletions.stream;

  @override
  Future<void> mute(String conversationId, String userId, {required int minutes}) async => mutes.add((userId, minutes));

  @override
  Future<void> setOnlySupervisorCanPost(String conversationId, bool value) async => locks.add(value);

  @override
  Future<void> markRead(String conversationId) async => read.add(conversationId);

  final direct = <String>[];
  @override
  Future<ConversationSummary> startDirect(String userId) async {
    direct.add(userId);
    return ConversationSummary(id: 'd_$userId', title: userId);
  }

  @override
  Stream<ChatMessage> incoming([String? conversationId]) => conversationId == null ? live.stream : live.stream.where((m) => m.conversationId == null || m.conversationId == conversationId);

  @override
  bool get isLive => true;
  @override
  Future<void> dispose() async {}
}
