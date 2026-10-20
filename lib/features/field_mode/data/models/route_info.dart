import '../../../../core/utils/geo_utils.dart';

// -------------------------------------------------------------
// مسار من موقع المستخدم للوجهة
// -------------------------------------------------------------
class RouteInfo {
  final List<GeoPoint> path; // خط المسار على الخريطة
  final double distanceMeters; // طول المسار
  final double durationSeconds; // الوقت المتوقع
  final List<double> stepDistances; // أطوال خطوات الإرشاد بالترتيب (لـ "لمسافة 2.8 كم")
  final bool isEstimate; // true = محسوب محلياً (خط مباشر + Haversine) بدون إنترنت

  const RouteInfo({
    required this.path,
    required this.distanceMeters,
    required this.durationSeconds,
    this.stepDistances = const [],
    this.isEstimate = false,
  });
}
