import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/location_service.dart';
import '../../data/map_repository.dart';
import '../../data/models/field_place.dart';
import '../../data/models/route_info.dart';
import '../../data/route_repository.dart';
import '../../data/sources/location_source.dart';

/// نتيجة زر "انا ضائع"
enum LostHelpResult {
  alertSent, // التنبيه وصل للسيرفر والمسار انحسب من جديد
  rerouted, // المسار انحسب من جديد (بدون سيرفر أو ما وصل التنبيه)
  locating, // لسا عم نحدد موقع المستخدم
  needsLocation, // الموقع مش مفعّل
}

// -------------------------------------------------------------
// RouteNavigationController — الملاحة الحية لشاشات الطريق وأبواب الحرم:
// موقع المستخدم الفعلي (GPS بدقة عالية) → المسار (MapRepository) →
// المسافة المتبقية والوقت المتوقع وحالة "الوجهة قريبة" — والموقع الحي بيوصل للسيرفر
// -------------------------------------------------------------
class RouteNavigationController extends ChangeNotifier {
  RouteNavigationController(this._place, {LocationSource? source}) : _source = source ?? const DeviceLocationSource();

  FieldPlace _place;
  final LocationSource _source; // موقع الجهاز الفعلي (GPS بدقة عالية)

  FieldPlace get place => _place;

  // إذا ابتعد المستخدم عن خط المسار أكتر من هيك بنطلب مسار جديد من موقعه
  static const _offRouteMeters = 150.0;
  // أقل مدة بين طلبين للمسار (حتى ما نكرر الطلب مع كل حركة)
  static const _refetchInterval = Duration(seconds: 30);

  LocationAccess? access;
  GeoPoint? position;
  RouteInfo? route;
  double? remainingMeters; // المسافة المتبقية للوجهة
  double? remainingSeconds; // الوقت المتوقع للوصول
  double? nextStepMeters; // المسافة لآخر خطوة الإرشاد الحالية ("لمسافة 2.8 كم")
  int routeVersion = 0; // بيزيد كل ما يتغير المسار (الخريطة بتعيد ضبط الكاميرا)

  StreamSubscription<GeoPoint>? _positions;
  AppLifecycleListener? _lifecycle;
  DateTime? _lastFetch;
  bool _fetching = false;
  bool _connecting = false;
  bool _disposed = false;
  double _pathLength = 0;

  /// حالة Figma القريبة ("تبقّى 300 م للوصول ...") — للوجهات اللي إلها حالة قريبة
  bool get isNear => _place.nearMeters > 0 && remainingMeters != null && remainingMeters! <= _place.nearMeters;

  Future<void> start() async {
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    await _connect(request: true);
  }

  // لما يرجع المستخدم للتطبيق (مثلاً بعد ما فعّل الموقع من الإعدادات)
  void _onResume() {
    if (access != LocationAccess.granted) _connect(request: false);
  }

  Future<void> _connect({required bool request}) async {
    if (_connecting) return;
    _connecting = true;
    try {
      final result = request ? await _source.requestAccess() : await _source.checkAccess();
      if (_disposed) return;
      access = result;
      _notify();
      if (result != LocationAccess.granted || _positions != null) return;

      // التحديثات الحية + آخر موقع معروف (فوري) + قراءة جديدة دقيقة من GPS
      _listen();
      final last = await _source.lastKnownPosition();
      if (_disposed) return;
      if (last != null && position == null) _onPosition(last);
      final current = await _source.currentPosition();
      if (_disposed || current == null) return;
      // آخر موقع معروف كان قديم (بعيد عن الحالي) ← الكاميرا بتنضبط من جديد
      final jumped = last != null && GeoUtils.haversine(last, current) > 1000;
      _onPosition(current);
      if (jumped) {
        routeVersion++;
        _notify();
      }
    } finally {
      _connecting = false;
    }
  }

  void _listen() {
    _positions?.cancel();
    _positions = _source.positions().listen(_onPosition, onError: (Object _) {});
  }

  /// وجهة جديدة (مثلاً باب ثاني من أبواب الحرم): المسار والمسافة بينحسبوا من موقع المستخدم الحالي
  void retarget(FieldPlace place) {
    _place = place;
    route = null;
    remainingMeters = null;
    remainingSeconds = null;
    nextStepMeters = null;
    _lastFetch = null;
    final p = position;
    if (p != null) {
      _onPosition(p);
    } else {
      _notify();
    }
  }

  void _onPosition(GeoPoint p) {
    position = p;
    final first = route == null;
    // بدون مسار حقيقي: خط مباشر من موقع المستخدم الحالي
    if (route == null || route!.isEstimate) _setRoute(RouteRepository.estimate(p, _place));
    final offRoute = _updateProgress();
    if (first) routeVersion++;
    _notify();
    unawaited(MapRepository.reportLocation(p));

    // المسار الحقيقي: أول مرة، أو لسا تقديري (يمكن رجعت الشبكة)، أو المستخدم طلع عن المسار
    if (MapRepository.canFetchRoutes && (route!.isEstimate || offRoute > _offRouteMeters)) _fetchRoute(p);
  }

  Future<void> _fetchRoute(GeoPoint from, {bool force = false}) async {
    if (_fetching) return;
    if (!force && _lastFetch != null && DateTime.now().difference(_lastFetch!) < _refetchInterval) return;
    _fetching = true;
    _lastFetch = DateTime.now();
    final target = _place;
    final result = await MapRepository.getRoute(from, target);
    _fetching = false;
    if (_disposed || target != _place) return;

    // الطلب فشل وعندنا مسار حقيقي من قبل → بنضل عليه
    if (result.isEstimate && route != null && !route!.isEstimate && !force) return;
    _setRoute(result.isEstimate ? RouteRepository.estimate(position ?? from, _place) : result);
    routeVersion++;
    _updateProgress();
    _notify();
  }

  void _setRoute(RouteInfo value) {
    route = value;
    _pathLength = GeoUtils.pathLength(value.path);
  }

  /// بيحدّث المسافة والوقت المتبقيين — وبيرجع بُعد المستخدم عن خط المسار
  double _updateProgress() {
    final r = route;
    final p = position;
    if (r == null || p == null) return 0;
    if (r.isEstimate) {
      remainingMeters = r.distanceMeters;
      remainingSeconds = r.durationSeconds;
      nextStepMeters = r.distanceMeters;
      return 0;
    }
    final progress = GeoUtils.progressAlong(r.path, p);
    final ratio = _pathLength == 0 ? 0.0 : (progress.remainingMeters / _pathLength).clamp(0.0, 1.0);
    remainingMeters = r.distanceMeters * ratio;
    remainingSeconds = r.durationSeconds * ratio;
    nextStepMeters = _nextStepMeters(r, r.distanceMeters - remainingMeters!);
    return progress.offRouteMeters;
  }

  // المسافة من مكان المستخدم لآخر خطوة الإرشاد اللي هو فيها
  double _nextStepMeters(RouteInfo r, double traveled) {
    var stepEnd = 0.0;
    for (final step in r.stepDistances) {
      stepEnd += step;
      if (stepEnd > traveled + 1) return stepEnd - traveled;
    }
    return remainingMeters!;
  }

  /// زر "انا ضائع": بيطلب الموقع إذا مش مفعّل، وإلا بيبعت تنبيه بموقع المستخدم للسيرفر
  /// وبيحسب المسار من جديد من مكانه وبيرجّع الخريطة على المستخدم والوجهة
  Future<LostHelpResult> helpLost() async {
    if (access != LocationAccess.granted) {
      final result = await _source.requestAccess();
      if (result == LocationAccess.deniedForever || result == LocationAccess.serviceOff) {
        await _source.openSettings(result);
      }
      if (result != LocationAccess.granted) return LostHelpResult.needsLocation;
      await _connect(request: false);
      if (position == null) return LostHelpResult.locating;
    }
    final p = position;
    if (p == null) return LostHelpResult.locating;
    final results = await Future.wait([MapRepository.sendLostAlert(p), _fetchRoute(p, force: true).then((_) => true)]);
    return results.first ? LostHelpResult.alertSent : LostHelpResult.rerouted;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _positions?.cancel();
    _lifecycle?.dispose();
    super.dispose();
  }
}
