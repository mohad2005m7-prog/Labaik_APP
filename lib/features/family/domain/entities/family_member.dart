import 'package:equatable/equatable.dart';

import '../../../../core/utils/geo_utils.dart';

/// حالة موقع الفرد بالقائمة: "موقعه متاح" / "موقعه غير متاح" / "لم يشارك موقعه"
enum MemberLocationState { available, unavailable, notShared }

// -------------------------------------------------------------
// فرد بدائرة العائلة (من السيرفر): متصل الآن أو آخر ظهور، ومشاركة موقعه وآخر موقع وصل منه
// -------------------------------------------------------------
class FamilyMember extends Equatable {
  final String userId;
  final String name;
  final String? photoUrl;
  final bool isMe;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final bool sharesLocation;
  final GeoPoint? location;
  final DateTime? locationUpdatedAt;

  const FamilyMember({
    required this.userId,
    required this.name,
    this.photoUrl,
    this.isMe = false,
    this.isOnline = false,
    this.lastSeenAt,
    this.sharesLocation = false,
    this.location,
    this.locationUpdatedAt,
  });

  /// الموقع "متاح" لو وصل خلال آخر 15 دقيقة
  static const freshFor = Duration(minutes: 15);

  MemberLocationState locationState({DateTime? now}) {
    if (!sharesLocation) return MemberLocationState.notShared;
    final at = locationUpdatedAt;
    if (location == null || at == null) return MemberLocationState.unavailable;
    return (now ?? DateTime.now()).difference(at) <= freshFor ? MemberLocationState.available : MemberLocationState.unavailable;
  }

  @override
  List<Object?> get props => [userId, name, photoUrl, isMe, isOnline, lastSeenAt, sharesLocation, location?.latitude, location?.longitude, locationUpdatedAt];
}
