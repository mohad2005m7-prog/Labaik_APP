import 'package:flutter/widgets.dart';

// -------------------------------------------------------------
// ثيم الخريطة البديلة (OpenStreetMap لما ما يكون في مفتاح Google)
// بنفس ألوان assets/styles/map_style.json (الثيم الأغمق بتباين أعلى):
//   الأرض #dfe4e1 — المباني رمادي عميق مايل للأخضر — الطرق ومسارات المشي أبيض واضح
//   الماء #1E513B — الحدائق #b5cfbf — النصوص غامقة
// طبقات OSM صور جاهزة، فكل طبقة بترسم 4 مرات بفلاتر ألوان (ColorFilter.matrix):
//   1) رمادي مخضر حسب إضاءة اللون: الأفتح (الأرض) فاتح والأغمق (المباني) أغمق بكتير — تباين أعلى
//   2) الطرق ومسارات المشي: ألوانها بـ OSM دافية (أصفر/برتقالي/زهري/سلموني: أحمر − أزرق > 45) ← أبيض
//   3) الحدائق: (أخضر − باقي الألوان > 35) ← #b5cfbf
//   4) الماء: (أزرق − أحمر > 20) ← #1E513B
// -------------------------------------------------------------
class MapTheme {
  /// لون الأرض بالثيم — خلفية الخريطة لحد ما تحمل الطبقات
  static const background = Color(0xFFDFE4E1);

  static const _osmLandLuminance = 239.3; // أرض OSM ‏#f2efe9

  static const _road = Color(0xFFFFFFFF);
  static const _park = Color(0xFFB5CFBF);
  static const _water = Color(0xFF1E513B);

  /// 1) رمادي مخضر: كل قناة = إضاءة × a + b — الأبيض بيضل أبيض وأرض OSM بتصير #dfe4e1
  ///    (المباني ‏#d9d0c9 ← تقريباً #a2b1a8 والنصوص السودا بتضل سودا)
  static final ColorFilter silver = _base(background);

  /// الإضاءة ← لون الأرض [land] (أرض OSM بتصير [land] بالظبط والأبيض بيضل أبيض)
  static ColorFilter _base(Color land) => ColorFilter.matrix([
    ..._row(land.r * 255),
    ..._row(land.g * 255),
    ..._row(land.b * 255),
    0, 0, 0, 1, 0,
  ]);

  static List<double> _row(double land) {
    final a = (255 - land) / (255 - _osmLandLuminance);
    return [a * 0.2126, a * 0.7152, a * 0.0722, 0, 255 - 255 * a];
  }

  /// 2) الطرق ومسارات المشي: شفافية = (أحمر − أزرق − 45) × 255 / 10
  static final ColorFilter roads = _mask(_road, const [1, 0, -1], threshold: 45, ramp: 10);

  /// 3) الحدائق: شفافية = (أخضر − (أحمر + أزرق) / 2 − 35) × 255 / 8
  static final ColorFilter park = _mask(_park, const [-0.5, 1, -0.5], threshold: 35, ramp: 8);

  /// 4) الماء: شفافية = (أزرق − أحمر − 20) × 255 / 25
  static final ColorFilter water = _mask(_water, const [-1, 0, 1], threshold: 20, ramp: 25);

  // لون ثابت وشفافيته من مؤشر لوني: [معامل أحمر، أخضر، أزرق] — فوق [threshold] بيبلش يبين وبيكمل خلال [ramp]
  static ColorFilter _mask(Color color, List<double> index, {required double threshold, required double ramp}) {
    final k = 255 / ramp;
    return ColorFilter.matrix([
      0, 0, 0, 0, color.r * 255,
      0, 0, 0, 0, color.g * 255,
      0, 0, 0, 0, color.b * 255,
      index[0] * k, index[1] * k, index[2] * k, 0, -threshold * k,
    ]);
  }

  /// طبقة OSM بثيم لبيك
  static Widget themed(Widget tile) => Stack(
    fit: StackFit.passthrough,
    children: [
      ColorFiltered(colorFilter: silver, child: tile),
      ColorFiltered(colorFilter: roads, child: tile),
      ColorFiltered(colorFilter: park, child: tile),
      ColorFiltered(colorFilter: water, child: tile),
    ],
  );
}

// -------------------------------------------------------------
// ثيمات بألوان صور Figma (نفس طريقة MapTheme: فلاتر ألوان فوق طبقات OSM):
//   members — خريطة أفراد العائلة والمجموعة ("image 68"): أرض #F3F3F3 وطرق أزرق رمادي (#D4DCE2 / #B0C0D0 / #92A6BF) وحدائق #ACE0BF
//   route   — خريطة الطريق لنقطة التجمع ("image 42"): أرض بيج #EDEBDC وطرق رمادي وحدائق #CEF2DA
// الطرق الصغيرة بـ OSM بيضا (أزرق > 244) — المتوسطة والكبيرة دافية (أحمر − أزرق: الثانوية 56، السريعة 70+)
// -------------------------------------------------------------
class MapPalette {
  final Color land;
  final Color minorRoad;
  final Color road;
  final Color majorRoad;
  final Color park;
  final Color water;

  const MapPalette({required this.land, required this.minorRoad, required this.road, required this.majorRoad, required this.park, required this.water});

  static const members = MapPalette(
    land: Color(0xFFF3F3F3),
    minorRoad: Color(0xFFD4DCE2),
    road: Color(0xFFB0C0D0),
    majorRoad: Color(0xFF92A6BF),
    park: Color(0xFFACE0BF),
    water: Color(0xFFB0C0D0),
  );

  static const route = MapPalette(
    land: Color(0xFFEDEBDC),
    minorRoad: Color(0xFFF4F4F4),
    road: Color(0xFFC6CCD5),
    majorRoad: Color(0xFF9DA8B8),
    park: Color(0xFFCEF2DA),
    water: Color(0xFFAACBE8),
  );

  Widget themed(Widget tile) => Stack(
    fit: StackFit.passthrough,
    children: [
      ColorFiltered(colorFilter: MapTheme._base(land), child: tile),
      ColorFiltered(colorFilter: MapTheme._mask(minorRoad, const [0, 0, 1], threshold: 244, ramp: 8), child: tile),
      ColorFiltered(colorFilter: MapTheme._mask(road, const [1, 0, -1], threshold: 30, ramp: 12), child: tile),
      ColorFiltered(colorFilter: MapTheme._mask(majorRoad, const [1, 0, -1], threshold: 62, ramp: 6), child: tile),
      ColorFiltered(colorFilter: MapTheme._mask(park, const [-0.5, 1, -0.5], threshold: 35, ramp: 8), child: tile),
      ColorFiltered(colorFilter: MapTheme._mask(water, const [-1, 0, 1], threshold: 20, ramp: 25), child: tile),
    ],
  );
}
