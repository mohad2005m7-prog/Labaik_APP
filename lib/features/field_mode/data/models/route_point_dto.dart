import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/json_fields.dart';

// -------------------------------------------------------------
// RoutePointDto — نقطة مسار (من السيرفر) أو نقطة من موقع المستخدم الحي (للسيرفر)
// JSON (ASP.NET Core):  { "latitude": 21.42, "longitude": 39.82, "sequence": 3, "speed": 18.5 }
//   sequence: ترتيب النقطة على المسار (أو رقم تحديث الموقع الحي)
//   speed: السرعة بالكيلومتر/ساعة (المتوقعة على المسار، أو الحالية بالموقع الحي)
// -------------------------------------------------------------
class RoutePointDto {
  final double latitude;
  final double longitude;
  final int sequence;
  final double speed;

  const RoutePointDto({required this.latitude, required this.longitude, required this.sequence, this.speed = 0});

  factory RoutePointDto.fromJson(Map<String, dynamic> json) => RoutePointDto(
    latitude: json.requireDouble('latitude'),
    longitude: json.requireDouble('longitude'),
    sequence: json.optionalInt('sequence') ?? 0,
    speed: json.doubleOr('speed', 0),
  );

  Map<String, dynamic> toJson() => {'latitude': latitude, 'longitude': longitude, 'sequence': sequence, 'speed': speed};

  GeoPoint get point => GeoPoint(latitude, longitude);
}
