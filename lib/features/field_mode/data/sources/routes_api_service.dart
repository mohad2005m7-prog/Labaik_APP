import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/maps_config.dart';
import '../models/route_info.dart';

// -------------------------------------------------------------
// Google Routes API — مسار السيارة من موقع المستخدم للوجهة
// (لازم تفعيل "Routes API" لنفس المفتاح MAPS_API_KEY)
// -------------------------------------------------------------
class RoutesApiService {
  static const _url = 'https://routes.googleapis.com/directions/v2:computeRoutes';
  static const _fields = 'routes.distanceMeters,routes.duration,routes.polyline.encodedPolyline,routes.legs.steps.distanceMeters';

  // الشبكة الضعيفة ما بتعلّق الشاشة: بعد هالمدة بنرجع للحساب المحلي
  static const timeout = Duration(seconds: 8);

  static bool get isConfigured => MapsConfig.apiKey.isNotEmpty;

  static Future<RouteInfo> computeRoute(GeoPoint from, GeoPoint to) async {
    final response = await http
        .post(
          Uri.parse(_url),
          headers: {'Content-Type': 'application/json', 'X-Goog-Api-Key': MapsConfig.apiKey, 'X-Goog-FieldMask': _fields},
          body: jsonEncode({'origin': _waypoint(from), 'destination': _waypoint(to), 'travelMode': 'DRIVE', 'routingPreference': 'TRAFFIC_AWARE'}),
        )
        .timeout(timeout);
    if (response.statusCode != 200) {
      throw http.ClientException('Routes API ${response.statusCode}', response.request?.url);
    }
    return parse(response.body);
  }

  static Map<String, Object> _waypoint(GeoPoint p) => {
    'location': {
      'latLng': {'latitude': p.latitude, 'longitude': p.longitude},
    },
  };

  /// قراءة رد Routes API
  static RouteInfo parse(String body) {
    final routes = (jsonDecode(body) as Map<String, dynamic>)['routes'] as List?;
    if (routes == null || routes.isEmpty) throw const FormatException('No route');
    final route = routes.first as Map<String, dynamic>;

    final path = GeoUtils.decodePolyline((route['polyline'] as Map<String, dynamic>)['encodedPolyline'] as String);
    if (path.length < 2) throw const FormatException('Empty route');

    // المدة بتوصل نص مثل "1234s"
    final duration = double.tryParse((route['duration'] as String? ?? '0s').replaceAll('s', '')) ?? 0;
    final steps = [
      for (final leg in (route['legs'] as List? ?? const []))
        for (final step in ((leg as Map<String, dynamic>)['steps'] as List? ?? const []))
          (((step as Map<String, dynamic>)['distanceMeters'] as num?) ?? 0).toDouble(),
    ];

    return RouteInfo(
      path: path,
      distanceMeters: ((route['distanceMeters'] as num?) ?? GeoUtils.pathLength(path)).toDouble(),
      durationSeconds: duration,
      stepDistances: steps,
    );
  }
}
