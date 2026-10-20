import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/utils/geo_utils.dart';
import '../../data/map_repository.dart';
import '../../data/models/destination_info_dto.dart';
import '../../data/models/field_place.dart';
import '../../data/sources/haram_gates.dart';
import '../../data/sources/location_source.dart';
import '../widgets/route_map.dart';
import 'route_navigation_controller.dart';

// -------------------------------------------------------------
// HaramGatesController — شاشة "وصلت إلى المسجد الحرام" (Figma 21:1859):
//   الأبواب من MapRepository (السيرفر مع الصور وحالة الازدحام، أو القائمة المحلية)
//   أول ما نعرف موقع المستخدم الفعلي بنختار أقرب باب ("اخترنا لك أقرب باب مناسب لموقعك")
//   الضغط على باب: بطاقته (الاسم بالعربي والإنجليزي، الصورة، الازدحام) والخريطة بتقرّب عليه بنعومة
//   ومن البطاقة "اتجه إلى هذا الباب" ← الملاحة الحية بتتجه إله
// -------------------------------------------------------------
class HaramGatesController extends ChangeNotifier {
  HaramGatesController({LocationSource? source}) : _gates = HaramGates.defaults, _selectedId = HaramGates.defaultGateId {
    navigation = RouteNavigationController(FieldPlace.gate(selected), source: source)..addListener(_onNavigation);
  }

  late final RouteNavigationController navigation;
  List<DestinationInfoDto> _gates;
  String _selectedId;
  String? _inspectedId;
  bool _chosenByUser = false;
  bool _pickedNearest = false;
  bool _disposed = false;
  MapFocus? _focus;

  List<DestinationInfoDto> get gates => _gates;

  /// الباب المختار (الوجهة الحالية)
  DestinationInfoDto get selected => _byId(_selectedId) ?? _gates.first;

  /// الباب اللي بطاقته مفتوحة (null = ما في بطاقة)
  DestinationInfoDto? get inspected => _inspectedId == null ? null : _byId(_inspectedId!);

  /// المستخدم اختار الباب بنفسه (مش الأقرب تلقائياً)
  bool get chosenByUser => _chosenByUser;

  /// الخريطة بتقرّب على هالنقطة (كل ما يتغير رقمها)
  MapFocus? get focus => _focus;

  /// الأبواب كنقاط على الخريطة
  List<MapPoi> get pois => [for (final g in _gates) MapPoi(id: g.targetId, location: g.location)];

  DestinationInfoDto? _byId(String id) {
    for (final g in _gates) {
      if (g.targetId == id) return g;
    }
    return null;
  }

  Future<void> start() async {
    unawaited(_loadGates());
    await navigation.start();
  }

  Future<void> _loadGates() async {
    final gates = await MapRepository.getHaramGates();
    if (_disposed || gates.isEmpty || identical(gates, _gates)) return;
    _gates = gates;
    if (_byId(_selectedId) == null) {
      _selectedId = _gates.first.targetId;
      navigation.retarget(FieldPlace.gate(selected));
    }
    if (_inspectedId != null && _byId(_inspectedId!) == null) _inspectedId = null;
    // قائمة السيرفر ممكن يكون فيها باب أقرب
    if (!_chosenByUser) _pickedNearest = false;
    _pickNearest();
    notifyListeners();
  }

  void _onNavigation() {
    _pickNearest();
    if (!_disposed) notifyListeners();
  }

  // أقرب باب لموقع المستخدم — مرة وحدة (حتى ما يتنقّل الباب مع كل خطوة)
  void _pickNearest() {
    final p = navigation.position;
    if (_chosenByUser || _pickedNearest || p == null) return;
    _pickedNearest = true;
    final nearest = _gates.reduce((a, b) => GeoUtils.haversine(p, a.location) <= GeoUtils.haversine(p, b.location) ? a : b);
    if (nearest.targetId != _selectedId) {
      _selectedId = nearest.targetId;
      navigation.retarget(FieldPlace.gate(nearest));
    }
  }

  /// المستخدم ضغط على دبوس باب: بطاقته + تقريب ناعم عليه
  void inspect(String targetId) {
    final gate = _byId(targetId);
    if (gate == null) return;
    _inspectedId = targetId;
    _focus = (point: gate.location, version: (_focus?.version ?? 0) + 1);
    notifyListeners();
  }

  /// سكّر البطاقة
  void closeInspection() {
    if (_inspectedId == null) return;
    _inspectedId = null;
    notifyListeners();
  }

  /// "اتجه إلى هذا الباب": الباب بيصير الوجهة والمسار بيتحسب من موقع المستخدم
  void select(String targetId) {
    if (targetId == _selectedId || _byId(targetId) == null) return;
    _chosenByUser = true;
    _selectedId = targetId;
    navigation.retarget(FieldPlace.gate(selected));
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    navigation
      ..removeListener(_onNavigation)
      ..dispose();
    super.dispose();
  }
}
