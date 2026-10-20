import 'package:labaik/core/utils/geo_utils.dart';
import 'package:labaik/features/family/domain/entities/family_circle.dart';
import 'package:labaik/features/family/domain/entities/family_member.dart';
import 'package:labaik/features/family/domain/repositories/family_repository.dart';

/// سيرفر دائرة العائلة الوهمي للاختبارات: بيسجّل الإنشاء والانضمام ومشاركة الموقع والحذف
class FakeFamily implements FamilyRepository {
  FamilyCircle? circle;
  List<FamilyMember> list = [];

  /// الدوائر اللي بتنلاقى بالرمز
  final Map<String, FamilyCircleSummary> codes = {};

  int created = 0;
  final joined = <String>[];
  final sharing = <bool>[];
  final removed = <String>[];

  FakeFamily({this.circle});

  @override
  Future<FamilyCircle?> cachedCircle() async => null;

  @override
  Future<FamilyCircle?> myCircle() async => circle;

  @override
  Future<FamilyCircle> createCircle() async {
    created++;
    return circle ??= const FamilyCircle(id: 'mine', name: 'عائلة محمد', code: 'MINE01', isOwner: true);
  }

  @override
  Future<FamilyCircleSummary?> findCircle(String code) async => codes[code];

  @override
  Future<FamilyCircle> joinCircle(String circleId) async {
    joined.add(circleId);
    final found = codes.values.firstWhere((c) => c.id == circleId);
    return circle = FamilyCircle(id: found.id, name: found.name, code: 'A7K9P2', membersCount: found.membersCount + 1);
  }

  @override
  Future<List<FamilyMember>> cachedMembers() async => const [];

  @override
  Future<List<FamilyMember>> members() async => list;

  @override
  Future<void> setLocationSharing(bool enabled) async {
    sharing.add(enabled);
    circle = circle?.copyWith(mySharesLocation: enabled);
  }

  @override
  Future<void> sendLocation(GeoPoint point) async {}

  @override
  Future<void> removeMember(String userId) async {
    removed.add(userId);
    list = [for (final m in list) if (m.userId != userId) m];
  }
}
