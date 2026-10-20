import '../../../family/domain/entities/family_member.dart';

// -------------------------------------------------------------
// فرد بالمجموعة: نفس بيانات فرد العائلة (الاتصال، آخر ظهور، مشاركة الموقع) + هل هو مشرف المجموعة
// (كرته بيطلع أول القائمة باسم "مشرف المجموعة" زي Figma)
// -------------------------------------------------------------
class GroupMember extends FamilyMember {
  final bool isSupervisor;

  const GroupMember({
    required super.userId,
    required super.name,
    super.photoUrl,
    super.isMe,
    super.isOnline,
    super.lastSeenAt,
    super.sharesLocation,
    super.location,
    super.locationUpdatedAt,
    this.isSupervisor = false,
  });

  @override
  List<Object?> get props => [...super.props, isSupervisor];
}
