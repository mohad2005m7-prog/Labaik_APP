import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/json_fields.dart';
import 'crowd_level.dart';

// -------------------------------------------------------------
// DestinationInfoDto — وجهة على الخريطة (مثل أبواب المسجد الحرام) من السيرفر
// JSON (ASP.NET Core):
//   { "targetId": "gate-79", "nameAr": "باب الملك فهد", "nameEn": "King Fahd Gate",
//     "latitude": 21.4227, "longitude": 39.8236, "gateNumber": 79,
//     "imageUrl": "https://.../gates/79.jpg", "crowdLevel": "medium" }
//   imageUrl و crowdLevel اختياريين (null = ما في صورة / الازدحام غير معروف)
// -------------------------------------------------------------
class DestinationInfoDto {
  final String targetId;
  final String nameAr;
  final String nameEn;
  final double latitude;
  final double longitude;
  final int? gateNumber; // رقم الباب (للأبواب بس)
  final String? imageUrl; // صورة الباب (عالية الجودة) من السيرفر
  final CrowdLevel? crowdLevel; // حالة الازدحام الحالية

  const DestinationInfoDto({
    required this.targetId,
    required this.nameAr,
    required this.nameEn,
    required this.latitude,
    required this.longitude,
    this.gateNumber,
    this.imageUrl,
    this.crowdLevel,
  });

  factory DestinationInfoDto.fromJson(Map<String, dynamic> json) {
    final image = json.field('imageUrl')?.toString();
    return DestinationInfoDto(
      targetId: json.requireString('targetId'),
      nameAr: json.requireString('nameAr'),
      nameEn: json.requireString('nameEn'),
      latitude: json.requireDouble('latitude'),
      longitude: json.requireDouble('longitude'),
      gateNumber: json.optionalInt('gateNumber'),
      imageUrl: image == null || image.isEmpty ? null : image,
      crowdLevel: CrowdLevel.fromJson(json.field('crowdLevel')),
    );
  }

  Map<String, dynamic> toJson() => {
    'targetId': targetId,
    'nameAr': nameAr,
    'nameEn': nameEn,
    'latitude': latitude,
    'longitude': longitude,
    'gateNumber': gateNumber,
    'imageUrl': imageUrl,
    'crowdLevel': crowdLevel?.toJson(),
  };

  /// الاسم بلغة التطبيق
  String name(String language) => language == 'ar' ? nameAr : nameEn;

  /// الاسم باللغة الثانية (بيبيّن تحت الاسم الأساسي ببطاقة الباب)
  String otherName(String language) => language == 'ar' ? nameEn : nameAr;

  GeoPoint get location => GeoPoint(latitude, longitude);
}
