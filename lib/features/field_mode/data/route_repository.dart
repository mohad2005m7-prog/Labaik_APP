import 'dart:math' as math;

import '../../../core/utils/geo_utils.dart';
import 'models/field_place.dart';
import 'models/route_info.dart';
import 'sources/routes_api_service.dart';

// -------------------------------------------------------------
// RouteRepository — مصدر المسار:
// 1) Google Routes API (المسار الحقيقي على الطرق)
// 2) إذا ما في مفتاح أو الشبكة ضعيفة أو الطلب فشل: حساب محلي فوراً
//    (خط مباشر + المسافة بمعادلة Haversine + الوقت من متوسط السرعة)
// -------------------------------------------------------------
class RouteRepository {
  /// في مصدر لمسار الطرق الحقيقي (مفتاح Google موجود)
  static bool get canFetchRoads => RoutesApiService.isConfigured;

  static Future<RouteInfo> getRoute(GeoPoint from, FieldPlace to) async {
    if (RoutesApiService.isConfigured) {
      try {
        return await RoutesApiService.computeRoute(from, to.location);
      } catch (_) {
        // بنكمل بالحساب المحلي
      }
    }
    return estimate(from, to);
  }

  /// تقدير محلي بدون إنترنت (المسافة المباشرة بمعادلة Haversine)
  static RouteInfo estimate(GeoPoint from, FieldPlace to) {
    final meters = GeoUtils.haversine(from, to.location);
    return RouteInfo(
      path: [from, to.location],
      distanceMeters: meters,
      durationSeconds: meters / (estimateSpeedKmh(meters, to) / 3.6),
      isEstimate: true,
    );
  }

  /// متوسط السرعة حسب البُعد: سفر بين المدن (مثلاً من غزة) — سيارة جوّا المدينة — وآخر جزء بسرعة الوجهة (مشي للأبواب)
  static double estimateSpeedKmh(double meters, FieldPlace to) {
    if (meters > 50000) return 90;
    if (meters > 2000) return math.max(to.averageSpeedKmh, 25);
    return to.averageSpeedKmh;
  }
}
