import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation_summary.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatsListState extends Equatable {
  final List<ConversationSummary> all;
  final String query;

  /// لسا ما رد السيرفر أول مرة
  final bool loading;

  /// آخر خطأ من السيرفر (null = تمام)
  final Object? error;

  const ChatsListState({this.all = const [], this.query = '', this.loading = true, this.error});

  /// المثبّتة فوق، وبعدين الأحدث — والبحث بالاسم أو آخر رسالة
  List<ConversationSummary> get visible {
    final q = query.trim();
    final list = [
      for (final c in all)
        if (q.isEmpty || c.title.contains(q) || (c.lastMessage?.text ?? '').contains(q)) c,
    ];
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return (b.updatedAt ?? epoch).compareTo(a.updatedAt ?? epoch);
    });
    return list;
  }

  ChatsListState copyWith({List<ConversationSummary>? all, String? query, bool? loading, Object? error, bool clearError = false}) =>
      ChatsListState(all: all ?? this.all, query: query ?? this.query, loading: loading ?? this.loading, error: clearError ? null : error ?? this.error);

  @override
  List<Object?> get props => [all, query, loading, error];
}

// -------------------------------------------------------------
// قائمة المحادثات (تبويب الدردشات): المحفوظة فوراً وبعدين من السيرفر
// الرسالة الجديدة (SignalR) بتحدّث آخر رسالة وعدد غير المقروء — ولو الاتصال اللحظي مقطوع بنحدّث كل 15 ثانية
// -------------------------------------------------------------
class ChatsListCubit extends Cubit<ChatsListState> {
  final ChatRepository _repository;
  final Duration pollInterval;

  ChatsListCubit(this._repository, {this.pollInterval = const Duration(seconds: 15)}) : super(const ChatsListState());

  StreamSubscription<ChatMessage>? _live;
  Timer? _poll;
  bool _fetching = false;

  /// المحادثة المفتوحة هلق (رسائلها ما بتنعد غير مقروءة)
  String? _openId;

  Future<void> start() async {
    final cached = await _repository.cachedConversations();
    if (isClosed) return;
    if (cached.isNotEmpty) emit(state.copyWith(all: cached));
    _live = _repository.incoming().listen(_onMessage, onError: (_) {});
    await refresh();
    if (isClosed) return;
    _poll = Timer.periodic(pollInterval, (_) {
      if (!_repository.isLive) refresh();
    });
  }

  Future<void> refresh() async {
    if (_fetching || isClosed) return;
    _fetching = true;
    try {
      final list = await _repository.conversations();
      if (!isClosed) emit(state.copyWith(all: list, loading: false, clearError: true));
    } catch (error) {
      if (!isClosed) emit(state.copyWith(loading: false, error: error));
    } finally {
      _fetching = false;
    }
  }

  void search(String query) => emit(state.copyWith(query: query));

  void _onMessage(ChatMessage message) {
    final id = message.conversationId;
    final i = state.all.indexWhere((c) => c.id == id);
    // محادثة جديدة ما عنا → من السيرفر
    if (i < 0) {
      refresh();
      return;
    }
    final current = state.all[i];
    final unread = message.fromMe || id == _openId ? current.unreadCount : current.unreadCount + 1;
    final list = [...state.all]..[i] = current.copyWith(lastMessage: message, unreadCount: unread);
    emit(state.copyWith(all: list));
  }

  /// فتح محادثة: عدد غير المقروء بيصير صفر (والمحادثة نفسها بتعلّمها مقروءة بالسيرفر)
  void opened(String conversationId) {
    _openId = conversationId;
    final list = [for (final c in state.all) c.id == conversationId ? c.copyWith(unreadCount: 0) : c];
    emit(state.copyWith(all: list));
  }

  /// الرجوع من المحادثة → آخر رسالة من السيرفر
  void closed() {
    _openId = null;
    refresh();
  }

  @override
  Future<void> close() async {
    _poll?.cancel();
    await _live?.cancel();
    await _repository.dispose();
    return super.close();
  }
}
