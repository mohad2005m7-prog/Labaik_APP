import 'package:flutter/foundation.dart';

// -------------------------------------------------------------
// إعدادات الخرائط
// مفتاح Google Maps بيوصل وقت التشغيل:  flutter run --dart-define=MAPS_API_KEY=xxxx
// ونفس القيمة بتروح لـ AndroidManifest عن طريق android/app/build.gradle.kts
// بدون مفتاح: خريطة بديلة تفاعلية (OpenStreetMap) بألوان هادية بدل ما يطلع مكان الخريطة أبيض
// -------------------------------------------------------------
class MapsConfig {
  static const apiKey = String.fromEnvironment('MAPS_API_KEY');

  /// ملف ألوان Google Maps
  static const stylePath = 'assets/styles/map_style.json';

  /// Google Maps بس إذا في مفتاح (بدونه Google Maps بيوقّف التطبيق)
  /// iOS لسا بدها إعداد المفتاح بـ AppDelegate (بتنعمل على Mac) فبتستخدم الخريطة البديلة
  static bool get useGoogleMaps => apiKey.isNotEmpty && !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// الخريطة البديلة: OpenStreetMap (بدون مفتاح — للتطوير والحالات اللي ما فيها مفتاح)
  static const fallbackTilesUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const appPackage = 'com.example.labaik';

  /// سيرفر لبيك (ASP.NET Core) لبيانات الخرائط: الأبواب، نقاط المسار، "أنا ضائع"، الموقع الحي
  static const mapApiBaseUrl = 'https://labaik-api.onrender.com/api/v1/map';

  /// الربط مع سيرفر الخرائط — بيتفعّل لما تكون الـ endpoints جاهزة:  flutter run --dart-define=MAP_BACKEND=true
  /// قبلها التطبيق بيستخدم البيانات المحلية (الأبواب) والحساب المحلي للمسار
  static const useMapBackend = bool.fromEnvironment('MAP_BACKEND');
}
