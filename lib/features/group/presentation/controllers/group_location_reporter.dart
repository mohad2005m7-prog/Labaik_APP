import 'dart:async';

import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/location_service.dart';
import '../../data/sources/group_api.dart';
import '../../data/sources/location_api.dart';

// -------------------------------------------------------------
// مشاركة موقعي مع مجموعتي — تلقائي (قرار صاحب المشروع): لو المعتمر بمجموعة والموقع مسموح للتطبيق
// بنفعّل المشاركة بالسيرفر (PUT /location/sharing) وبنبعت موقعي الفعلي (POST /location)
// أول ما يشتغل، وبعدها كل 30 ثانية أو كل ما يتحرك 50 م — والتطبيق مفتوح بس (بدون خدمة خلفية)
// بيوقف مع تسجيل الخروج
// -------------------------------------------------------------
class GroupLocationReporter {
  GroupLocationReporter._();

  static final instance = GroupLocationReporter._();

  // مصادر البيانات — الاختبارات بتبدّلها
  static GroupApi Function() groupApi = GroupApi.server;
  static LocationApi Function() locationApi = LocationApi.server;

  static const interval = Duration(seconds: 30);
  static const distance = 50.0;

  LocationApi? _api;
  StreamSubscription<GeoPoint>? _positions;
  DateTime? _lastSent;
  GeoPoint? _lastPoint;
  bool _starting = false;

  bool get running => _positions != null;

  /// بيشتغل بس لو بمجموعة والموقع مسموح — وإلا ما بيعمل شي (بيرجع يجرّب مع الفتحة الجاية)
  Future<void> start() async {
    if (running || _starting) return;
    _starting = true;
    try {
      if (await LocationService.checkAccess() != LocationAccess.granted) return;
      if (await groupApi().myGroup() == null) return;
      final api = locationApi();
      if (!await api.isSharing()) await api.setSharing(true);
      _api = api;
      final first = await LocationService.currentPosition() ?? await LocationService.lastKnownPosition();
      if (first != null) await _send(first);
      _positions = LocationService.positions().listen(_onPosition, onError: (_) {});
    } catch (_) {
      // ما في إنترنت أو السيرفر نايم — بنرجع نجرّب مع الفتحة الجاية
    } finally {
      _starting = false;
    }
  }

  void _onPosition(GeoPoint point) {
    final last = _lastPoint, at = _lastSent;
    final due = at == null || DateTime.now().difference(at) >= interval;
    final moved = last == null || GeoUtils.haversine(last, point) >= distance;
    if (due || moved) _send(point);
  }

  Future<void> _send(GeoPoint point) async {
    _lastSent = DateTime.now();
    _lastPoint = point;
    try {
      await _api?.send(point);
    } catch (_) {
      // بنرجع نحاول مع الموقع الجاي
      _lastSent = null;
    }
  }

  Future<void> stop() async {
    await _positions?.cancel();
    _positions = null;
    _api = null;
    _lastSent = null;
    _lastPoint = null;
  }
}
