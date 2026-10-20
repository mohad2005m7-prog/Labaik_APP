import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/location_service.dart';

// -------------------------------------------------------------
// مصدر موقع المستخدم لشاشات الطريق والحرم: موقع الجهاز الفعلي (GPS بدقة عالية عن طريق Geolocator)
// ما في أي إحداثيات ثابتة للمستخدم — بالمحاكي الموقع هو اللي مضبوط بإعدادات المحاكي (Extended controls → Location)
// (الواجهة موجودة حتى الاختبارات تقدر تمرّر مصدر وهمي)
// -------------------------------------------------------------
abstract class LocationSource {
  Future<LocationAccess> requestAccess();
  Future<LocationAccess> checkAccess();
  Future<GeoPoint?> lastKnownPosition();
  Future<GeoPoint?> currentPosition();
  Stream<GeoPoint> positions();
  Future<void> openSettings(LocationAccess access);
}

class DeviceLocationSource implements LocationSource {
  const DeviceLocationSource();

  @override
  Future<LocationAccess> requestAccess() => LocationService.requestAccess();

  @override
  Future<LocationAccess> checkAccess() => LocationService.checkAccess();

  @override
  Future<GeoPoint?> lastKnownPosition() => LocationService.lastKnownPosition();

  @override
  Future<GeoPoint?> currentPosition() => LocationService.currentPosition();

  @override
  Stream<GeoPoint> positions() => LocationService.positions();

  @override
  Future<void> openSettings(LocationAccess access) => LocationService.openSettings(access);
}
