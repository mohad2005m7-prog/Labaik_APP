import '../../../../core/l10n/app_language.dart';
import '../../../../core/utils/geo_utils.dart';
import 'destination_info_dto.dart';
import 'field_destination.dart';

// -------------------------------------------------------------
// مكان الوجهة على الخريطة (لشاشات "الطريق إلى ..." وأبواب المسجد الحرام)
// موقع المستخدم دايماً من GPS الجهاز — هون بس إحداثيات الوجهات (والسيرفر بيقدر يبدّلها)
// -------------------------------------------------------------
class FieldPlace {
  final GeoPoint location;
  final String? nameAr; // اسم الوجهة على الخريطة بالعربي والإنجليزي (ثابت هون أو من السيرفر)
  final String? nameEn;
  final String? targetId; // رقم الوجهة بالسيرفر (TargetId)
  final double nearMeters; // من هالمسافة نصوص الإرشاد بتصير "الوجهة قريبة" (حالة Figma القريبة) — 0 = ما في
  final double averageSpeedKmh; // سرعة آخر جزء من الطريق — لتقدير الوقت محلياً بدون إنترنت

  const FieldPlace({
    required this.location,
    this.nameAr,
    this.nameEn,
    this.targetId,
    required this.nearMeters,
    required this.averageSpeedKmh,
  });

  /// باب من أبواب المسجد الحرام (آخر جزء مشي) — من DestinationInfoDto
  factory FieldPlace.gate(DestinationInfoDto gate) => FieldPlace(
    location: gate.location,
    nameAr: gate.nameAr,
    nameEn: gate.nameEn,
    targetId: gate.targetId,
    nearMeters: 0,
    averageSpeedKmh: 5,
  );

  /// الاسم بلغة التطبيق
  String label() => (AppLanguage.isArabic ? nameAr : nameEn) ?? '';
}

extension FieldDestinationPlace on FieldDestination {
  /// مكان الوجهة — الفندق بتنضاف خريطته لما يكون عندنا إحداثيات مكان الإقامة
  FieldPlace? get place => switch (this) {
    // مسجد ميقات ذو الحليفة (أبيار علي)
    FieldDestination.miqat => const FieldPlace(
      location: GeoPoint(24.4136, 39.5431),
      nameAr: 'مسجد ميقات ذو الحليفة',
      nameEn: 'Dhul Hulaifah Miqat Mosque',
      targetId: 'miqat-dhul-hulaifah',
      nearMeters: 1000,
      averageSpeedKmh: 40,
    ),
    // مكة المكرمة (المسجد الحرام)
    FieldDestination.mecca => const FieldPlace(
      location: GeoPoint(21.4225, 39.8262),
      nameAr: 'مكة',
      nameEn: 'Makkah',
      targetId: 'makkah',
      nearMeters: 10000,
      averageSpeedKmh: 80,
    ),
    // المسجد الحرام — جوّا مكة (زحمة)
    FieldDestination.haram => const FieldPlace(
      location: GeoPoint(21.4225, 39.8262),
      nameAr: 'المسجد الحرام',
      nameEn: 'Al-Masjid Al-Haram',
      targetId: 'haram',
      nearMeters: 0,
      averageSpeedKmh: 19,
    ),
    FieldDestination.hotel => null,
  };
}
