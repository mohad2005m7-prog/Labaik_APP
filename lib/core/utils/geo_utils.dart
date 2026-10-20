import 'dart:math' as math;

// -------------------------------------------------------------
// حسابات جغرافية محلية (بدون إنترنت):
// المسافة بمعادلة Haversine — فك ترميز خط المسار من Google — المسافة المتبقية على طول المسار
// -------------------------------------------------------------

/// نقطة جغرافية (خط العرض وخط الطول بالدرجات)
class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint(this.latitude, this.longitude);
}

/// تقدّم المستخدم على المسار
typedef RouteProgress = ({
  double remainingMeters, // المسافة المتبقية على طول المسار
  double offRouteMeters, // بُعد المستخدم عن خط المسار
});

class GeoUtils {
  static const earthRadiusMeters = 6371000.0;

  static double _rad(double degrees) => degrees * math.pi / 180;

  /// المسافة المباشرة بين نقطتين بالمتر (Haversine)
  static double haversine(GeoPoint a, GeoPoint b) {
    final dLat = _rad(b.latitude - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final sinLat = math.sin(dLat / 2);
    final sinLng = math.sin(dLng / 2);
    final h = sinLat * sinLat + math.cos(_rad(a.latitude)) * math.cos(_rad(b.latitude)) * sinLng * sinLng;
    return 2 * earthRadiusMeters * math.asin(math.min(1, math.sqrt(h)));
  }

  /// طول خط مكوّن من عدة نقاط بالمتر
  static double pathLength(List<GeoPoint> path) {
    var total = 0.0;
    for (var i = 1; i < path.length; i++) {
      total += haversine(path[i - 1], path[i]);
    }
    return total;
  }

  /// فك ترميز خط المسار (Encoded Polyline Algorithm من Google)
  static List<GeoPoint> decodePolyline(String encoded) {
    final points = <GeoPoint>[];
    var index = 0;
    var lat = 0;
    var lng = 0;

    int next() {
      var result = 0;
      var shift = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < encoded.length);
      return (result & 1) != 0 ? ~(result >> 1) : result >> 1;
    }

    while (index < encoded.length) {
      lat += next();
      if (index >= encoded.length) break;
      lng += next();
      points.add(GeoPoint(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  /// المسافة المتبقية من موقع المستخدم لآخر المسار (من أقرب نقطة على المسار)
  /// وبُعد المستخدم عن المسار — الحساب بإسقاط مستوي محلي حوالين موقع المستخدم
  static RouteProgress progressAlong(List<GeoPoint> path, GeoPoint position) {
    if (path.isEmpty) return (remainingMeters: 0, offRouteMeters: 0);
    if (path.length == 1) {
      final d = haversine(position, path.first);
      return (remainingMeters: d, offRouteMeters: d);
    }

    // إحداثيات مستوية بالمتر (x شرق، y شمال) حوالين موقع المستخدم
    final cosLat = math.cos(_rad(position.latitude));
    double x(GeoPoint p) => _rad(p.longitude - position.longitude) * cosLat * earthRadiusMeters;
    double y(GeoPoint p) => _rad(p.latitude - position.latitude) * earthRadiusMeters;

    var bestIndex = 0;
    var bestT = 0.0;
    var bestDistance = double.infinity;
    for (var i = 0; i < path.length - 1; i++) {
      final ax = x(path[i]), ay = y(path[i]);
      final bx = x(path[i + 1]), by = y(path[i + 1]);
      final dx = bx - ax, dy = by - ay;
      final lengthSq = dx * dx + dy * dy;
      // إسقاط موقع المستخدم (0,0) على القطعة
      final t = lengthSq == 0 ? 0.0 : ((-ax * dx - ay * dy) / lengthSq).clamp(0.0, 1.0);
      final px = ax + t * dx, py = ay + t * dy;
      final distance = math.sqrt(px * px + py * py);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
        bestT = t;
      }
    }

    // الباقي من القطعة الأقرب + كل القطع اللي بعدها
    var remaining = haversine(path[bestIndex], path[bestIndex + 1]) * (1 - bestT);
    for (var i = bestIndex + 1; i < path.length - 1; i++) {
      remaining += haversine(path[i], path[i + 1]);
    }
    return (remainingMeters: remaining, offRouteMeters: bestDistance);
  }
}
