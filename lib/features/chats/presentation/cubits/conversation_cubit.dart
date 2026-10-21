import 'dart:async';
import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/geo_utils.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/repositories/chat_repository.dart';

class ConversationState extends Equatable {
  final List<ChatMessage> messages;

  /// آخر خطأ بتحديث الرسائل من السيرفر (null = تمام)
  final Object? error;

  /// جاري تحديد الموقع لإرساله
  final bool locating;

  /// صلاحياتي (أكتب؟ مكتوم؟ مشرف؟ قراءة بس؟) — قبل ما توصل: بنفترض بقدر أكتب
  final ChatRoom room;

  const ConversationState({this.messages = const [], this.error, this.locating = false, this.room = ChatRoom.direct});

  ConversationState copyWith({List<ChatMessage>? messages, Object? error, bool clearError = false, bool? locating, ChatRoom? room}) =>
      ConversationState(messages: messages ?? this.messages, error: clearError ? null : error ?? this.error, locating: locating ?? this.locating, room: room ?? this.room);

  /// بقدر أحذف هالرسالة؟ (رسالتي، أو أنا مشرف المجموعة)
  bool canDelete(ChatMessage m) => !room.readOnly && m.status == ChatMessageStatus.sent && room.isGroup && (m.fromMe || room.isSupervisor);

  /// بقدر أكتم صاحبها؟ (المشرف لمعتمر بالمجموعة)
  bool canMute(ChatMessage m) => room.isGroup && room.isSupervisor && !m.fromMe && m.senderId != null;

  @override
  List<Object?> get props => [messages, error, locating, room];
}

// -------------------------------------------------------------
// محادثة وحدة (مع المشرف من مركز المساعدة، أو أي محادثة من الدردشات):
// - الرسائل المحفوظة بتطلع فوراً، وبعدين من السيرفر — وبتتعلّم كمقروءة
// - الجديد بيوصل لحظياً (SignalR) — ولو الاتصال اللحظي مش شغّال بنحدّث كل 4 ثواني (وكل 20 ثانية كاحتياط لو شغّال)
// - الإرسال بيطلع فوراً بالمحادثة ("جاري الإرسال") وبيتبدّل بنسخة السيرفر — ولو فشل بيضل "لم تُرسل" وبينضغط لإعادة المحاولة
// - صلاحياتي (room) بتحدد الكتابة — والمحذوف (MessageDeleted) بيختفي فوراً — والمشرف بيحذف ويكتم ويقفل الكتابة
// -------------------------------------------------------------
class ConversationCubit extends Cubit<ConversationState> {
  final ChatRepository _repository;
  final String conversationId;
  final Duration pollInterval;

  ConversationCubit(this._repository, this.conversationId, {this.pollInterval = const Duration(seconds: 4)}) : super(const ConversationState());

  StreamSubscription<ChatMessage>? _live;
  StreamSubscription<String>? _deleted;
  Timer? _poll;
  int _tick = 0;
  bool _fetching = false;
  final _random = math.Random();

  Future<void> start() async {
    final cached = await _repository.cached(conversationId);
    if (isClosed) return;
    if (cached.isNotEmpty) emit(state.copyWith(messages: cached));
    _live = _repository.incoming(conversationId).listen((message) {
      _merge([message]);
      if (!message.fromMe) _markRead();
    }, onError: (_) {});
    _deleted = _repository.deletedMessages(conversationId).listen(_removeLocally, onError: (_) {});
    unawaited(loadRoom());
    await refresh();
    if (isClosed) return;
    _markRead();
    _poll = Timer.periodic(pollInterval, (_) {
      _tick++;
      if (!_repository.isLive || _tick % 5 == 0) refresh();
    });
  }

  /// الرسائل الواصلة صارت مقروءة (لو فشل بنرجع نحاول مع الرسالة الجاية)
  Future<void> _markRead() async {
    try {
      await _repository.markRead(conversationId);
    } catch (_) {}
  }

  /// آخر رسالة وصلت من السيرفر (الأحدث منها بس بتنطلب)
  String? get _lastServerId {
    for (final m in state.messages.reversed) {
      if (m.status == ChatMessageStatus.sent) return m.id;
    }
    return null;
  }

  Future<void> refresh() async {
    if (_fetching || isClosed) return;
    _fetching = true;
    try {
      final fresh = await _repository.fetch(conversationId, afterId: _lastServerId);
      if (isClosed) return;
      _merge(fresh, clearError: true);
      if (fresh.any((m) => !m.fromMe)) _markRead();
    } catch (error) {
      if (!isClosed) emit(state.copyWith(error: error));
    } finally {
      _fetching = false;
    }
  }

  void _merge(List<ChatMessage> incoming, {bool clearError = false}) {
    final list = [...state.messages];
    for (final m in incoming) {
      final i = list.indexWhere((x) => x.id == m.id || x.clientId == m.clientId);
      if (i >= 0) {
        list[i] = m;
      } else {
        list.add(m);
      }
    }
    // ترتيب بالوقت (والمتساوي بيضل بترتيبه)
    final indexed = list.indexed.toList()..sort((a, b) => a.$2.sentAt.compareTo(b.$2.sentAt) != 0 ? a.$2.sentAt.compareTo(b.$2.sentAt) : a.$1.compareTo(b.$1));
    final sorted = [for (final e in indexed) e.$2];
    emit(state.copyWith(messages: sorted, clearError: clearError));
    _repository.saveCache(conversationId, sorted);
  }

  String _newClientId() => 'c${DateTime.now().microsecondsSinceEpoch}${_random.nextInt(1 << 20)}';

  Future<void> sendText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return Future.value();
    return _send(ChatMessage(id: '', clientId: _newClientId(), conversationId: conversationId, fromMe: true, text: trimmed, sentAt: DateTime.now(), status: ChatMessageStatus.sending));
  }

  Future<void> sendLocation(GeoPoint point) {
    return _send(ChatMessage(id: '', clientId: _newClientId(), conversationId: conversationId, fromMe: true, location: point, sentAt: DateTime.now(), status: ChatMessageStatus.sending));
  }

  /// إعادة إرسال رسالة ما وصلت (بنفس clientId — السيرفر ما بيكررها)
  Future<void> retry(ChatMessage message) {
    if (message.status != ChatMessageStatus.failed) return Future.value();
    return _send(message.copyWith(status: ChatMessageStatus.sending));
  }

  Future<void> _send(ChatMessage pending) async {
    final local = pending.copyWith(id: pending.id.isEmpty ? pending.clientId : pending.id);
    _merge([local]);
    try {
      final saved = await _repository.send(conversationId, clientId: local.clientId, text: local.text, location: local.location);
      if (isClosed) return;
      // نسخة السيرفر بتاخد مكان المؤقتة (نفس clientId)
      emit(
        state.copyWith(
          messages: [
            for (final m in state.messages)
              if (m.clientId != local.clientId) m,
          ],
        ),
      );
      _merge([saved]);
    } catch (_) {
      if (!isClosed) _merge([local.copyWith(status: ChatMessageStatus.failed)]);
    }
  }

  void setLocating(bool value) => emit(state.copyWith(locating: value));

  /// صلاحياتي من السيرفر (لو فشل بنضل على الافتراضي)
  Future<void> loadRoom() async {
    try {
      final room = await _repository.room(conversationId);
      if (!isClosed) emit(state.copyWith(room: room));
    } catch (_) {}
  }

  void _removeLocally(String messageId) {
    if (isClosed || !state.messages.any((m) => m.id == messageId)) return;
    final list = [for (final m in state.messages) if (m.id != messageId) m];
    emit(state.copyWith(messages: list));
    _repository.saveCache(conversationId, list);
  }

  /// حذف رسالة (بترمي الخطأ للشاشة) — بتختفي فوراً
  Future<void> delete(ChatMessage message) async {
    await _repository.deleteMessage(conversationId, message.id);
    _removeLocally(message.id);
  }

  /// المشرف: كتم صاحب الرسالة [minutes] دقيقة (0 = فك)
  Future<void> mute(ChatMessage message, {required int minutes}) => _repository.mute(conversationId, message.senderId!, minutes: minutes);

  /// المشرف: الكتابة للمشرف بس / للكل
  Future<void> setOnlySupervisorCanPost(bool value) async {
    await _repository.setOnlySupervisorCanPost(conversationId, value);
    if (!isClosed) emit(state.copyWith(room: state.room.copyWith(onlySupervisorCanPost: value)));
  }

  @override
  Future<void> close() async {
    _poll?.cancel();
    await _live?.cancel();
    await _deleted?.cancel();
    await _repository.dispose();
    return super.close();
  }
}
