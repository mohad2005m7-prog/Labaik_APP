import 'package:equatable/equatable.dart';

import '../../../../core/utils/geo_utils.dart';

// -------------------------------------------------------------
// دائرة العائلة (من السيرفر): الاسم ("عائلة أحمد")، رمز الانضمام (A7K9P2) ورابطه
// [mySharesLocation]: قراري بمشاركة موقعي — null = لسا ما قررت (بتطلع شاشة "مشاركة موقعك مع عائلتك")
// [meetingPoint]: نقطة التجمع (لو محددة)
// -------------------------------------------------------------
class FamilyCircle extends Equatable {
  final String id;
  final String name;
  final String code;
  final String? inviteLink;
  final bool isOwner;
  final int membersCount;
  final bool? mySharesLocation;
  final MeetingPoint? meetingPoint;

  const FamilyCircle({
    required this.id,
    required this.name,
    required this.code,
    this.inviteLink,
    this.isOwner = false,
    this.membersCount = 1,
    this.mySharesLocation,
    this.meetingPoint,
  });

  /// فيها غيري؟ (لو أنا بس، بتضل شاشة الدعوة)
  bool get hasOthers => membersCount > 1;

  FamilyCircle copyWith({bool? mySharesLocation, int? membersCount}) => FamilyCircle(
        id: id,
        name: name,
        code: code,
        inviteLink: inviteLink,
        isOwner: isOwner,
        membersCount: membersCount ?? this.membersCount,
        mySharesLocation: mySharesLocation ?? this.mySharesLocation,
        meetingPoint: meetingPoint,
      );

  @override
  List<Object?> get props => [id, name, code, inviteLink, isOwner, membersCount, mySharesLocation, meetingPoint];
}

/// نتيجة البحث بالرمز (قبل الانضمام): "تم العثور على دائرة عائلتك"
class FamilyCircleSummary extends Equatable {
  final String id;
  final String name;
  final int membersCount;

  const FamilyCircleSummary({required this.id, required this.name, this.membersCount = 0});

  @override
  List<Object?> get props => [id, name, membersCount];
}

class MeetingPoint extends Equatable {
  final String name;
  final GeoPoint location;

  const MeetingPoint({required this.name, required this.location});

  @override
  List<Object?> get props => [name, location.latitude, location.longitude];
}
