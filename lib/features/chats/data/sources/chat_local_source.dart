import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/data/account_registry.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation_summary.dart';
import '../models/chat_message_json.dart';
import '../models/conversation_summary_json.dart';

// -------------------------------------------------------------
// نسخة على الجهاز من آخر بيانات وصلت من السيرفر — كل حساب لحاله (بإيميله):
//   chats_list:<email>                       → قائمة المحادثات
//   help_chat:<email>:<conversationId>       → آخر 200 رسالة بالمحادثة
// -------------------------------------------------------------
class ChatLocalSource {
  static const maxMessages = 200;

  Future<String> _account() async => await AccountRegistry.currentEmail() ?? '';

  Future<List<ConversationSummary>> conversations() async {
    final raw = (await SharedPreferences.getInstance()).getString('chats_list:${await _account()}');
    if (raw == null) return const [];
    try {
      return [for (final item in (jsonDecode(raw) as List).whereType<Map<String, dynamic>>()) ConversationSummaryJson.fromJson(item)];
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveConversations(List<ConversationSummary> list) async {
    await (await SharedPreferences.getInstance()).setString('chats_list:${await _account()}', jsonEncode([for (final c in list) c.toJson()]));
  }

  Future<List<ChatMessage>> messages(String conversationId) async {
    final raw = (await SharedPreferences.getInstance()).getString('help_chat:${await _account()}:$conversationId');
    if (raw == null) return const [];
    try {
      return [for (final item in (jsonDecode(raw) as List).whereType<Map<String, dynamic>>()) ChatMessageJson.fromJson(item)];
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveMessages(String conversationId, List<ChatMessage> messages) async {
    final recent = messages.length > maxMessages ? messages.sublist(messages.length - maxMessages) : messages;
    await (await SharedPreferences.getInstance()).setString('help_chat:${await _account()}:$conversationId', jsonEncode([for (final m in recent) m.toJson()]));
  }
}
