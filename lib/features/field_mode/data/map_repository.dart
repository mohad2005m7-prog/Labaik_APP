import 'dart:convert';

import '../../../core/utils/geo_utils.dart';
import '../../../core/utils/token_storage.dart';
import 'models/destination_info_dto.dart';
import 'models/emergency_alert_dto.dart';
import 'models/field_place.dart';
import 'models/route_info.dart';
import 'models/route_point_dto.dart';
import 'route_repository.dart';
import 'sources/haram_gates.dart';
import 'sources/map_api_service.dart';

// -------------------------------------------------------------
// MapRepository — كل بيانات الخرائط من مكان واحد:
//   الأبواب:  سيرفر لبيك ← القائمة المحلية (HaramGates)
//   المسار:   سيرفر لبيك ← Google Routes API ← حساب محلي فوري (Haversine) — الشاشة ما بتعلق أبداً
//   "أنا ضائع" والموقع الحي: للسيرفر (لو الربط مفعّل)، وأي فشل ما بيوقف الملاحة
// -------------------------------------------------------------
class MapRepository {
  /// في مصدر لمسار الطرق (سيرفر لبيك أو Google)
  static bool get canFetchRoutes => MapApiService.isEnabled || RouteRepository.canFetchRoads;

  /// أبواب المسجد الحرام
  static Future<List<DestinationInfoDto>> getHaramGates() async {
    if (MapApiService.isEnabled) {
      try {
        final gates = await MapApiService.getDestinations(type: 'haram-gate');
        if (gates.isNotEmpty) return gates;
      } catch (_) {
        // بنكمل بالقائمة المحلية
      }
    }
    return HaramGates.defaults;
  }

  /// المسار من موقع المستخدم للوجهة
  static Future<RouteInfo> getRoute(GeoPoint from, FieldPlace to) async {
    final targetId = to.targetId;
    if (MapApiService.isEnabled && targetId != null) {
      try {
        final route = routeFromPoints(await MapApiService.getRoutePoints(from: from, targetId: targetId), fallbackSpeedKmh: to.averageSpeedKmh);
        if (route != null) return route;
      } catch (_) {
        // بنكمل بـ Google أو الحساب المحلي
      }
    }
    return RouteRepository.getRoute(from, to);
  }

  /// نقاط السيرفر ← مسار: الطول من النقاط والوقت من سرعة كل جزء (أو متوسط سرعة الوجهة)
  static RouteInfo? routeFromPoints(List<RoutePointDto> points, {required double fallbackSpeedKmh}) {
    if (points.length < 2) return null;
    final sorted = [...points]..sort((a, b) => a.sequence.compareTo(b.sequence));
    final path = [for (final p in sorted) p.point];
    var meters = 0.0;
    var seconds = 0.0;
    for (var i = 1; i < sorted.length; i++) {
      final segment = GeoUtils.haversine(path[i - 1], path[i]);
      final speedKmh = sorted[i - 1].speed > 0 ? sorted[i - 1].speed : fallbackSpeedKmh;
      meters += segment;
      seconds += segment / (speedKmh / 3.6);
    }
    return RouteInfo(path: path, distanceMeters: meters, durationSeconds: seconds);
  }

  /// "أنا ضائع": تنبيه بموقع المستخدم — true إذا وصل للسيرفر
  static Future<bool> sendLostAlert(GeoPoint position) async {
    if (!MapApiService.isEnabled) return false;
    final userId = await currentUserId();
    if (userId == null) return false;
    try {
      await MapApiService.sendEmergencyAlert(
        EmergencyAlertDto(userId: userId, currentLat: position.latitude, currentLng: position.longitude, timestamp: DateTime.now().toUtc()),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // الموقع الحي: تحديث كل 30 ثانية على الأكتر
  static const _reportInterval = Duration(seconds: 30);
  static int _sequence = 0;
  static DateTime? _lastReportTime;
  static GeoPoint? _lastReportPoint;

  /// تحديث موقع المستخدم الحي على السيرفر (السرعة محسوبة من آخر تحديث)
  static Future<void> reportLocation(GeoPoint position, {DateTime? now}) async {
    if (!MapApiService.isEnabled) return;
    final time = now ?? DateTime.now();
    final lastTime = _lastReportTime;
    if (lastTime != null && time.difference(lastTime) < _reportInterval) return;

    final lastPoint = _lastReportPoint;
    final elapsed = lastTime == null ? 0 : time.difference(lastTime).inMilliseconds / 1000;
    final speedKmh = lastPoint == null || elapsed <= 0 ? 0.0 : GeoUtils.haversine(lastPoint, position) / elapsed * 3.6;
    _lastReportTime = time;
    _lastReportPoint = position;
    try {
      await MapApiService.updateLiveLocation(
        RoutePointDto(latitude: position.latitude, longitude: position.longitude, sequence: ++_sequence, speed: speedKmh),
      );
    } catch (_) {
      // التحديث الجاي بيحاول مرة ثانية
    }
  }

  /// رقم المستخدم من الـ JWT المحفوظ (ASP.NET Core: nameidentifier أو sub)
  static Future<String?> currentUserId() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final claims = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))) as Map<String, dynamic>;
      final id =
          claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
          claims['nameid'] ??
          claims['sub'] ??
          claims['userId'] ??
          claims['id'];
      return id?.toString();
    } catch (_) {
      return null;
    }
  }
}
