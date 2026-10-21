import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsState extends Equatable {
  final List<AppNotification> items;

  /// لسا ما رد السيرفر أول مرة
  final bool loading;

  /// آخر خطأ من السيرفر (null = تمام)
  final Object? error;

  const NotificationsState({this.items = const [], this.loading = true, this.error});

  /// شاشة المعتمر (Figma 114:10192): كل إشعاراته — "انضم عضو" للمشرف بس
  List<AppNotification> get visible => [for (final n in items) if (n.kind != NotificationKind.memberJoined) n];

  @override
  List<Object?> get props => [items, loading, error];
}

// -------------------------------------------------------------
// إشعارات المعتمر: من السيرفر أول ما تفتح الشاشة (وبعدها كلها بتصير مقروءة)،
// والإشعار الجديد بيوصل لحظياً وهي مفتوحة
// -------------------------------------------------------------
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsState());

  final NotificationsRepository _repository;
  StreamSubscription<void>? _live;
  bool _fetching = false;

  Future<void> start() async {
    _live = _repository.changes().listen((_) => refresh(), onError: (_) {});
    await refresh();
  }

  Future<void> refresh() async {
    if (_fetching || isClosed) return;
    _fetching = true;
    try {
      final items = await _repository.list();
      if (isClosed) return;
      emit(NotificationsState(items: items, loading: false));
      if (items.any((n) => !n.isRead)) await _markAllRead();
    } catch (error) {
      if (!isClosed) emit(NotificationsState(items: state.items, loading: false, error: error));
    } finally {
      _fetching = false;
    }
  }

  // شافها → مقروءة بالسيرفر (لو فشل بنرجع نحاول مع التحديث الجاي)
  Future<void> _markAllRead() async {
    try {
      await _repository.markAllRead();
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    await _live?.cancel();
    return super.close();
  }
}
