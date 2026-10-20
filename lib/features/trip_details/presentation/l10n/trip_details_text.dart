import '../../../../core/l10n/tx.dart';

/// نصوص شاشة "تفاصيل الرحلة" (Figma 1:8143)
abstract final class TripDetailsText {
  static const title = Tx('تفاصيل الرحلة', 'Trip Details');
  static const info = Tx('معلومات الرحلة الخاصة بك', 'Your trip information');
  // Figma: "رحلتك الحالية  : عمرة  " (بمسافات زيادة) — بمسافة وحدة
  static String current(String type) => tr('رحلتك الحالية : $type', 'Your current trip: $type');
  static const arrivalDate = Tx('موعد الوصول : ', 'Arrival date: ');
  static const arrivalPoint = Tx('نقطة الوصول : ', 'Arrival point: ');
  // الميقات الوحيد المدعوم بالتطبيق (وضع الميدان بيوجّه لمسجد ميقات ذو الحليفة)
  static const miqat = Tx('الميقات المتوقع: ذو الحليفة — مسجد ميقات ذو الحليفة', 'Expected miqat: Dhul Hulaifah — Dhul Hulaifah Miqat Mosque');
  static const reminder = Tx('سنذكّرك بموعد الاستعداد للإحرام حسب مسار رحلتك.', 'We will remind you when to prepare for ihram based on your route.');
  static const edit = Tx('تعديل تفاصيل الرحلة', 'Edit trip details');

  /// قيمة ما دخّلها المعتمر لسا
  static const notSet = '—';
}
