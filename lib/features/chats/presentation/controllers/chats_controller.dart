import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/api_error_text.dart';
import '../../../../core/l10n/common_text.dart';
import '../../../../core/l10n/tx.dart';
import '../../../../core/utils/app_launcher.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/group_chat_repository.dart';
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
// التبويب من السيرفر: محادثة مجموعتي (GroupChatRepository)
// المحادثات الفردية (مع المشرف من مركز المساعدة، أو مع فرد) لسا مش موجودة بالسيرفر (مؤجلة بالاتفاق)
// -------------------------------------------------------------
class ChatsController {
  // مصادر البيانات — الاختبارات بتبدّلها
  /// تبويب الدردشات: محادثة المجموعة
  static ChatRepository Function() groupChats = GroupChatRepository.new;

  /// المحادثات الفردية (/chats — docs/backend_pending.md)
  static ChatRepository Function() chatRepository = ChatRepositoryImpl.new;

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

  /// محادثة فردية مع شخص (فرد من العائلة مثلاً): السيرفر بيرجّع محادثتنا (أو بينشئها) وبتنفتح
  /// [repository]: مصدر غير السيرفر (مثلاً المحادثات على الجهاز للأقسام المفصولة مؤقتاً عن السيرفر)
  static Future<void> openDirect(BuildContext context, {required String userId, required String name, String? photoUrl, ChatRepository? repository}) async {
    final repo = repository ?? chatRepository();
    final ConversationSummary conversation;
    try {
      conversation = await repo.startDirect(userId);
    } catch (error) {
      await repo.dispose();
      if (context.mounted) showMessage(context, ApiErrorText.of(error));
      return;
    }
    if (!context.mounted) {
      await repo.dispose();
      return;
    }
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
