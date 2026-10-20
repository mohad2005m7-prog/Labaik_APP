import '../../../../core/l10n/tx.dart';

/// نصوص شاشة تفعيل الموقع
abstract final class LocationPermissionText {
  static const title = Tx('فعّل موقعك', 'Enable Your Location');
  static const description = Tx(
    'يساعدك لبيك على معرفة موقعك، الوصول إلى فندقك ومجموعتك، واستخدام الخريطة والمساعدة عند الحاجة.',
    'Labaik helps you know your location, reach your hotel and your group, and use the map and get help when needed.',
  );
  static const enable = Tx('تفعيل الموقع', 'Enable Location');
  static const later = Tx('لاحقًا', 'Later');
}
