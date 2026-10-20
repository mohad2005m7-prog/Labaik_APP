import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/location_service.dart';
import '../../../../core/utils/maps_config.dart';
import '../controllers/route_navigation_controller.dart';
import 'map_compass_button.dart';
import 'map_marker.dart';
import 'route_map.dart';

// -------------------------------------------------------------
// Google Maps لشاشات الطريق والحرم (لما يكون في مفتاح MAPS_API_KEY)
// الألوان من assets/styles/map_style.json عن طريق setMapStyle — والمباني 3D بشاشة الحرم (إمالة 45°)
// موقع المستخدم الفعلي (النقطة الزرقا) وزر "موقعي" من Google — والبوصلة زرّنا (فوق يسار)
// -------------------------------------------------------------
class GoogleRouteMap extends StatefulWidget {
  final RouteNavigationController controller;
  final List<MapPoi> pois;
  final ValueChanged<String>? onPoiTap;
  final MapZoomRange? zoomRange;
  final MapFocus? focus;

  /// الخريطة العادية بدون ثيم لبيك (شاشات صورتها بـ Figma خريطة Google العادية)
  final bool plainStyle;

  /// موقعي كدبوس مع اسم بدل النقطة الزرقا
  final String? userLabel;
  final bool controls;

  const GoogleRouteMap({super.key, required this.controller, this.pois = const [], this.onPoiTap, this.zoomRange, this.focus, this.plainStyle = false, this.userLabel, this.controls = true});

  @override
  State<GoogleRouteMap> createState() => _GoogleRouteMapState();
}

class _GoogleRouteMapState extends State<GoogleRouteMap> {
  // ملف الألوان (rootBundle بيحفظه بالكاش)
  late final Future<String> _style = rootBundle.loadString(MapsConfig.stylePath);

  // إمالة شاشة الحرم حتى تبيّن المباني ثلاثية الأبعاد (شكل المسجد الحرام)
  static const _areaTilt = 45.0;

  GoogleMapController? _map;
  Size _size = Size.zero;
  CameraPosition? _camera;
  final _north = ValueNotifier<double>(0); // زاوية الشمال على الشاشة (للبوصلة)
  final _pins = <String, MapMarkerIcon>{}; // الدبوس مع الاسم (حسب الاسم)
  MapMarkerIcon? _plainPin; // دبوس بدون اسم (النقاط الإضافية)
  int _fittedVersion = -1;

  RouteNavigationController get _navigation => widget.controller;

  @override
  void initState() {
    super.initState();
    _navigation.addListener(_onNavigationChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pins.clear(); // اللغة أو الاتجاه ممكن يكونوا تغيروا
    _loadIcons();
  }

  @override
  void didUpdateWidget(GoogleRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final focus = widget.focus;
    if (focus != null && focus.version != oldWidget.focus?.version) _flyTo(focus.point);
  }

  // دبوس الوجهة مع اسمها والدبوس بدون اسم
  Future<void> _loadIcons() async {
    final label = _navigation.place.label();
    final userLabel = widget.userLabel;
    if (_pins.containsKey(label) && _plainPin != null && (userLabel == null || _pins.containsKey(userLabel))) return;
    final scale = DesignScale.of(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final direction = Directionality.of(context);
    final pin = _pins[label] ?? await MapMarker.pin(label: label, scale: scale, pixelRatio: pixelRatio, direction: direction);
    final plain = _plainPin ?? await MapMarker.plainPin(scale: scale, pixelRatio: pixelRatio);
    final user = userLabel == null ? null : _pins[userLabel] ?? await MapMarker.pin(label: userLabel, scale: scale, pixelRatio: pixelRatio, direction: direction);
    if (!mounted) return;
    setState(() {
      _pins[label] = pin;
      if (userLabel != null && user != null) _pins[userLabel] = user;
      _plainPin = plain;
    });
  }

  void _onNavigationChanged() {
    if (!_pins.containsKey(_navigation.place.label())) _loadIcons(); // وجهة جديدة (باب ثاني)
    setState(() {});
    _fitCamera();
  }

  Future<void> _onMapCreated(GoogleMapController map) async {
    _map = map;
    try {
      // ثيم لبيك (map_style.json) بدل الخريطة التقليدية المزدحمة
      // ignore: deprecated_member_use
      if (!widget.plainStyle) await map.setMapStyle(await _style);
    } catch (_) {}
    if (mounted) _fitCamera();
  }

  void _animate(CameraUpdate update) => unawaited(_map?.animateCamera(update).catchError((Object _) {}));

  /// شاشات الطريق: CameraUpdate.newLatLngBounds (المستخدم والوجهة والمسار)
  /// الحرم: مركز الأبواب بتكبير 16–18 وإمالة للمباني 3D
  void _fitCamera() {
    if (_map == null || _navigation.route == null || _navigation.routeVersion == _fittedVersion) return;
    _fittedVersion = _navigation.routeVersion;

    final s = DesignScale.of(context);
    final range = widget.zoomRange;
    if (range != null) {
      final f = RouteMap.frame(RouteMap.areaPoints(_navigation, widget.pois), _size, s.x(40), range);
      _animate(CameraUpdate.newCameraPosition(CameraPosition(target: _latLng(f.center), zoom: f.zoom, tilt: _areaTilt)));
      return;
    }
    final points = RouteMap.cameraPoints(_navigation);
    final b = RouteMap.bounds(points);
    _animate(
      b == null
          ? CameraUpdate.newLatLngZoom(_latLng(points.first), 16)
          : CameraUpdate.newLatLngBounds(
              LatLngBounds(southwest: LatLng(b.south, b.west), northeast: LatLng(b.north, b.east)),
              s.x(80), // مسافة كافية حتى اسم الوجهة تحت الدبوس ما ينقص
            ),
    );
  }

  /// تقريب ناعم على نقطة (باب) — بنفس اتجاه الخريطة الحالي
  void _flyTo(GeoPoint point) {
    _animate(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _latLng(point),
          zoom: RouteMap.focusZoom,
          tilt: widget.zoomRange != null ? _areaTilt : 0,
          bearing: _camera?.bearing ?? 0,
        ),
      ),
    );
  }

  /// البوصلة: رجوع للشمال بنعومة (بنفس المكان والتكبير)
  void _resetNorth() {
    final camera = _camera;
    if (camera == null) return;
    _animate(CameraUpdate.newCameraPosition(CameraPosition(target: camera.target, zoom: camera.zoom, tilt: camera.tilt)));
  }

  static LatLng _latLng(GeoPoint p) => LatLng(p.latitude, p.longitude);

  @override
  void dispose() {
    _navigation.removeListener(_onNavigationChanged);
    _north.dispose();
    _map?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final route = _navigation.route;
    final place = _navigation.place;
    final pin = _pins[place.label()];
    final plain = _plainPin;
    final userLabel = widget.userLabel;
    final userPin = userLabel == null ? null : _pins[userLabel];
    final position = _navigation.position;
    final range = widget.zoomRange;
    final targetId = place.targetId;

    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;
        return Stack(
          fit: StackFit.expand,
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _latLng(place.location),
                zoom: range == null ? 12 : (range.min + range.max) / 2,
                tilt: range == null ? 0 : _areaTilt,
              ),
              markers: {
                if (pin != null)
                  Marker(
                    markerId: const MarkerId('destination'),
                    position: _latLng(place.location),
                    icon: pin.icon,
                    anchor: pin.anchor,
                    zIndexInt: 2,
                    consumeTapEvents: widget.onPoiTap != null,
                    onTap: widget.onPoiTap == null || targetId == null ? null : () => widget.onPoiTap!(targetId),
                  ),
                // موقعي كدبوس مع اسم ("موقعك الحالي")
                if (userPin != null && position != null)
                  Marker(markerId: const MarkerId('user'), position: _latLng(position), icon: userPin.icon, anchor: userPin.anchor, zIndexInt: 1),
                // النقاط الإضافية (أبواب الحرم): الضغط بيفتح بطاقتها
                if (plain != null)
                  for (final poi in RouteMap.otherPois(_navigation, widget.pois))
                    Marker(
                      markerId: MarkerId(poi.id),
                      position: _latLng(poi.location),
                      icon: plain.icon,
                      anchor: plain.anchor,
                      consumeTapEvents: true,
                      onTap: () => widget.onPoiTap?.call(poi.id),
                    ),
              },
              polylines: {
                if (route != null)
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: [for (final p in route.path) _latLng(p)],
                    color: RouteMap.routeColor,
                    width: 5,
                    jointType: JointType.round,
                    startCap: Cap.roundCap,
                    endCap: Cap.roundCap,
                    // بدون إنترنت: خط مباشر متقطّع (تقدير مش طريق فعلي)
                    geodesic: route.isEstimate,
                    patterns: route.isEstimate ? [PatternItem.dash(18), PatternItem.gap(10)] : const [],
                  ),
              },
              // موقع المستخدم الفعلي (GPS) وزر "موقعي" الأصلي
              myLocationEnabled: _navigation.access == LocationAccess.granted,
              myLocationButtonEnabled: widget.controls,
              // المباني ثلاثية الأبعاد (بتبيّن مع الإمالة والتكبير العالي)
              buildingsEnabled: true,
              // تفاعل كامل: سحب بكل الاتجاهات، تكبير وتصغير بأصبعين، تدوير وإمالة
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,
              // البوصلة زرّنا (دايماً ظاهرة) بدل بوصلة Google اللي بتطلع بس مع الدوران
              compassEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              indoorViewEnabled: false,
              // كل اللمسات جوّا الخريطة إلها (حتى ما ياخدها أي ويدجت فوقها)
              gestureRecognizers: {Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new)},
              onMapCreated: _onMapCreated,
              onCameraMove: (camera) {
                _camera = camera;
                _north.value = -camera.bearing;
              },
            ),
            if (widget.controls) MapCompassButton(scale: DesignScale.of(context), northDegrees: _north, onTap: _resetNorth),
          ],
        );
      },
    );
  }
}
