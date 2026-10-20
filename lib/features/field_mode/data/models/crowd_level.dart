// -------------------------------------------------------------
// حالة الازدحام عند الباب (من السيرفر — CrowdLevel)
// JSON: "low" / "medium" / "high" (أو 0 / 1 / 2) — أي قيمة ثانية = غير معروف (ما بتنعرض)
// -------------------------------------------------------------
enum CrowdLevel {
  low,
  medium,
  high;

  static CrowdLevel? fromJson(Object? value) => switch (value) {
    'low' || 'Low' || 0 => CrowdLevel.low,
    'medium' || 'Medium' || 1 => CrowdLevel.medium,
    'high' || 'High' || 2 => CrowdLevel.high,
    _ => null,
  };

  String toJson() => name;
}
