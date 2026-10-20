import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/group_info.dart';
import '../../domain/entities/group_location_event.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/repositories/group_repository.dart';

class GroupMembersState extends Equatable {
  final GroupInfo? group;
  final List<GroupMember> members;
  final String query;

  /// لسا ما وصل الرد أول مرة
  final bool loading;
  final Object? error;

  const GroupMembersState({this.group, this.members = const [], this.query = '', this.loading = true, this.error});

  /// القائمة (Figma): المشرف أول وبعدين الباقي — بدون أنا — والبحث بالاسم
  List<GroupMember> get visible {
    final q = query.trim();
    final list = [for (final m in members) if (!m.isMe && (q.isEmpty || m.name.contains(q))) m];
    final supervisor = list.indexWhere((m) => m.isSupervisor);
    if (supervisor > 0) list.insert(0, list.removeAt(supervisor));
    return list;
  }

  GroupMember? get me => members.where((m) => m.isMe).firstOrNull;

  GroupMembersState copyWith({GroupInfo? group, List<GroupMember>? members, String? query, bool? loading, Object? error, bool clearError = false}) => GroupMembersState(
        group: group ?? this.group,
        members: members ?? this.members,
        query: query ?? this.query,
        loading: loading ?? this.loading,
        error: clearError ? null : error ?? this.error,
      );

  @override
  List<Object?> get props => [group, members, query, loading, error];
}

// -------------------------------------------------------------
// أفراد المجموعة (القائمة والخريطة والوجهة): الحالة الكاملة من السيرفر أول ما تفتح الشاشة،
// وبعدين المواقع لحظة بلحظة (SignalR) — ولو الاتصال اللحظي مقطوع بنحدّث كل 15 ثانية (وكل دقيقة كاحتياط لو شغّال)
// -------------------------------------------------------------
class GroupMembersCubit extends Cubit<GroupMembersState> {
  final GroupRepository _repository;
  final Duration pollInterval;

  GroupMembersCubit(this._repository, {this.pollInterval = const Duration(seconds: 15)}) : super(const GroupMembersState());

  Timer? _poll;
  StreamSubscription<GroupLocationEvent>? _live;
  int _tick = 0;
  bool _fetching = false;

  Future<void> start() async {
    _live = _repository.liveLocations().listen(_onLive, onError: (_) {});
    await refresh();
    if (isClosed) return;
    _poll = Timer.periodic(pollInterval, (_) {
      _tick++;
      if (!_repository.isLive || _tick % 4 == 0) refresh();
    });
  }

  void _onLive(GroupLocationEvent event) {
    if (isClosed) return;
    final i = state.members.indexWhere((m) => m.userId == event.userId);
    if (i < 0) return;
    final m = state.members[i];
    // موقعي أنا من جهازي مباشرة
    if (m.isMe) return;
    final updated = switch (event) {
      MemberMoved(:final location, :final at) => GroupMember(
          userId: m.userId,
          name: m.name,
          photoUrl: m.photoUrl,
          isOnline: true,
          sharesLocation: true,
          location: location,
          locationUpdatedAt: at,
          isSupervisor: m.isSupervisor,
        ),
      MemberStoppedSharing() => GroupMember(userId: m.userId, name: m.name, photoUrl: m.photoUrl, isSupervisor: m.isSupervisor),
    };
    emit(state.copyWith(members: [...state.members]..[i] = updated));
  }

  Future<void> refresh() async {
    if (_fetching || isClosed) return;
    _fetching = true;
    try {
      final group = await _repository.group();
      final members = await _repository.members();
      if (!isClosed) emit(state.copyWith(group: group, members: members, loading: false, clearError: true));
    } catch (error) {
      if (!isClosed) emit(state.copyWith(loading: false, error: error));
    } finally {
      _fetching = false;
    }
  }

  void search(String query) => emit(state.copyWith(query: query));

  @override
  Future<void> close() async {
    _poll?.cancel();
    await _live?.cancel();
    return super.close();
  }
}
