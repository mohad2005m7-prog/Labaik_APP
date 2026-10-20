import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/location_service.dart';
import '../../../../core/utils/maps_config.dart';
import '../../../field_mode/presentation/widgets/map_attribution.dart';
import '../../../field_mode/presentation/widgets/map_theme.dart';
import '../../domain/entities/family_circle.dart';
import '../../domain/entities/family_member.dart';
import '../l10n/family_map_text.dart';
import 'family_colors.dart';
import 'family_icons.dart';
import 'family_map_markers.dart';

/// على شو الخريطة بتركّز: فرد ("عرض الموقع") أو نقطة التجمع — [version] بيتغيّر مع كل ضغطة
class FamilyMapFocus {
  final String? memberId;
  final bool meetingPoint;
  final int version;

  const FamilyMapFocus.member(String this.memberId, {this.version = 0}) : meetingPoint = false;
  const FamilyMapFocus.meetingPoint({this.version = 0})
      : memberId = null,
        meetingPoint = true;
}

// -------------------------------------------------------------
// خريطة أفراد العائلة والمجموعة (Figma 361×389): OpenStreetMap بألوان صورة Figma ([MapPalette.members]) — تفاعلية
// الأفراد اللي بيشاركوا موقعهم (من السيرفر) + موقعي الفعلي (GPS لو مسموح — وإلا آخر موقع بعتّه) + نقطة التجمع
// أول ما تفتح: الكل بالصورة (أو اللي بدنا نركّز عليه) — زر موقعي (35 بحد #1F3B2E) فوق يمين
// -------------------------------------------------------------
class FamilyMapView extends StatefulWidget {
  final DesignScale s;
  final List<FamilyMember> members;
  final MeetingPoint? meetingPoint;
  final FamilyMapFocus? focus;
  final VoidCallback onNoLocation;

  /// الضغط على دبوس فرد ([anchor] = مكان الدبوس على الشاشة — القائمة بتطلع جنبه)
  final void Function(FamilyMember member, Rect anchor)? onMemberTap;

  /// ألوان صورة Figma للخريطة
  final MapPalette palette;

  /// زر موقعي: من طرف الخريطة (يمين بالعربي) ومن فوق — العائلة 29.5×8 والمجموعة 26×10
  final Offset locateButton;

  const FamilyMapView({
    super.key,
    required this.s,
    required this.members,
    required this.meetingPoint,
    required this.focus,
    required this.onNoLocation,
    this.onMemberTap,
    this.palette = MapPalette.members,
    this.locateButton = const Offset(29.5, 8),
  });

  /// لو موقعي أبعد من هيك عن الباقي (مثلاً ببلد تاني) ما بيدخل بالصورة الأولى — زر موقعي بيروح عليه
  static const nearbyMeters = 50000.0;

  /// مكة (الحرم) لو ما في ولا نقطة لسا
  static const fallbackCenter = GeoPoint(21.4225, 39.8262);
  static const focusZoom = 17.0;

  @override
  State<FamilyMapView> createState() => _FamilyMapViewState();
}

class _FamilyMapViewState extends State<FamilyMapView> {
  final _map = MapController();
  final _tiles = NetworkTileProvider(silenceExceptions: true);
  StreamSubscription<GeoPoint>? _positions;
  GeoPoint? _gps;
  bool _ready = false;

  // الكاميرا بتتحرك لحالها بس أول مرة توصل نقاط، أو لما يطلب تركيز جديد — غير هيك بتضل وين ما حرّكها
  bool _hadPoints = false;
  int? _focusDone;

  @override
  void initState() {
    super.initState();
    _watchMe();
  }

  /// موقعي الحي — بس لو الصلاحية معطاة (ما بنطلبها هون)
  Future<void> _watchMe() async {
    if (await LocationService.checkAccess() != LocationAccess.granted || !mounted) return;
    _positions = LocationService.positions().listen((point) {
      if (!mounted) return;
      setState(() => _gps = point);
      _maybeFit();
    }, onError: (_) {});
  }

  @override
  void didUpdateWidget(FamilyMapView old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeFit());
  }

  void _maybeFit() {
    final focus = widget.focus;
    final newFocus = focus != null && focus.version != _focusDone && _focusPoint() != null;
    if (newFocus || (!_hadPoints && _points().isNotEmpty)) _fit();
  }

  /// نقاط الصورة الأولى: الأفراد ونقطة التجمع، وأنا إذا قريب منهم
  List<GeoPoint> _points() {
    final points = [for (final m in _others) m.location!, ?widget.meetingPoint?.location];
    final me = _myPoint;
    if (me != null && (points.isEmpty || points.any((p) => GeoUtils.haversine(p, me) <= FamilyMapView.nearbyMeters))) points.add(me);
    return points;
  }

  @override
  void dispose() {
    _positions?.cancel();
    _map.dispose();
    super.dispose();
  }

  FamilyMember? get _me => widget.members.where((m) => m.isMe).firstOrNull;

  /// موقعي: الحي أولاً وإلا آخر موقع وصل للسيرفر
  GeoPoint? get _myPoint => _gps ?? (_me?.sharesLocation == true ? _me?.location : null);

  List<FamilyMember> get _others => [for (final m in widget.members) if (!m.isMe && m.sharesLocation && m.location != null) m];

  static LatLng _latLng(GeoPoint p) => LatLng(p.latitude, p.longitude);

  GeoPoint? _focusPoint() {
    final focus = widget.focus;
    if (focus == null) return null;
    if (focus.meetingPoint) return widget.meetingPoint?.location;
    final member = widget.members.where((m) => m.userId == focus.memberId).firstOrNull;
    if (member == null) return null;
    return member.isMe ? _myPoint : member.location;
  }

  /// الكاميرا: اللي بنركّز عليه، وإلا كل النقاط بالصورة
  void _fit() {
    if (!_ready || !mounted) return;
    final focus = _focusPoint();
    final points = _points();
    _hadPoints = points.isNotEmpty;
    if (focus != null) {
      _focusDone = widget.focus!.version;
      _map.move(_latLng(focus), FamilyMapView.focusZoom);
      return;
    }
    if (points.isEmpty) {
      _map.move(_latLng(FamilyMapView.fallbackCenter), 15);
      return;
    }
    if (points.length == 1) {
      _map.move(_latLng(points.first), 16);
      return;
    }
    final s = widget.s;
    _map.fitCamera(
      CameraFit.coordinates(
        coordinates: [for (final p in points) _latLng(p)],
        // مسافة حتى الأسماء والحلقات ما ينقصوا على الأطراف
        padding: EdgeInsets.fromLTRB(s.x(50), s.x(40), s.x(50), s.x(50)),
        maxZoom: 18,
      ),
    );
  }

  Future<void> _locateMe() async {
    var point = _myPoint;
    if (point == null && await LocationService.checkAccess() == LocationAccess.granted) {
      point = await LocationService.currentPosition() ?? await LocationService.lastKnownPosition();
    }
    if (!mounted) return;
    if (point == null) {
      widget.onNoLocation();
      return;
    }
    if (_gps == null) setState(() => _gps = point);
    _map.move(_latLng(point), math.max(_map.camera.zoom, 16));
  }

  /// دبوس فرد بينضغط (الدبوس نفسه — مش الاسم تحته)
  Widget _tappable(FamilyMember member, Widget pin) {
    final onTap = widget.onMemberTap;
    if (onTap == null) return pin;
    return Builder(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null || !box.hasSize) return;
          final s = widget.s;
          final origin = box.localToGlobal(Offset(box.size.width / 2 - s.x(8), 0));
          onTap(member, origin & Size(s.x(16), s.x(23)));
        },
        child: pin,
      ),
    );
  }

  Marker _marker(GeoPoint point, double height, double tip, Widget child, {Key? key}) {
    final s = widget.s;
    return Marker(
      key: key,
      point: _latLng(point),
      width: s.x(FamilyMarkerSize.width),
      height: s.x(height),
      alignment: Alignment(0, 1 - 2 * tip / height),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final me = _myPoint;
    final meeting = widget.meetingPoint;
    return Stack(
      fit: StackFit.expand,
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: _latLng(FamilyMapView.fallbackCenter),
            initialZoom: 15,
            backgroundColor: widget.palette.land,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
            onMapReady: () {
              _ready = true;
              _fit();
            },
          ),
          children: [
            TileLayer(
              urlTemplate: MapsConfig.fallbackTilesUrl,
              userAgentPackageName: MapsConfig.appPackage,
              tileProvider: _tiles,
              maxNativeZoom: 19,
              tileBuilder: (context, tile, _) => widget.palette.themed(tile),
            ),
            MarkerLayer(
              markers: [
                if (meeting != null)
                  _marker(meeting.location, FamilyMarkerSize.ringedHeight, FamilyMarkerSize.ringedTip, FamilyRingedMarker(s: s, label: FamilyMapText.meetingPoint(), meetingPoint: true), key: const ValueKey('meeting')),
                for (final m in _others)
                  _marker(m.location!, FamilyMarkerSize.memberHeight, FamilyMarkerSize.memberTip, _tappable(m, FamilyMemberMarker(s: s, name: m.name, online: m.isOnline)), key: ValueKey(m.userId)),
                if (me != null) _marker(me, FamilyMarkerSize.ringedHeight, FamilyMarkerSize.ringedTip, FamilyRingedMarker(s: s, label: FamilyMapText.me()), key: const ValueKey('me')),
              ],
            ),
            // حقوق بيانات OpenStreetMap (مطلوبة — مكان "Map data" بـ Figma)
            MapAttribution(s: s),
          ],
        ),
        // زر موقعي (Figma: دايرة 35 بيضا بحد #1F3B2E من 312.5,165 — يعني بعد 29.5 من طرف الخريطة و8 من فوق)
        PositionedDirectional(
          start: s.x(widget.locateButton.dx),
          top: s.y(widget.locateButton.dy),
          width: s.x(35),
          height: s.x(35),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _locateMe,
            child: DecoratedBox(
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: FamilyColors.green, width: s.x(1))),
              child: Center(child: LocateIcon(size: s.x(24), color: FamilyColors.green)),
            ),
          ),
        ),
      ],
    );
  }
}
