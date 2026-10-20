import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/maps_config.dart';
import '../controllers/route_navigation_controller.dart';
import 'map_attribution.dart';
import 'map_compass_button.dart';
import 'map_marker.dart';
import 'map_theme.dart';
import 'my_location_button.dart';
import 'route_map.dart';

// -------------------------------------------------------------
// الخريطة البديلة (لما ما يكون في مفتاح Google): OpenStreetMap تفاعلية
// بنفس ثيم map_style.json (شوف MapTheme): أرض رمادي فاتح، ماء أخضر غامق، حدائق أخضر فاتح
// الطبقات اللي انشافت قبل بتنحفظ بالجهاز (بتبيّن بدون إنترنت)، وخلفيتها بلون الأرض حتى لو ما حملت
// حركة الكاميرا (التقريب على باب والرجوع للشمال) ناعمة بأنيميشن 650 ملي ثانية
// -------------------------------------------------------------
class OpenRouteMap extends StatefulWidget {
  final RouteNavigationController controller;
  final List<MapPoi> pois;
  final ValueChanged<String>? onPoiTap;
  final MapZoomRange? zoomRange;
  final MapFocus? focus;
  final MapPalette? palette;
  final String? userLabel;
  final bool controls;

  const OpenRouteMap({super.key, required this.controller, this.pois = const [], this.onPoiTap, this.zoomRange, this.focus, this.palette, this.userLabel, this.controls = true});

  @override
  State<OpenRouteMap> createState() => _OpenRouteMapState();
}

class _OpenRouteMapState extends State<OpenRouteMap> with SingleTickerProviderStateMixin {
  final _map = MapController();
  final _north = ValueNotifier<double>(0); // زاوية الشمال على الشاشة (للبوصلة)
  late final AnimationController _flight = AnimationController(vsync: this, duration: const Duration(milliseconds: 650))..addListener(_flightStep);
  late final _flightCurve = CurvedAnimation(parent: _flight, curve: Curves.easeInOutCubic);
  ({MapCamera from, LatLng center, double zoom, double turn})? _flightPlan;
  StreamSubscription<MapEvent>? _events;
  final _tiles = NetworkTileProvider(silenceExceptions: true);
  Size _size = Size.zero;
  bool _ready = false;
  int _fittedVersion = -1;

  RouteNavigationController get _navigation => widget.controller;

  @override
  void initState() {
    super.initState();
    _navigation.addListener(_onNavigationChanged);
  }

  void _onNavigationChanged() {
    setState(() {});
    _fitCamera();
  }

  @override
  void didUpdateWidget(OpenRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final focus = widget.focus;
    if (focus != null && focus.version != oldWidget.focus?.version) {
      _flyTo(_latLng(focus.point), RouteMap.focusZoom);
    }
  }

  void _onMapReady() {
    _ready = true;
    _events = _map.mapEventStream.listen((event) => _north.value = event.camera.rotation);
    _fitCamera();
  }

  /// حركة ناعمة للكاميرا (المكان والتكبير والاتجاه) — الدوران من أقصر طريق
  void _flyTo(LatLng center, double zoom, {double? rotation}) {
    if (!_ready) return;
    final from = _map.camera;
    final turn = rotation == null ? 0.0 : ((rotation - from.rotation + 540) % 360) - 180;
    _flightPlan = (from: from, center: center, zoom: zoom, turn: turn);
    _flight.forward(from: 0);
  }

  void _flightStep() {
    final plan = _flightPlan;
    if (plan == null) return;
    final t = _flightCurve.value;
    final from = plan.from;
    _map.moveAndRotate(
      LatLng(
        from.center.latitude + (plan.center.latitude - from.center.latitude) * t,
        from.center.longitude + (plan.center.longitude - from.center.longitude) * t,
      ),
      from.zoom + (plan.zoom - from.zoom) * t,
      from.rotation + plan.turn * t,
    );
  }

  /// البوصلة: رجوع للشمال بنعومة
  void _resetNorth() {
    if (!_ready) return;
    _flyTo(_map.camera.center, _map.camera.zoom, rotation: 0);
  }

  /// شاشات الطريق: المستخدم والوجهة والمسار كلهم بالصورة — الحرم: مركز الأبواب بتكبير 16–18
  void _fitCamera() {
    if (!_ready || _navigation.route == null || _navigation.routeVersion == _fittedVersion) return;
    _fittedVersion = _navigation.routeVersion;
    final s = DesignScale.of(context);

    final range = widget.zoomRange;
    if (range != null) {
      final f = RouteMap.frame(RouteMap.areaPoints(_navigation, widget.pois), _size, s.x(40), range);
      _map.move(_latLng(f.center), f.zoom);
      return;
    }

    final points = RouteMap.cameraPoints(_navigation);
    final b = RouteMap.bounds(points);
    if (b == null) {
      _map.move(_latLng(points.first), 16);
      return;
    }
    _map.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(LatLng(b.south, b.west), LatLng(b.north, b.east)),
        // مسافة أكبر على الجنبين حتى اسم الوجهة تحت الدبوس ما ينقص
        padding: EdgeInsets.symmetric(horizontal: s.x(90), vertical: s.x(56)),
      ),
    );
  }

  void _centerOnUser() {
    final position = _navigation.position;
    if (!_ready || position == null) return;
    final zoom = widget.zoomRange?.max ?? RouteMap.userZoom;
    _flyTo(_latLng(position), math.max(_map.camera.zoom, zoom));
  }

  static LatLng _latLng(GeoPoint p) => LatLng(p.latitude, p.longitude);

  @override
  void dispose() {
    _navigation.removeListener(_onNavigationChanged);
    _events?.cancel();
    _flight.dispose();
    _north.dispose();
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    final route = _navigation.route;
    final position = _navigation.position;
    final place = _navigation.place;
    final range = widget.zoomRange;

    // الدبوس: رأسه على الإحداثيات (flutter_map بيحط النقطة على بُعد (1 - y) × نص الارتفاع من فوق)
    final pinWidth = s.x(260);
    final pinHeight = s.x(MapMarker.pinSize + MapMarker.labelHeight);
    final pinAlignment = Alignment(0, 1 - 2 * s.x(MapMarker.tipY) / pinHeight);
    final plainSize = s.x(MapMarker.pinSize);
    final plainAlignment = Alignment(0, 1 - 2 * s.x(MapMarker.tipY) / plainSize);
    final dotSize = s.x(MapMarker.userDotSize + 4);

    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;
        return Stack(
          fit: StackFit.expand,
          children: [
            FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: _latLng(place.location),
                initialZoom: range == null ? 12 : (range.min + range.max) / 2,
                backgroundColor: widget.palette?.land ?? MapTheme.background,
                // تفاعل كامل: سحب بكل الاتجاهات، تكبير وتصغير بأصبعين، تدوير
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                onMapReady: _onMapReady,
              ),
              children: [
                TileLayer(
                  urlTemplate: MapsConfig.fallbackTilesUrl,
                  userAgentPackageName: MapsConfig.appPackage,
                  tileProvider: _tiles,
                  // طبقات الحرم بتكبير لـ 19 (الطبقات بتتكبّر فوق 19)
                  maxNativeZoom: 19,
                  tileBuilder: (context, tile, _) => widget.palette?.themed(tile) ?? MapTheme.themed(tile),
                ),
                if (route != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [for (final p in route.path) _latLng(p)],
                        color: RouteMap.routeColor,
                        strokeWidth: s.x(5),
                        // بدون إنترنت: خط مباشر متقطّع (تقدير مش طريق فعلي)
                        pattern: route.isEstimate ? StrokePattern.dashed(segments: [s.x(18), s.x(10)]) : const StrokePattern.solid(),
                      ),
                    ],
                  ),
                MarkerLayer(
                  rotate: true, // الدبابيس والأسماء بيضلوا واقفين لما تتدور الخريطة
                  markers: [
                    // النقاط الإضافية (أبواب الحرم): الضغط بيفتح بطاقتها
                    for (final poi in RouteMap.otherPois(_navigation, widget.pois))
                      Marker(
                        key: ValueKey(poi.id),
                        point: _latLng(poi.location),
                        width: plainSize,
                        height: plainSize,
                        alignment: plainAlignment,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => widget.onPoiTap?.call(poi.id),
                          child: PlainPin(scale: s),
                        ),
                      ),
                    Marker(
                      point: _latLng(place.location),
                      width: pinWidth,
                      height: pinHeight,
                      alignment: pinAlignment,
                      child: GestureDetector(
                        behavior: HitTestBehavior.deferToChild,
                        onTap: widget.onPoiTap == null || place.targetId == null ? null : () => widget.onPoiTap!(place.targetId!),
                        child: DestinationPin(label: place.label(), scale: s),
                      ),
                    ),
                    if (position != null)
                      widget.userLabel == null
                          ? Marker(point: _latLng(position), width: dotSize, height: dotSize, child: UserDot(scale: s))
                          : Marker(point: _latLng(position), width: pinWidth, height: pinHeight, alignment: pinAlignment, child: IgnorePointer(child: DestinationPin(label: widget.userLabel!, scale: s))),
                  ],
                ),
                // حقوق بيانات OpenStreetMap (مطلوبة)
                MapAttribution(s: s),
              ],
            ),
            if (widget.controls) MyLocationButton(scale: s, onTap: _centerOnUser),
            if (widget.controls) MapCompassButton(scale: s, northDegrees: _north, onTap: _resetNorth),
          ],
        );
      },
    );
  }
}
