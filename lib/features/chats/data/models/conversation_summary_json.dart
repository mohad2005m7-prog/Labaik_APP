import '../../../../core/utils/json_fields.dart';
import '../../domain/entities/conversation_summary.dart';
import 'chat_message_json.dart';

// -------------------------------------------------------------
// ConversationDto من السيرفر (camelCase أو PascalCase):
// { "id", "title", "photoUrl", "isGroup", "isPinned", "unreadCount", "lastMessage": MessageDto | null }
// -------------------------------------------------------------
extension ConversationSummaryJson on ConversationSummary {
  static ConversationSummary fromJson(Map<String, dynamic> json, {String? myUserId}) {
    String? text(String name) {
      final value = json.field(name)?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    final last = json.field('lastMessage');
    return ConversationSummary(
      id: json.requireString('id'),
      title: text('title') ?? '',
      photoUrl: text('photoUrl'),
      isGroup: json.field('isGroup') == true,
      isPinned: json.field('isPinned') == true,
      unreadCount: json.optionalInt('unreadCount') ?? 0,
      lastMessage: last is Map<String, dynamic> ? ChatMessageJson.fromJson(last, myUserId: myUserId) : null,
    );
  }

  /// للكاش المحلي
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'photoUrl': photoUrl, 'isGroup': isGroup, 'isPinned': isPinned, 'unreadCount': unreadCount, 'lastMessage': lastMessage?.toJson()};
}
