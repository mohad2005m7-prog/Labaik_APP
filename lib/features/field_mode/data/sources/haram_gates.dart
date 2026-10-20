import '../../../../core/utils/geo_utils.dart';
import '../models/destination_info_dto.dart';

// -------------------------------------------------------------
// أبواب المسجد الحرام الرئيسية — قائمة محلية لحد ما تيجي من السيرفر
// (GET /map/destinations?type=haram-gate مع روابط الصور وحالة الازدحام)
// وبتضل تشتغل بدون إنترنت (بدون صور)
// ⚠️ إحداثيات الأبواب تقريبية (± عشرات الأمتار) — السيرفر هو المرجع الدقيق
// -------------------------------------------------------------
class HaramGates {
  /// مركز المسجد الحرام (الكعبة المشرفة)
  static const center = GeoPoint(21.42249, 39.82621);

  static const defaults = [
    DestinationInfoDto(
      targetId: 'gate-1',
      nameAr: 'باب الملك عبد العزيز',
      nameEn: 'King Abdulaziz Gate',
      latitude: 21.42100,
      longitude: 39.82500,
      gateNumber: 1,
    ),
    DestinationInfoDto(
      targetId: 'gate-24',
      nameAr: 'باب السلام',
      nameEn: 'Bab Al-Salam',
      latitude: 21.42340,
      longitude: 39.82760,
      gateNumber: 24,
    ),
    DestinationInfoDto(
      targetId: 'gate-45',
      nameAr: 'باب الفتح',
      nameEn: 'Al-Fath Gate',
      latitude: 21.42475,
      longitude: 39.82585,
      gateNumber: 45,
    ),
    DestinationInfoDto(
      targetId: 'gate-62',
      nameAr: 'باب العمرة',
      nameEn: 'Umrah Gate',
      latitude: 21.42430,
      longitude: 39.82430,
      gateNumber: 62,
    ),
    DestinationInfoDto(
      targetId: 'gate-79',
      nameAr: 'باب الملك فهد',
      nameEn: 'King Fahd Gate',
      latitude: 21.42270,
      longitude: 39.82360,
      gateNumber: 79,
    ),
  ];

  /// الباب الافتراضي قبل ما نعرف موقع المستخدم (زي Figma 21:1859)
  static const defaultGateId = 'gate-79';
}
