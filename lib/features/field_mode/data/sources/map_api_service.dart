import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/json_fields.dart';
import '../../../../core/utils/maps_config.dart';
import '../../../../core/utils/token_storage.dart';
import '../models/destination_info_dto.dart';
import '../models/emergency_alert_dto.dart';
import '../models/route_point_dto.dart';

// -------------------------------------------------------------
// MapApiService — طلبات الخرائط لسيرفر لبيك (C# ASP.NET Core)
// العنوان: MapsConfig.mapApiBaseUrl  — كل الطلبات مع  Authorization: Bearer <accessToken>
//
//   GET  /destinations?type=haram-gate              → 200  [DestinationInfoDto]
//   GET  /route?fromLat=..&fromLng=..&targetId=..   → 200  [RoutePointDto]   (مرتّبة بـ sequence)
//   POST /emergency     body: EmergencyAlertDto     → 200/201/202/204
//   POST /location      body: RoutePointDto         → 200/201/202/204   (موقع المستخدم الحي)
//
// الرد ممكن يكون القائمة نفسها أو { "data": [...] } — وأسماء الحقول camelCase أو PascalCase
// أي رد غير 2xx أو انقطاع أو تأخير أكتر من 8 ثواني ← Exception (والـ MapRepository بيرجع للبيانات المحلية)
// -------------------------------------------------------------
class MapApiService {
  static const timeout = Duration(seconds: 8);

  static bool get isEnabled => MapsConfig.useMapBackend;

  static Uri _uri(String path, [Map<String, String>? query]) => Uri.parse('${MapsConfig.mapApiBaseUrl}$path').replace(queryParameters: query);

  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static void _check(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException('Map API ${response.statusCode}', response.request?.url);
    }
  }

  static List<Map<String, dynamic>> _list(String body) {
    final data = unwrapData(jsonDecode(body));
    if (data is! List) throw const FormatException('Expected a list');
    return [for (final item in data) item as Map<String, dynamic>];
  }

  /// الوجهات (مثل أبواب المسجد الحرام)
  static Future<List<DestinationInfoDto>> getDestinations({String type = 'haram-gate'}) async {
    final response = await http.get(_uri('/destinations', {'type': type}), headers: await _headers()).timeout(timeout);
    _check(response);
    return [for (final json in _list(response.body)) DestinationInfoDto.fromJson(json)];
  }

  /// نقاط المسار من موقع المستخدم للوجهة
  static Future<List<RoutePointDto>> getRoutePoints({required GeoPoint from, required String targetId}) async {
    final response = await http
        .get(
          _uri('/route', {'fromLat': '${from.latitude}', 'fromLng': '${from.longitude}', 'targetId': targetId}),
          headers: await _headers(),
        )
        .timeout(timeout);
    _check(response);
    return [for (final json in _list(response.body)) RoutePointDto.fromJson(json)]..sort((a, b) => a.sequence.compareTo(b.sequence));
  }

  /// تنبيه "أنا ضائع"
  static Future<void> sendEmergencyAlert(EmergencyAlertDto alert) async {
    final response = await http.post(_uri('/emergency'), headers: await _headers(), body: jsonEncode(alert.toJson())).timeout(timeout);
    _check(response);
  }

  /// موقع المستخدم الحي
  static Future<void> updateLiveLocation(RoutePointDto point) async {
    final response = await http.post(_uri('/location'), headers: await _headers(), body: jsonEncode(point.toJson())).timeout(timeout);
    _check(response);
  }
}
