// -------------------------------------------------------------
// قراءة حقول JSON من سيرفر ASP.NET Core
// الافتراضي هناك camelCase (latitude) بس ممكن يكون PascalCase (Latitude) — فبنقبل الاتنين
// -------------------------------------------------------------
extension JsonFields on Map<String, dynamic> {
  Object? field(String name) => this[name] ?? this[name[0].toUpperCase() + name.substring(1)];

  double requireDouble(String name) {
    final value = field(name);
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? (throw FormatException('Invalid $name: $value'));
    throw FormatException('Missing $name');
  }

  double doubleOr(String name, double fallback) {
    final value = field(name);
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  int? optionalInt(String name) {
    final value = field(name);
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String requireString(String name) {
    final value = field(name);
    if (value == null) throw FormatException('Missing $name');
    return value.toString();
  }
}

/// الرد ممكن يكون القائمة نفسها أو ملفوف بـ { "data": ... }
Object? unwrapData(Object? decoded) => decoded is Map<String, dynamic> && decoded.containsKey('data') ? decoded['data'] : decoded;
