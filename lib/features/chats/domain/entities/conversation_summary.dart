import 'package:equatable/equatable.dart';

import 'chat_message.dart';

// -------------------------------------------------------------
// صف بقائمة المحادثات: محادثة فردية (المشرف أو فرد) أو مجموعة
// [isPinned]: مثبّتة فوق (📌) — [unreadCount]: عدد الرسائل غير المقروءة (الدايرة الخضرا)
// [otherUserId]: الطرف التاني بالمحادثة الفردية (المشرف أو المعتمر)
// -------------------------------------------------------------
class ConversationSummary extends Equatable {
  final String id;
  final String title;
  final String? photoUrl;
  final bool isGroup;
  final bool isPinned;
  final int unreadCount;
  final ChatMessage? lastMessage;
  final String? otherUserId;

  const ConversationSummary({required this.id, required this.title, this.photoUrl, this.isGroup = false, this.isPinned = false, this.unreadCount = 0, this.lastMessage, this.otherUserId});

  DateTime? get updatedAt => lastMessage?.sentAt;

  ConversationSummary copyWith({int? unreadCount, ChatMessage? lastMessage, bool? isPinned}) =>
      ConversationSummary(id: id, title: title, photoUrl: photoUrl, isGroup: isGroup, isPinned: isPinned ?? this.isPinned, unreadCount: unreadCount ?? this.unreadCount, lastMessage: lastMessage ?? this.lastMessage, otherUserId: otherUserId);

  @override
  List<Object?> get props => [id, title, photoUrl, isGroup, isPinned, unreadCount, lastMessage, otherUserId];
}
