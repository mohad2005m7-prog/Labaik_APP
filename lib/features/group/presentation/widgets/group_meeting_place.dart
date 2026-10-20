import '../../../field_mode/data/models/field_place.dart';
import '../../domain/entities/group_info.dart';
import '../l10n/group_route_text.dart';

/// نقطة التجمع كوجهة للملاحة (نفس محرّك "الطريق إلى ..." بوضع الميدان): دبوسها على الخريطة باسم "نقطة التجمع"
/// وآخر جزء من الطريق مشي (5 كم/س لتقدير الوقت بدون إنترنت)
FieldPlace groupMeetingPlace(GroupMeetingPoint point) => FieldPlace(
      location: point.location,
      nameAr: GroupRouteText.meetingPoint.ar,
      nameEn: GroupRouteText.meetingPoint.en,
      nearMeters: 0,
      averageSpeedKmh: 5,
    );
