import 'dart:async';

import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/location_service.dart';
import '../../domain/repositories/family_repository.dart';

// -------------------------------------------------------------
// مشاركة موقعي مع عائلتي (لما أوافق): الموقع الفعلي (GPS) بيروح للسيرفر
// أول ما يشتغل، وبعدها كل 30 ثانية أو كل ما يتحرك 50 م — وبيوقف لما أوقف المشاركة أو أطلع من الحساب
// (بيشتغل والتطبيق مفتوح — المشاركة بالخلفية بدها خدمة خلفية بالمرحلة الجاية)
// -------------------------------------------------------------
class FamilyLocationReporter {
  FamilyLocationReporter._();

  static final instance = FamilyLocationReporter._();

  static const interval = Duration(seconds: 30);
  static const distance = 50.0;

  FamilyRepository? _repository;
  StreamSubscription<GeoPoint>? _positions;
  DateTime? _lastSent;
  GeoPoint? _lastPoint;

  bool get running => _positions != null;

  /// false لو الموقع مش مسموح أو مطفي
  Future<bool> start(FamilyRepository repository) async {
    _repository = repository;
    if (running) return true;
    if (await LocationService.checkAccess() != LocationAccess.granted) return false;
    final first = await LocationService.currentPosition() ?? await LocationService.lastKnownPosition();
    if (first != null) await _send(first);
    _positions = LocationService.positions().listen(_onPosition, onError: (_) {});
    return true;
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
      await _repository?.sendLocation(point);
    } catch (_) {
      // بنرجع نحاول مع الموقع الجاي
      _lastSent = null;
    }
  }

  Future<void> stop() async {
    await _positions?.cancel();
    _positions = null;
    _lastSent = null;
    _lastPoint = null;
  }
}
