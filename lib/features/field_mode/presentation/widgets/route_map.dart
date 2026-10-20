import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/maps_config.dart';
import '../controllers/route_navigation_controller.dart';
import 'google_route_map.dart';
import 'map_theme.dart';
import 'open_route_map.dart';

/// نقطة إضافية على الخريطة بتنضغط (مثل أبواب المسجد الحرام) — [id] = TargetId
class MapPoi {
  final String id;
  final GeoPoint location;

  const MapPoi({required this.id, required this.location});
}

/// حدود التكبير لشاشة (مثل الحرم: 16–18 حتى يبيّن صحن الطواف والأبواب)
typedef MapZoomRange = ({double min, double max});

/// الخريطة بتقرّب بنعومة على [point] كل ما يتغير [version] (مثلاً الضغط على باب)
typedef MapFocus = ({GeoPoint point, int version});

// -------------------------------------------------------------
// خريطة شاشات الطريق والحرم (مكانها ومقاسها من Figma بـ RouteLayout):
//   في مفتاح Google → Google Maps بثيم assets/styles/map_style.json
//   ما في مفتاح → خريطة بديلة تفاعلية (OpenStreetMap) بنفس ألوان الثيم — ما بيطلع مكانها أبيض
// الاتنين: سحب وتكبير وتدوير، الوجهة (دبوس مع اسمها) والمسار وموقع المستخدم، زر "موقعي"،
// ونقاط إضافية بتنضغط ([pois] و [onPoiTap] — ودبوس الوجهة كمان)، وتقريب ناعم على نقطة ([focus])
// أزرار التحكم: "موقعي" (فوق يمين) والبوصلة (فوق يسار — بترجّع الشمال)
// الكاميرا: شاشات الطريق بتشمل المستخدم والوجهة — والحرم ([zoomRange]) بيبيّن الأبواب بتكبير 16–18
// -------------------------------------------------------------
class RouteMap extends StatelessWidget {
  final RouteNavigationController controller;
  final List<MapPoi> pois;
  final ValueChanged<String>? onPoiTap;
  final MapZoomRange? zoomRange;
  final MapFocus? focus;

  /// ألوان صورة Figma للخريطة البديلة (null = ثيم لبيك) — وبـ Google: الخريطة العادية بدون ثيم لبيك
  final MapPalette? palette;

  /// موقعي كدبوس مع اسم (مثل "موقعك الحالي" بـ 111:6809) بدل النقطة الزرقا
  final String? userLabel;

  /// زرّي "موقعي" والبوصلة (شاشة نقطة التجمع 111:6809 ما فيها أزرار)
  final bool controls;

  const RouteMap({super.key, required this.controller, this.pois = const [], this.onPoiTap, this.zoomRange, this.focus, this.palette, this.userLabel, this.controls = true});

  /// تكبير التقريب على نقطة (باب)
  static const focusZoom = 18.0;

  // أحمر المسار بـ Figma
  static const routeColor = Color(0xFFDE4B43);

  /// زوم "موقعي"
  static const userZoom = 15.0;

  /// النقاط الإضافية غير الوجهة الحالية
  static List<MapPoi> otherPois(RouteNavigationController c, List<MapPoi> pois) => [
    for (final poi in pois)
      if (poi.id != c.place.targetId) poi,
  ];

  /// كل النقاط اللي لازم تبين بالكاميرا: المسار والوجهة والمستخدم
  static List<GeoPoint> cameraPoints(RouteNavigationController c) => [...?c.route?.path, c.place.location, ?c.position];

  /// نقاط كاميرا الحرم: الأبواب والوجهة، والمستخدم إذا قريب (أقل من 1.5 كم)
  static List<GeoPoint> areaPoints(RouteNavigationController c, List<MapPoi> pois) {
    final user = c.position;
    return [
      for (final poi in pois) poi.location,
      c.place.location,
      if (user != null && GeoUtils.haversine(user, c.place.location) < 1500) user,
    ];
  }

  /// حدود النقاط (جنوب، غرب، شمال، شرق) — null لو كلها تقريباً بنقطة وحدة (المستخدم عند الوجهة)
  static ({double south, double west, double north, double east})? bounds(List<GeoPoint> points) {
    var south = points.first.latitude, north = south;
    var west = points.first.longitude, east = west;
    for (final p in points) {
      if (p.latitude < south) south = p.latitude;
      if (p.latitude > north) north = p.latitude;
      if (p.longitude < west) west = p.longitude;
      if (p.longitude > east) east = p.longitude;
    }
    if (north - south < 0.002 && east - west < 0.002) return null;
    return (south: south, west: west, north: north, east: east);
  }

  /// مركز وتكبير بيشملوا [points] بخريطة حجمها [size] (Web Mercator — طبقات 256) ضمن [range]
  static ({GeoPoint center, double zoom}) frame(List<GeoPoint> points, Size size, double padding, MapZoomRange range) {
    var south = points.first.latitude, north = south;
    var west = points.first.longitude, east = west;
    for (final p in points) {
      south = math.min(south, p.latitude);
      north = math.max(north, p.latitude);
      west = math.min(west, p.longitude);
      east = math.max(east, p.longitude);
    }
    double mercator(double lat) => math.log(math.tan(math.pi / 4 + lat * math.pi / 360));
    double log2(double v) => math.log(v) / math.ln2;
    final width = math.max(1.0, size.width - 2 * padding);
    final height = math.max(1.0, size.height - 2 * padding);
    final zoomX = log2(width * 360 / (256 * math.max(east - west, 1e-9)));
    final zoomY = log2(height * 2 * math.pi / (256 * math.max(mercator(north) - mercator(south), 1e-12)));
    final zoom = math.min(zoomX, zoomY).clamp(range.min, range.max);
    return (center: GeoPoint((south + north) / 2, (west + east) / 2), zoom: zoom);
  }

  @override
  Widget build(BuildContext context) {
    return MapsConfig.useGoogleMaps
        ? GoogleRouteMap(controller: controller, pois: pois, onPoiTap: onPoiTap, zoomRange: zoomRange, focus: focus, plainStyle: palette != null, userLabel: userLabel, controls: controls)
        : OpenRouteMap(controller: controller, pois: pois, onPoiTap: onPoiTap, zoomRange: zoomRange, focus: focus, palette: palette, userLabel: userLabel, controls: controls);
  }
}
