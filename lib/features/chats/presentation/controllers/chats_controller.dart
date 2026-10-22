import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/api_error_text.dart';
import '../../../../core/l10n/common_text.dart';
import '../../../../core/l10n/tx.dart';
import '../../../../core/utils/app_launcher.dart';
import '../../../../core/widgets/busy_overlay.dart';
import '../../data/repositories/server_chat_repository.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation_summary.dart';
import '../../domain/repositories/chat_repository.dart';
import '../cubits/chats_list_cubit.dart';
import '../cubits/conversation_cubit.dart';
import '../l10n/chats_text.dart';
import '../pages/chats_list_screen.dart';
import '../pages/conversation_screen.dart';

// -------------------------------------------------------------
// التنقل بالدردشات (بروتوتايب Figma): تبويب "الدردشات" → قائمة المحادثات → المحادثة
// كله من السيرفر (ServerChatRepository): دردشة المجموعة + المحادثات الفردية بين المعتمر ومشرفه
// المحادثة مع فرد من العائلة على الجهاز (LocalChatRepository) — السيرفر بيسمح بالفردية بين المعتمر ومشرفه بس
// -------------------------------------------------------------
class ChatsController {
  // مصادر البيانات — الاختبارات بتبدّلها
  /// تبويب الدردشات: المجموعة + الفردية
  static ChatRepository Function() groupChats = ServerChatRepository.new;

  /// محادثة فردية (مع المشرف من مركز المساعدة، أو مع معتمر من صفحة المشرف)
  static ChatRepository Function() chatRepository = ServerChatRepository.new;

  static void showMessage(BuildContext context, Tx text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text()), duration: const Duration(milliseconds: 1600)));
  }

  /// صفحة تبويب الدردشات (مع الـ Cubit تبعها)
  static Widget listPage() => BlocProvider(create: (_) => ChatsListCubit(groupChats())..start(), child: const ChatsListScreen());

  /// قائمة المحادثات → المحادثة (عدد غير المقروء بيصير صفر، وبعد الرجوع بتتحدّث القائمة)
  static Future<void> openConversation(BuildContext context, ConversationSummary conversation) async {
    final list = context.read<ChatsListCubit>();
    list.opened(conversation.id);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ConversationCubit(groupChats(), conversation.id)..start(),
          child: ConversationScreen(title: conversation.title, photoUrl: conversation.photoUrl, isGroup: conversation.isGroup),
        ),
      ),
    );
    if (!list.isClosed) list.closed();
  }

  /// الضغط المطوّل على صف بقائمة المحادثات: تثبيت/إلغاء التثبيت، وتعليم كمقروءة
  static Future<void> conversationOptions(BuildContext context, ConversationSummary conversation) async {
    final list = context.read<ChatsListCubit>();
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(conversation.isPinned ? Icons.push_pin_outlined : Icons.push_pin, color: const Color(0xFF1F3B2E)),
              title: Text(conversation.isPinned ? ChatsText.unpin() : ChatsText.pin(), style: const TextStyle(fontFamily: 'NotoSansArabic', fontSize: 15)),
              onTap: () => Navigator.pop(ctx, 'pin'),
            ),
            if (conversation.unreadCount > 0)
              ListTile(
                leading: const Icon(Icons.mark_chat_read_outlined, color: Color(0xFF1F3B2E)),
                title: Text(ChatsText.markRead(), style: const TextStyle(fontFamily: 'NotoSansArabic', fontSize: 15)),
                onTap: () => Navigator.pop(ctx, 'read'),
              ),
          ],
        ),
      ),
    );
    if (choice == 'pin') await list.togglePin(conversation);
    if (choice == 'read') await list.markRead(conversation);
  }

  /// فتح محادثة من أي مكان (قائمة دردشات المشرف، دردشة مجموعة الشركة قراءة بس) — [repository] null = السيرفر
  static Future<void> openRoom(BuildContext context, {required String id, required String title, bool isGroup = false, String? photoUrl, ChatRepository? repository}) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ConversationCubit(repository ?? chatRepository(), id)..start(),
          child: ConversationScreen(title: title, photoUrl: photoUrl, isGroup: isGroup),
        ),
      ),
    );
  }

  /// دردشة مجموعة من حساب الشركة (قراءة بس)
  static Future<void> openCompanyGroupChat(BuildContext context, {required String groupId, required String title}) =>
      openRoom(context, id: groupId, title: title, isGroup: true, repository: ServerChatRepository.companyReader(groupId));

  /// محادثة فردية مع شخص (فرد من العائلة مثلاً): السيرفر بيرجّع محادثتنا (أو بينشئها) وبتنفتح
  /// [repository]: مصدر غير السيرفر (مثلاً المحادثات على الجهاز للأقسام المفصولة مؤقتاً عن السيرفر)
  static Future<void> openDirect(BuildContext context, {required String userId, required String name, String? photoUrl, ChatRepository? repository}) async {
    final repo = repository ?? chatRepository();
    final ConversationSummary? started;
    try {
      started = await BusyOverlay.run(context, () => repo.startDirect(userId));
    } catch (error) {
      await repo.dispose();
      if (context.mounted) showMessage(context, ApiErrorText.of(error));
      return;
    }
    if (started == null || !context.mounted) {
      await repo.dispose();
      return;
    }
    final conversation = started;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ConversationCubit(repo, conversation.id)..start(),
          child: ConversationScreen(title: conversation.title.isEmpty ? name : conversation.title, photoUrl: conversation.photoUrl ?? photoUrl),
        ),
      ),
    );
  }

  /// فقاعة الموقع → الخريطة
  static Future<void> openLocation(BuildContext context, ChatMessage message) async {
    final opened = await AppLauncher.openMap(message.location!);
    if (!opened && context.mounted) showMessage(context, ChatsText.mapFailed);
  }

  /// الميكروفون: الرسائل الصوتية لسا مش مدعومة
  static void voiceSoon(BuildContext context) => showMessage(context, CommonText.comingSoon);
}
