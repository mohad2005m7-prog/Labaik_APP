import 'dart:async';

import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/json_fields.dart';
import '../../../../core/utils/location_service.dart';
import '../../../auth/data/account_registry.dart';
import '../../domain/entities/group_info.dart';
import '../../domain/entities/group_location_event.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/repositories/group_repository.dart';
import '../sources/group_api.dart';
import '../sources/group_realtime.dart';

// -------------------------------------------------------------
// المجموعة من السيرفر: مجموعتي (/home) وأعضاؤها ومواقعهم (/groups/{id}/locations) + التحديث اللحظي (/hubs/location)
// أنا (isMe) على الخريطة بموقع جهازي الفعلي لو مسموح (أدق وأحدث من آخر موقع وصل للسيرفر)
// السيرفر ما فيه نقطة تجمع ولا تأكيد وصول (docs/backend_pending.md):
//   نقطة التجمع null ("لم تُحدَّد نقطة تجمع بعد") — وتأكيد الوصول بينحفظ على الجهاز بس
// -------------------------------------------------------------
class GroupRepositoryImpl implements GroupRepository {
  GroupRepositoryImpl({GroupApi? api}) : _api = api ?? GroupApi.server();

  final GroupApi _api;
  String? _groupId;

  // تأكيد الوصول لكل حساب لحاله (بإيميله)
  static final arrivedAt = <String, DateTime>{};

  @override
  Future<GroupInfo?> group() async {
    final group = await _api.myGroup();
    _groupId = group?.id;
    return group == null ? null : GroupInfo(id: group.id, name: group.name);
  }

  @override
  Future<List<GroupMember>> members() async {
    final id = _groupId ?? (await group())?.id;
    if (id == null) return const [];
    final members = await _api.members(id);
    final i = members.indexWhere((m) => m.isMe);
    if (i < 0 || await LocationService.checkAccess() != LocationAccess.granted) return members;
    final here = await LocationService.lastKnownPosition();
    if (here == null) return members;
    final me = members[i];
    return [...members]..[i] = GroupMember(
        userId: me.userId,
        name: me.name,
        isMe: true,
        isOnline: true,
        sharesLocation: me.sharesLocation,
        location: here,
        locationUpdatedAt: DateTime.now(),
        isSupervisor: me.isSupervisor,
      );
  }

  @override
  Future<void> confirmArrival() async => arrivedAt[await AccountRegistry.currentEmail() ?? ''] = DateTime.now();

  @override
  Stream<GroupLocationEvent> liveLocations() {
    final moved = GroupRealtime.location.on('LocationUpdated').expand((args) sync* {
      final json = args.firstOrNull;
      if (json is! Map<String, dynamic>) return;
      final lat = json.field('latitude'), lng = json.field('longitude');
      final userId = json.field('userId')?.toString();
      if (userId == null || lat is! num || lng is! num) return;
      final at = DateTime.tryParse(json.field('updatedAtUtc')?.toString() ?? '')?.toLocal() ?? DateTime.now();
      yield MemberMoved(userId, GeoPoint(lat.toDouble(), lng.toDouble()), at);
    });
    final stopped = GroupRealtime.location.on('StoppedSharing').expand((args) sync* {
      final json = args.firstOrNull;
      final userId = json is Map<String, dynamic> ? json.field('userId')?.toString() : null;
      if (userId != null) yield MemberStoppedSharing(userId);
    });
    return _merge(moved, stopped);
  }

  @override
  bool get isLive => GroupRealtime.location.isConnected;

  static Stream<T> _merge<T>(Stream<T> a, Stream<T> b) {
    final subs = <StreamSubscription<T>>[];
    late final StreamController<T> controller;
    controller = StreamController<T>(
      onListen: () {
        subs
          ..add(a.listen(controller.add))
          ..add(b.listen(controller.add));
      },
      onCancel: () async {
        for (final s in subs) {
          await s.cancel();
        }
      },
    );
    return controller.stream;
  }
}
