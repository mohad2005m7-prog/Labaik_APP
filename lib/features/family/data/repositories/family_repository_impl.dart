import '../../../../core/utils/geo_utils.dart';
import '../../domain/entities/family_circle.dart';
import '../../domain/entities/family_member.dart';
import '../../domain/repositories/family_repository.dart';
import '../sources/family_api.dart';
import '../sources/family_local_source.dart';

// -------------------------------------------------------------
// دائرة العائلة: من السيرفر، وكل رد ناجح بينحفظ على الجهاز
// -------------------------------------------------------------
class FamilyRepositoryImpl implements FamilyRepository {
  final FamilyApi _api;
  final FamilyLocalSource _local;

  FamilyRepositoryImpl({FamilyApi? api, FamilyLocalSource? local})
      : _api = api ?? FamilyApi.server(),
        _local = local ?? FamilyLocalSource();

  @override
  Future<FamilyCircle?> cachedCircle() => _local.circle();

  @override
  Future<FamilyCircle?> myCircle() async {
    final circle = await _api.myCircle();
    await _local.saveCircle(circle);
    return circle;
  }

  @override
  Future<FamilyCircle> createCircle() async {
    final circle = await _api.createCircle();
    await _local.saveCircle(circle);
    return circle;
  }

  @override
  Future<FamilyCircleSummary?> findCircle(String code) => _api.findCircle(code);

  @override
  Future<FamilyCircle> joinCircle(String circleId) async {
    final circle = await _api.joinCircle(circleId);
    await _local.saveCircle(circle);
    return circle;
  }

  @override
  Future<List<FamilyMember>> cachedMembers() => _local.members();

  @override
  Future<List<FamilyMember>> members() async {
    final list = await _api.members();
    await _local.saveMembers(list);
    return list;
  }

  @override
  Future<void> setLocationSharing(bool enabled) async {
    await _api.setLocationSharing(enabled);
    final circle = await _local.circle();
    if (circle != null) await _local.saveCircle(circle.copyWith(mySharesLocation: enabled));
  }

  @override
  Future<void> sendLocation(GeoPoint point) => _api.sendLocation(point);

  @override
  Future<void> removeMember(String userId) async {
    await _api.removeMember(userId);
    final members = await _local.members();
    await _local.saveMembers([for (final m in members) if (m.userId != userId) m]);
  }
}
