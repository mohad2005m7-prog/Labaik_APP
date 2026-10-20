import 'dart:async';

import 'package:labaik/core/utils/geo_utils.dart';
import 'package:labaik/features/group/domain/entities/group_info.dart';
import 'package:labaik/features/group/domain/entities/group_location_event.dart';
import 'package:labaik/features/group/domain/entities/group_member.dart';
import 'package:labaik/features/group/domain/repositories/group_repository.dart';

// -------------------------------------------------------------
// مجموعة للاختبارات (بنفس أفراد Figma — "لائحة أفراد المجموعة" 111:5507 و"خريطة المجموعة" 111:6611)
// مع نقطة تجمع عند باب الملك فهد — والمواقع اللحظية من [live]
// -------------------------------------------------------------
class FakeGroupRepository implements GroupRepository {
  int arrivals = 0;
  final live = StreamController<GroupLocationEvent>.broadcast();

  static const info = GroupInfo(
    id: 'g1',
    name: 'حملة النور',
    meetingPoint: GroupMeetingPoint(title: 'بوابة الملك فهد — المسجد الحرام', direction: 'باب الملك فهد', location: GeoPoint(21.42270, 39.82360)),
  );

  static List<GroupMember> people(DateTime now) {
    GroupMember online(String id, String name, double lat, double lng, {bool supervisor = false}) => GroupMember(
          userId: id,
          name: name,
          isOnline: true,
          sharesLocation: true,
          location: GeoPoint(lat, lng),
          locationUpdatedAt: now.subtract(const Duration(minutes: 1)),
          isSupervisor: supervisor,
        );
    GroupMember away(String id, String name, double lat, double lng, int minutes) => GroupMember(
          userId: id,
          name: name,
          lastSeenAt: now.subtract(Duration(minutes: minutes)),
          sharesLocation: true,
          location: GeoPoint(lat, lng),
          locationUpdatedAt: now.subtract(Duration(minutes: minutes)),
        );
    return [
      online('s', 'مشرف المجموعة', 21.42190, 39.82450, supervisor: true),
      GroupMember(userId: 'khaled', name: 'خالد', lastSeenAt: now.subtract(const Duration(minutes: 18)), sharesLocation: true),
      const GroupMember(userId: 'sara', name: 'سارة', isOnline: true),
      online('abdullah', 'عبدالله', 21.42160, 39.82320),
      online('maha', 'مها', 21.42400, 39.82170),
      away('sondos', 'سندس', 21.42370, 39.82260, 25),
      online('mona', 'منى', 21.42330, 39.82200),
      away('rola', 'رولا', 21.42290, 39.82290, 40),
      online('ahmad', 'احمد', 21.42250, 39.82140),
      online('moamen', 'مؤمن', 21.42210, 39.82400),
      const GroupMember(userId: 'me', name: 'محمد', isMe: true, isOnline: true),
    ];
  }

  @override
  Future<GroupInfo?> group() async => info;

  @override
  Future<List<GroupMember>> members() async => people(DateTime.now());

  @override
  Future<void> confirmArrival() async => arrivals++;

  @override
  Stream<GroupLocationEvent> liveLocations() => live.stream;

  @override
  bool get isLive => true;
}
