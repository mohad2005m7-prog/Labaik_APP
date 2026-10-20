import '../../../../core/utils/geo_utils.dart';

// -------------------------------------------------------------
// تحديث لحظي لموقع فرد بالمجموعة (من /hubs/location):
//   MemberMoved — "LocationUpdated": موقعه الجديد
//   MemberStoppedSharing — "StoppedSharing": وقف المشاركة (علامته بتنشال من الخريطة)
// -------------------------------------------------------------
sealed class GroupLocationEvent {
  final String userId;

  const GroupLocationEvent(this.userId);
}

class MemberMoved extends GroupLocationEvent {
  final GeoPoint location;
  final DateTime at;

  const MemberMoved(super.userId, this.location, this.at);
}

class MemberStoppedSharing extends GroupLocationEvent {
  const MemberStoppedSharing(super.userId);
}
