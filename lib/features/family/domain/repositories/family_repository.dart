import '../../../../core/utils/geo_utils.dart';
import '../entities/family_circle.dart';
import '../entities/family_member.dart';

// -------------------------------------------------------------
// دائرة العائلة: الإنشاء، الانضمام بالرمز (أو QR)، الأفراد، ومشاركة الموقع — كلها من السيرفر
// -------------------------------------------------------------
abstract class FamilyRepository {
  /// آخر دائرة محفوظة على الجهاز (بتطلع فوراً)
  Future<FamilyCircle?> cachedCircle();

  /// دائرتي من السيرفر — null = مش بدائرة
  Future<FamilyCircle?> myCircle();

  /// إنشاء دائرتي (ولو عندي وحدة السيرفر بيرجّعها نفسها)
  Future<FamilyCircle> createCircle();

  /// البحث بالرمز — null = ما في دائرة بهالرمز
  Future<FamilyCircleSummary?> findCircle(String code);

  Future<FamilyCircle> joinCircle(String circleId);

  Future<List<FamilyMember>> cachedMembers();

  Future<List<FamilyMember>> members();

  Future<void> setLocationSharing(bool enabled);

  Future<void> sendLocation(GeoPoint point);

  /// حذف فرد من الدائرة (لصاحب الدائرة بس)
  Future<void> removeMember(String userId);
}
