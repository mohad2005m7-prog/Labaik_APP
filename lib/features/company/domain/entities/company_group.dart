import 'package:equatable/equatable.dart';

/// حالة المجموعة (الشارة): "نشطة" أو "منتهية" (رحلتها رجعت)
enum CompanyGroupStatus { active, ended }

// -------------------------------------------------------------
// مجموعة من مجموعات الشركة (CompanyGroupDto): اسمها، رحلتها، عدد المعتمرين، رمز الانضمام ومشرفها
// [joinCode] = الرمز اللي بيدخله المعتمر (أو بيمسحه QR) حتى ينضم — [supervisorName] null = بلا مشرف بعد
// -------------------------------------------------------------
class CompanyGroup extends Equatable {
  final String id;
  final String name;
  final String tripName;
  final int memberCount;
  final CompanyGroupStatus status;
  final String? thumbnail;
  final String tripId;
  final String joinCode;
  final String? supervisorName;

  const CompanyGroup({
    required this.id,
    required this.name,
    required this.tripName,
    required this.memberCount,
    required this.status,
    this.thumbnail,
    this.tripId = '',
    this.joinCode = '',
    this.supervisorName,
  });

  CompanyGroup copyWith({int? memberCount, String? supervisorName}) => CompanyGroup(
        id: id,
        name: name,
        tripName: tripName,
        memberCount: memberCount ?? this.memberCount,
        status: status,
        thumbnail: thumbnail,
        tripId: tripId,
        joinCode: joinCode,
        supervisorName: supervisorName ?? this.supervisorName,
      );

  @override
  List<Object?> get props => [id, name, tripName, memberCount, status, thumbnail, tripId, joinCode, supervisorName];
}
