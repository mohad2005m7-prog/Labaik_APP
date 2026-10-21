import 'package:equatable/equatable.dart';

/// حالة المجموعة (الشارة): "نشطة" أو "منتهية" (رحلتها رجعت)
enum CompanyGroupStatus { active, ended }

// -------------------------------------------------------------
// مجموعة من مجموعات الشركة (CompanyGroupDto): اسمها، رحلتها، عدد المعتمرين، رمز الانضمام ومشرفها
// [joinCode] = الرمز اللي بيدخله المعتمر (أو بيمسحه QR) حتى ينضم — [supervisorName] null = بلا مشرف بعد
// [notes] ملاحظات الشركة — [capacity] أقصى عدد معتمرين (null = بلا حد؛ السيرفر بيرفض الزيادة Group.CapacityReached)
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
  final String? supervisorUserId;
  final String? notes;
  final int? capacity;

  /// رحلة حج (العدد بيطلع "حاج" بدل "معتمر")
  final bool hajj;

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
    this.supervisorUserId,
    this.notes,
    this.capacity,
    this.hajj = false,
  });

  CompanyGroup copyWith({int? memberCount, String? supervisorName, String? supervisorUserId, String? name, String? notes, int? capacity, bool clearNotes = false, bool clearCapacity = false}) => CompanyGroup(
        id: id,
        name: name ?? this.name,
        tripName: tripName,
        memberCount: memberCount ?? this.memberCount,
        status: status,
        thumbnail: thumbnail,
        tripId: tripId,
        joinCode: joinCode,
        supervisorName: supervisorName ?? this.supervisorName,
        supervisorUserId: supervisorUserId ?? this.supervisorUserId,
        notes: clearNotes ? null : notes ?? this.notes,
        capacity: clearCapacity ? null : capacity ?? this.capacity,
        hajj: hajj,
      );

  @override
  List<Object?> get props => [id, name, tripName, memberCount, status, thumbnail, tripId, joinCode, supervisorName, supervisorUserId, notes, capacity, hajj];
}
