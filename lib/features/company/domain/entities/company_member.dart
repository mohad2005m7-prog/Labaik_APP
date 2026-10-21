import 'package:equatable/equatable.dart';

// -------------------------------------------------------------
// عضو بمجموعة من مجموعات الشركة (GroupMemberRowDto / GroupMemberDetailsDto)
// [isSupervisor] = المشرف (Role 1 Leader) وبيجي أول القائمة — [healthNotes] و[notes] ببطاقة العضو بس
// -------------------------------------------------------------
class CompanyMember extends Equatable {
  final String userId;
  final String name;
  final String? email;
  final bool isSupervisor;
  final int? number;
  final String? nationality;
  final String? photoUrl;
  final bool present;
  final String? healthNotes;
  final String? notes;

  const CompanyMember({
    required this.userId,
    required this.name,
    this.email,
    this.isSupervisor = false,
    this.number,
    this.nationality,
    this.photoUrl,
    this.present = false,
    this.healthNotes,
    this.notes,
  });

  @override
  List<Object?> get props => [userId, name, email, isSupervisor, number, nationality, photoUrl, present, healthNotes, notes];
}

// -------------------------------------------------------------
// مشرف بقائمة الشركة (CompanySupervisorDto) — [groupsCount] = كم مجموعة بيشرف عليها
// [suspended] = الشركة موقفة حسابه (isDisabled من السيرفر — لسا مش موجود، فبيضل false)
// -------------------------------------------------------------
class CompanySupervisor extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final int groupsCount;
  final bool suspended;

  const CompanySupervisor({required this.userId, required this.name, required this.email, this.phone, this.groupsCount = 0, this.suspended = false});

  CompanySupervisor copyWith({bool? suspended}) => CompanySupervisor(userId: userId, name: name, email: email, phone: phone, groupsCount: groupsCount, suspended: suspended ?? this.suspended);

  @override
  List<Object?> get props => [userId, name, email, phone, groupsCount, suspended];
}

// -------------------------------------------------------------
// معتمر من معتمري الشركة (CompanyPilgrimDto من GET /company/pilgrims) — مرة وحدة حتى لو بأكتر من مجموعة
// -------------------------------------------------------------
class CompanyPilgrim extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final List<String> groupIds;

  const CompanyPilgrim({required this.userId, required this.name, required this.email, this.phone, this.groupIds = const []});

  @override
  List<Object?> get props => [userId, name, email, phone, groupIds];
}
