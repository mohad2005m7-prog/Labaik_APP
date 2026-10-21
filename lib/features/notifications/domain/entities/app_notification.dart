import 'package:equatable/equatable.dart';

/// أنواع الإشعارات اللي بيبعتها السيرفر (type)
enum NotificationKind {
  /// 1 AnnouncementPosted — لكل أعضاء المجموعة غير الكاتب ([AppNotification.preview] = عنوان الإعلان)
  announcement,

  /// 2 MemberJoinedGroup — لمشرف المجموعة بس ([AppNotification.preview] = اسم العضو)
  memberJoined,

  /// 6 GatheringPointChanged — ([AppNotification.preview] = العنوان)
  gatheringPoint,

  /// 8 GroupMessagePosted / 9 SupervisorMessagePosted — ([AppNotification.preview] = نص الرسالة)
  groupMessage,
  supervisorMessage,

  /// 11 LostChildReported — ([AppNotification.preview] = الوصف)
  lostChild,

  /// 12 FamilyMemberJoined — ([AppNotification.preview] = اسم العضو الجديد)
  familyJoined,

  /// أي نوع تاني (أو جديد بالسيرفر) — بيطلع "إشعار جديد" مع نصه
  other,
}

// -------------------------------------------------------------
// إشعار من السيرفر: نوعه ونص قصير، والجملة بيصيغها التطبيق
// [referenceId]: رقم الإعلان أو العضو حسب النوع
// -------------------------------------------------------------
class AppNotification extends Equatable {
  final String id;
  final NotificationKind kind;
  final String? groupId;
  final String? referenceId;
  final String preview;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.kind,
    required this.createdAt,
    this.groupId,
    this.referenceId,
    this.preview = '',
    this.isRead = false,
  });

  @override
  List<Object?> get props => [id, kind, groupId, referenceId, preview, createdAt, isRead];
}
