import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'geo_utils.dart';

// -------------------------------------------------------------
// LocationService — صلاحية الموقع وموقع المستخدم الحي (Geolocator)
// مستخدمة بشاشة "فعّل موقعك" وبخرائط وضع الميدان
// -------------------------------------------------------------

/// حالة الوصول للموقع
enum LocationAccess {
  granted, // مسموح والموقع شغّال
  denied, // المستخدم رفض (بنقدر نطلب مرة ثانية)
  deniedForever, // رفض نهائي — لازم من إعدادات التطبيق
  serviceOff, // خدمة الموقع بالجهاز مطفية
}

class LocationService {
  /// بيطلب الصلاحية إذا لسا ما انطلبت، وبيرجع حالة الوصول
  static Future<LocationAccess> requestAccess() => _access(request: true);

  /// حالة الوصول الحالية بدون ما يطلب شي من المستخدم
  static Future<LocationAccess> checkAccess() => _access(request: false);

  static Future<LocationAccess> _access({required bool request}) async {
    try {
      var permission = await Geolocator.checkPermission();
      if (request && permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      switch (permission) {
        case LocationPermission.always:
        case LocationPermission.whileInUse:
          break;
        case LocationPermission.deniedForever:
          return LocationAccess.deniedForever;
        default:
          return LocationAccess.denied;
      }
      if (!await Geolocator.isLocationServiceEnabled()) return LocationAccess.serviceOff;
      return LocationAccess.granted;
    } catch (_) {
      // جهاز/منصة بدون خدمة موقع
      return LocationAccess.denied;
    }
  }

  /// آخر موقع معروف (سريع — ممكن يكون null)
  static Future<GeoPoint?> lastKnownPosition() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      return position == null ? null : GeoPoint(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  /// إعدادات GPS بدقة عالية حسب المنصة — تحديث كل ما يتحرك المستخدم 5 م
  static LocationSettings _settings({Duration? timeLimit}) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(accuracy: LocationAccuracy.high, distanceFilter: 5, intervalDuration: const Duration(seconds: 2), timeLimit: timeLimit);
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.otherNavigation,
        distanceFilter: 5,
        pauseLocationUpdatesAutomatically: false,
        timeLimit: timeLimit,
      );
    }
    return LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5, timeLimit: timeLimit);
  }

  /// الموقع الحالي الفعلي (قراءة جديدة بدقة عالية — بتستنى لحد 15 ثانية)
  static Future<GeoPoint?> currentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(locationSettings: _settings(timeLimit: const Duration(seconds: 15)));
      return GeoPoint(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  /// موقع المستخدم الحي بدقة عالية
  static Stream<GeoPoint> positions() {
    return Geolocator.getPositionStream(locationSettings: _settings()).map((position) => GeoPoint(position.latitude, position.longitude));
  }

  /// بيفتح الإعدادات المناسبة (خدمة الموقع أو صلاحيات التطبيق)
  static Future<void> openSettings(LocationAccess access) async {
    try {
      if (access == LocationAccess.serviceOff) {
        await Geolocator.openLocationSettings();
      } else {
        await Geolocator.openAppSettings();
      }
    } catch (_) {}
  }
}
