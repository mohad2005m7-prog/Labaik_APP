import '../../../../core/utils/geo_utils.dart';
import '../entities/chat_message.dart';
import '../entities/chat_room.dart';
import '../entities/conversation_summary.dart';

// -------------------------------------------------------------
// المحادثات (رسائل فعلية عبر السيرفر) — نفس المحادثة مع المشرف بتطلع بمركز المساعدة وبالدردشات
// -------------------------------------------------------------
abstract class ChatRepository {
  /// قائمة محادثات المستخدم (من السيرفر)
  Future<List<ConversationSummary>> conversations();

  /// آخر قائمة محفوظة على الجهاز (بتطلع فوراً)
  Future<List<ConversationSummary>> cachedConversations();

  /// الرسائل المحفوظة على الجهاز من آخر مرة (بتطلع فوراً قبل ما يرد السيرفر)
  Future<List<ChatMessage>> cached(String conversationId);

  Future<void> saveCache(String conversationId, List<ChatMessage> messages);

  /// الرسائل من السيرفر — [afterId]: بس الأحدث من هالرسالة
  Future<List<ChatMessage>> fetch(String conversationId, {String? afterId});

  /// إرسال نص أو موقع — بيرجع الرسالة زي ما خزّنها السيرفر
  Future<ChatMessage> send(String conversationId, {required String clientId, String? text, GeoPoint? location});

  /// محادثة فردية مع شخص (من أفراد العائلة) — السيرفر بينشئها لو مش موجودة
  Future<ConversationSummary> startDirect(String userId);

  /// تعليم رسائل المحادثة كمقروءة (بتختفي الدايرة الخضرا)
  Future<void> markRead(String conversationId);

  /// الرسائل الجديدة لحظة وصولها (SignalR) — [conversationId] = null: من كل المحادثات (للقائمة)
  Stream<ChatMessage> incoming([String? conversationId]);

  /// صلاحياتي بالمحادثة (أكتب؟ مكتوم؟ مشرف؟ قراءة بس؟)
  Future<ChatRoom> room(String conversationId);

  /// حذف رسالة (صاحبها، أو مشرف المجموعة لأي رسالة بالمجموعة)
  Future<void> deleteMessage(String conversationId, String messageId);

  /// أرقام الرسائل المحذوفة لحظة حذفها (SignalR "MessageDeleted")
  Stream<String> deletedMessages([String? conversationId]);

  /// المشرف: كتم معتمر بالمجموعة [minutes] دقيقة (0 = فك الكتم، لحد 7 أيام)
  Future<void> mute(String conversationId, String userId, {required int minutes});

  /// المشرف: الكتابة بالمجموعة للمشرف بس
  Future<void> setOnlySupervisorCanPost(String conversationId, bool value);

  /// الاتصال اللحظي شغّال؟ (لو لا، الشاشة بتتحدّث كل كم ثانية من الـ REST)
  bool get isLive;

  Future<void> dispose();
}
