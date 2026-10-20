import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/family_circle.dart';
import '../../domain/entities/family_member.dart';
import '../../domain/repositories/family_repository.dart';

class FamilyMembersState extends Equatable {
  final List<FamilyMember> members;
  final FamilyCircle? circle;
  final String query;

  /// لسا ما رد السيرفر أول مرة
  final bool loading;
  final Object? error;

  const FamilyMembersState({this.members = const [], this.circle, this.query = '', this.loading = true, this.error});

  /// أنا أول، وبعدين الباقي بترتيب السيرفر — والبحث بالاسم
  List<FamilyMember> get visible {
    final q = query.trim();
    final list = [for (final m in members) if (q.isEmpty || m.name.contains(q)) m];
    final mine = list.indexWhere((m) => m.isMe);
    if (mine > 0) list.insert(0, list.removeAt(mine));
    return list;
  }

  /// الأفراد اللي بيشاركوا موقعهم ووصل موقعهم (على الخريطة)
  List<FamilyMember> get onMap => [for (final m in members) if (m.sharesLocation && m.location != null) m];

  FamilyMembersState copyWith({List<FamilyMember>? members, FamilyCircle? circle, String? query, bool? loading, Object? error, bool clearError = false}) => FamilyMembersState(
        members: members ?? this.members,
        circle: circle ?? this.circle,
        query: query ?? this.query,
        loading: loading ?? this.loading,
        error: clearError ? null : error ?? this.error,
      );

  @override
  List<Object?> get props => [members, circle, query, loading, error];
}

// -------------------------------------------------------------
// أفراد دائرة العائلة (القائمة والخريطة): المحفوظين فوراً وبعدين من السيرفر،
// وبيتحدّثوا كل 15 ثانية وهي مفتوحة (الاتصال والمواقع)
// -------------------------------------------------------------
class FamilyMembersCubit extends Cubit<FamilyMembersState> {
  final FamilyRepository _repository;
  final Duration pollInterval;

  FamilyMembersCubit(this._repository, {this.pollInterval = const Duration(seconds: 15)}) : super(const FamilyMembersState());

  Timer? _poll;
  bool _fetching = false;

  Future<void> start() async {
    final cached = await _repository.cachedMembers();
    final circle = await _repository.cachedCircle();
    if (isClosed) return;
    emit(state.copyWith(members: cached.isEmpty ? null : cached, circle: circle));
    await refresh();
    if (isClosed) return;
    _poll = Timer.periodic(pollInterval, (_) => refresh());
  }

  Future<void> refresh() async {
    if (_fetching || isClosed) return;
    _fetching = true;
    try {
      final results = await Future.wait([_repository.members(), _repository.myCircle()]);
      if (!isClosed) emit(state.copyWith(members: results[0] as List<FamilyMember>, circle: results[1] as FamilyCircle?, loading: false, clearError: true));
    } catch (error) {
      if (!isClosed) emit(state.copyWith(loading: false, error: error));
    } finally {
      _fetching = false;
    }
  }

  void search(String query) => emit(state.copyWith(query: query));

  /// ApiException لو فشل (مثلاً 403: مش صاحب الدائرة)
  Future<void> remove(String userId) async {
    await _repository.removeMember(userId);
    if (isClosed) return;
    emit(state.copyWith(members: [for (final m in state.members) if (m.userId != userId) m]));
  }

  @override
  Future<void> close() {
    _poll?.cancel();
    return super.close();
  }
}
