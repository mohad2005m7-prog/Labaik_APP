import 'tx.dart';

// -------------------------------------------------------------
// الدول: الداشبورد بتخزّن الدولة برمزها (ISO مثل "SA") — التطبيق بيعرض الاسم وبيحفظ الرمز
// القيمة القديمة المكتوبة كاسم (مثل "فلسطين") بتنعرض زي ما هي
// -------------------------------------------------------------
abstract final class CompanyCountries {
  static const all = [
    ('PS', Tx('فلسطين', 'Palestine')),
    ('JO', Tx('الأردن', 'Jordan')),
    ('SA', Tx('السعودية', 'Saudi Arabia')),
    ('EG', Tx('مصر', 'Egypt')),
    ('AE', Tx('الإمارات', 'UAE')),
    ('QA', Tx('قطر', 'Qatar')),
    ('KW', Tx('الكويت', 'Kuwait')),
    ('BH', Tx('البحرين', 'Bahrain')),
    ('OM', Tx('عُمان', 'Oman')),
    ('LB', Tx('لبنان', 'Lebanon')),
    ('SY', Tx('سوريا', 'Syria')),
    ('IQ', Tx('العراق', 'Iraq')),
    ('YE', Tx('اليمن', 'Yemen')),
    ('TR', Tx('تركيا', 'Türkiye')),
    ('MA', Tx('المغرب', 'Morocco')),
    ('DZ', Tx('الجزائر', 'Algeria')),
    ('TN', Tx('تونس', 'Tunisia')),
    ('LY', Tx('ليبيا', 'Libya')),
    ('SD', Tx('السودان', 'Sudan')),
  ];

  /// الاسم للعرض ("SA" → "السعودية") — غير معروف: زي ما هو
  static String? label(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final v = value.trim();
    for (final (code, name) in all) {
      if (code == v.toUpperCase() || name.ar == v || name.en.toLowerCase() == v.toLowerCase()) return name();
    }
    return v;
  }

  /// الرمز لقيمة مخزّنة (اسم أو رمز) — null لو مش بالقائمة
  static String? codeOf(String? value) {
    if (value == null) return null;
    final v = value.trim();
    for (final (code, name) in all) {
      if (code == v.toUpperCase() || name.ar == v || name.en.toLowerCase() == v.toLowerCase()) return code;
    }
    return null;
  }
}
