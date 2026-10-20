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
// -------------------------------------------------------------
class CompanySupervisor extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final int groupsCount;

  const CompanySupervisor({required this.userId, required this.name, required this.email, this.phone, this.groupsCount = 0});

  @override
  List<Object?> get props => [userId, name, email, phone, groupsCount];
}
