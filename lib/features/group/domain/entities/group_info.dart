import 'package:equatable/equatable.dart';

import '../../../../core/utils/geo_utils.dart';

// -------------------------------------------------------------
// المجموعة (من المشرف): اسمها ونقطة التجمع اللي حددها المشرف
// -------------------------------------------------------------
class GroupInfo extends Equatable {
  final String id;
  final String name;
  final GroupMeetingPoint? meetingPoint;

  const GroupInfo({required this.id, required this.name, this.meetingPoint});

  @override
  List<Object?> get props => [id, name, meetingPoint];
}

/// نقطة التجمع: [title] بكرت "وجهتك القادمة" ("بوابة الملك فهد — المسجد الحرام")
/// و[direction] بنصوص الإرشاد ("باتجاه باب الملك فهد")
class GroupMeetingPoint extends Equatable {
  final String title;
  final String direction;
  final GeoPoint location;

  const GroupMeetingPoint({required this.title, required this.direction, required this.location});

  @override
  List<Object?> get props => [title, direction, location.latitude, location.longitude];
}
