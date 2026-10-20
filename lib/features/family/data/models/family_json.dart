import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/json_fields.dart';
import '../../domain/entities/family_circle.dart';
import '../../domain/entities/family_member.dart';

// -------------------------------------------------------------
// JSON دائرة العائلة من السيرفر (camelCase أو PascalCase):
//   FamilyCircleDto:  { id, name, code, inviteLink, isOwner, membersCount, mySharesLocation, meetingPoint: { name, latitude, longitude } }
//   FamilyMemberDto:  { userId, fullName, photoUrl, isMe, isOnline, lastSeenAt, sharesLocation, latitude, longitude, locationUpdatedAt }
//   lookup:           { id, name, membersCount }
// -------------------------------------------------------------
String? _text(Map<String, dynamic> json, String name) {
  final value = json.field(name)?.toString().trim();
  return value == null || value.isEmpty ? null : value;
}

DateTime? _time(Map<String, dynamic> json, String name) => DateTime.tryParse(_text(json, name) ?? '')?.toLocal();

GeoPoint? _point(Map<String, dynamic> json) {
  final lat = json.field('latitude'), lng = json.field('longitude');
  return lat is num && lng is num ? GeoPoint(lat.toDouble(), lng.toDouble()) : null;
}

abstract final class FamilyJson {
  static FamilyCircle circle(Map<String, dynamic> json) {
    final meeting = json.field('meetingPoint');
    final point = meeting is Map<String, dynamic> ? _point(meeting) : null;
    final sharing = json.field('mySharesLocation');
    return FamilyCircle(
      id: json.requireString('id'),
      name: _text(json, 'name') ?? '',
      code: _text(json, 'code') ?? '',
      inviteLink: _text(json, 'inviteLink'),
      isOwner: json.field('isOwner') == true,
      membersCount: json.optionalInt('membersCount') ?? 1,
      mySharesLocation: sharing is bool ? sharing : null,
      meetingPoint: point == null ? null : MeetingPoint(name: _text(meeting as Map<String, dynamic>, 'name') ?? '', location: point),
    );
  }

  static Map<String, dynamic> circleToJson(FamilyCircle c) => {
        'id': c.id,
        'name': c.name,
        'code': c.code,
        'inviteLink': c.inviteLink,
        'isOwner': c.isOwner,
        'membersCount': c.membersCount,
        'mySharesLocation': c.mySharesLocation,
        'meetingPoint': c.meetingPoint == null ? null : {'name': c.meetingPoint!.name, 'latitude': c.meetingPoint!.location.latitude, 'longitude': c.meetingPoint!.location.longitude},
      };

  static FamilyCircleSummary summary(Map<String, dynamic> json) => FamilyCircleSummary(
        id: json.requireString('id'),
        name: _text(json, 'name') ?? '',
        membersCount: json.optionalInt('membersCount') ?? 0,
      );

  static FamilyMember member(Map<String, dynamic> json) => FamilyMember(
        userId: _text(json, 'userId') ?? json.requireString('id'),
        name: _text(json, 'fullName') ?? _text(json, 'name') ?? '',
        photoUrl: _text(json, 'photoUrl'),
        isMe: json.field('isMe') == true,
        isOnline: json.field('isOnline') == true,
        lastSeenAt: _time(json, 'lastSeenAt'),
        sharesLocation: json.field('sharesLocation') == true,
        location: _point(json),
        locationUpdatedAt: _time(json, 'locationUpdatedAt'),
      );

  static Map<String, dynamic> memberToJson(FamilyMember m) => {
        'userId': m.userId,
        'fullName': m.name,
        'photoUrl': m.photoUrl,
        'isMe': m.isMe,
        'isOnline': m.isOnline,
        'lastSeenAt': m.lastSeenAt?.toUtc().toIso8601String(),
        'sharesLocation': m.sharesLocation,
        'latitude': m.location?.latitude,
        'longitude': m.location?.longitude,
        'locationUpdatedAt': m.locationUpdatedAt?.toUtc().toIso8601String(),
      };
}
