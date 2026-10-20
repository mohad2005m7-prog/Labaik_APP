import '../../../../core/utils/geo_utils.dart';
import '../../domain/entities/family_circle.dart';
import '../../domain/entities/family_member.dart';

// -------------------------------------------------------------
// بيانات تجريبية مؤقتة (بدون سيرفر — BackendMode) بنفس محتوى Figma:
// دائرة "عائلة أحمد" (A7K9P2) وأفرادها خالد وسارة وعبدالله حوالين المسجد الحرام، ونقطة التجمع عند باب الملك فهد
// إنت بياناتك الحقيقية (موقعك الفعلي لما توافق على المشاركة) — بتنشال لما نرجع نربط السيرفر
// -------------------------------------------------------------
abstract final class FamilyDemoSource {
  static const circleId = 'demo-family';
  static const code = 'A7K9P2';

  /// نقطة التجمع: باب الملك فهد (نفس إحداثيات HaramGates)
  static const meetingPoint = MeetingPoint(name: 'باب الملك فهد', location: GeoPoint(21.42270, 39.82360));

  static const circle = FamilyCircle(id: circleId, name: 'عائلة أحمد', code: code, membersCount: 4, meetingPoint: meetingPoint);

  static const summary = FamilyCircleSummary(id: circleId, name: 'عائلة أحمد', membersCount: 3);

  /// أفراد Figma (111:5255): خالد (اخر ظهور 18 د — موقعه غير متاح)، سارة (لم يشارك موقعه)، عبدالله (موقعه متاح)
  static List<FamilyMember> others(DateTime now) => [
        FamilyMember(
          userId: 'demo-khaled',
          name: 'خالد',
          lastSeenAt: now.subtract(const Duration(minutes: 18)),
          sharesLocation: true,
          location: const GeoPoint(21.42420, 39.82230),
          locationUpdatedAt: now.subtract(const Duration(minutes: 40)),
        ),
        const FamilyMember(userId: 'demo-sara', name: 'سارة', isOnline: true),
        FamilyMember(
          userId: 'demo-abdullah',
          name: 'عبدالله',
          isOnline: true,
          sharesLocation: true,
          location: const GeoPoint(21.42150, 39.82300),
          locationUpdatedAt: now.subtract(const Duration(minutes: 2)),
        ),
      ];
}
