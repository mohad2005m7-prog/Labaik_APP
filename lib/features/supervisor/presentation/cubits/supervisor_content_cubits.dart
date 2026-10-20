import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/group_member.dart';
import '../../domain/entities/supervisor_group.dart';
import '../../domain/entities/supervisor_inbox.dart';
import '../../domain/entities/trip_program.dart';
import '../../domain/repositories/supervisor_repository.dart';

// -------------------------------------------------------------
// Cubits محتوى شاشات المشرف (قراءة + بحث): المجموعات، الأعضاء، البرنامج، الدردشات، الإشعارات
// كل واحد بيحمل بياناته من SupervisorRepository، والبحث بيفلتر بدون ما يعيد التحميل
// -------------------------------------------------------------

/// بيانات قائمة + نص البحث
class ListState<T> extends Equatable {
  final bool loaded;
  final List<T> items;
  final String query;

  /// آخر تحميل فشل (ما في إنترنت أو خطأ بالسيرفر) — والبيانات اللي معروضة هي آخر اللي وصل
  final bool failed;

  const ListState({this.loaded = false, this.items = const [], this.query = '', this.failed = false});

  ListState<T> copyWith({bool? loaded, List<T>? items, String? query, bool? failed}) =>
      ListState(loaded: loaded ?? this.loaded, items: items ?? this.items, query: query ?? this.query, failed: failed ?? this.failed);

  @override
  List<Object?> get props => [loaded, items, query, failed];
}

abstract class _ListCubit<T> extends Cubit<ListState<T>> {
  _ListCubit() : super(ListState<T>());

  Future<List<T>> fetch();

  Future<void> load() async {
    try {
      final items = await fetch();
      if (!isClosed) emit(state.copyWith(loaded: true, items: items, failed: false));
    } catch (_) {
      // ما في إنترنت أو السيرفر ما رد — بنضل على آخر بيانات وصلت
      if (!isClosed) emit(state.copyWith(loaded: true, failed: true));
    }
  }

  void search(String query) => emit(state.copyWith(query: query));

  StreamSubscription<void>? _changes;

  /// تحديث لحظي: كل ما وصل جديد من السيرفر بنعيد التحميل
  void watch(Stream<void> changes) => _changes ??= changes.listen((_) => load(), onError: (_) {});

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}

// ---------------- المجموعات ----------------
class SupervisorGroupsCubit extends _ListCubit<SupervisorGroup> {
  SupervisorGroupsCubit(this._repository);

  final SupervisorRepository _repository;

  @override
  Future<List<SupervisorGroup>> fetch() => _repository.getGroups();

  /// المجموعة الأساسية (الرئيسية وإرسال الإعلانات)
  SupervisorGroup? get mainGroup => state.items.isEmpty ? null : state.items.first;
}

extension GroupsFilter on ListState<SupervisorGroup> {
  List<SupervisorGroup> get visible {
    final q = query.trim();
    return q.isEmpty ? items : items.where((g) => g.name.contains(q)).toList();
  }
}

// ---------------- الأعضاء ----------------
enum MembersTab { all, present, absent }

class GroupMembersCubit extends _ListCubit<GroupMember> {
  GroupMembersCubit(this._repository, this.groupId);

  final SupervisorRepository _repository;
  final String groupId;

  @override
  Future<List<GroupMember>> fetch() => _repository.getMembers(groupId);
}

extension MembersFilter on ListState<GroupMember> {
  // الحضور لسا مش بالسيرفر (null) — فالعدّين 0 لحد ما ينضاف
  int get presentCount => items.where((m) => m.present == true).length;
  int get absentCount => items.where((m) => m.present == false).length;

  /// بالترتيب اللي بيرجع من السيرفر، والبحث بالاسم أو رقم المعتمر
  List<GroupMember> visible(MembersTab tab) {
    final q = query.trim();
    return items.where((m) {
      if (tab == MembersTab.present && m.present != true) return false;
      if (tab == MembersTab.absent && m.present != false) return false;
      return q.isEmpty || m.name.contains(q) || (m.number != null && '${m.number}' == q);
    }).toList();
  }
}

// ---------------- برنامج الرحلة ----------------
class TripProgramCubit extends _ListCubit<TripDay> {
  TripProgramCubit(this._repository, this.groupId);

  final SupervisorRepository _repository;
  final String groupId;

  @override
  Future<List<TripDay>> fetch() => _repository.getProgram(groupId);

  /// بترمي الخطأ للشاشة (تعرض رسالته) — والبرنامج الجديد بيطلع فوراً
  Future<void> addActivity({required DateTime day, required String title, DateTime? time, String? place}) async {
    final days = await _repository.addProgramActivity(groupId, day: day, title: title, time: time, place: place);
    if (!isClosed) emit(state.copyWith(loaded: true, items: days));
  }
}

// ---------------- الدردشات ----------------
class SupervisorChatsCubit extends _ListCubit<ChatThread> {
  SupervisorChatsCubit(this._repository);

  final SupervisorRepository _repository;

  @override
  Future<List<ChatThread>> fetch() => _repository.getChats();
}

extension ChatsFilter on ListState<ChatThread> {
  List<ChatThread> get visible {
    final q = query.trim();
    return q.isEmpty ? items : items.where((t) => t.name.contains(q) || t.lastMessage.contains(q)).toList();
  }
}

// ---------------- الإشعارات ----------------
class SupervisorNotificationsCubit extends _ListCubit<NotificationSection> {
  SupervisorNotificationsCubit(this._repository);

  final SupervisorRepository _repository;

  @override
  Future<List<NotificationSection>> fetch() => _repository.getNotifications();

  /// فتح شاشة الإشعارات: أحدث قائمة، وكلها بتصير مقروءة بالسيرفر
  Future<void> opened() async {
    await load();
    try {
      await _repository.markNotificationsRead();
    } catch (_) {}
  }
}
