import 'package:equatable/equatable.dart';

// -------------------------------------------------------------
// صلاحياتي بمحادثة (من /home للمجموعة):
// [readOnly] = الشركة بتقرأ دردشة مجموعتها بس — [isSupervisor] = مشرف المجموعة (بيحذف أي رسالة، بيكتم، وبيقفل الكتابة)
// [onlySupervisorCanPost] = الكتابة للمشرف بس — [mutedUntil] = أنا مكتوم لحد هالوقت
// -------------------------------------------------------------
class ChatRoom extends Equatable {
  final bool isGroup;
  final bool readOnly;
  final bool isSupervisor;
  final bool onlySupervisorCanPost;
  final DateTime? mutedUntil;

  const ChatRoom({this.isGroup = false, this.readOnly = false, this.isSupervisor = false, this.onlySupervisorCanPost = false, this.mutedUntil});

  static const direct = ChatRoom();

  bool get isMuted => mutedUntil != null && mutedUntil!.isAfter(DateTime.now());

  /// بقدر أكتب؟ (المشرف دايماً)
  bool get canPost => !readOnly && (isSupervisor || (!isMuted && !(isGroup && onlySupervisorCanPost)));

  ChatRoom copyWith({bool? onlySupervisorCanPost}) =>
      ChatRoom(isGroup: isGroup, readOnly: readOnly, isSupervisor: isSupervisor, onlySupervisorCanPost: onlySupervisorCanPost ?? this.onlySupervisorCanPost, mutedUntil: mutedUntil);

  @override
  List<Object?> get props => [isGroup, readOnly, isSupervisor, onlySupervisorCanPost, mutedUntil];
}
