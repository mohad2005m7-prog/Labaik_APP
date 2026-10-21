import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/api_error_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_back_chevron.dart';
import '../../../pilgrim_account/presentation/controllers/pilgrim_account_controller.dart';
import '../controllers/chats_controller.dart';
import '../../domain/entities/chat_message.dart';
import '../cubits/conversation_cubit.dart';
import '../l10n/conversation_text.dart';
import '../widgets/chat_avatar.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chats_colors.dart';
import '../widgets/conversation_input_bar.dart';

// -------------------------------------------------------------
// "المحادثة الفردية" (Figma 111:7045) — من قائمة المحادثات:
// الهيدر: ">" + صورة المحادثة 45 + اسمها — فاصل الوقت — الرسائل (الطرف التاني يسار رمادي، رسائلي يمين أخضر — كل وحدة مع صورة صاحبها)
// خانة الكتابة تحت (فوق الكيبورد بـ 16 زي Figma) — ولو ما بقدر أكتب (قراءة بس / مكتوم / للمشرف بس) سطر بيوضّح السبب
// الضغط المطوّل على فقاعة: حذفها (رسالتي أو المشرف) وكتم صاحبها (المشرف) — والمشرف عنده قفل "الكتابة للمشرف فقط" بالهيدر
// -------------------------------------------------------------
class ConversationScreen extends StatefulWidget {
  final String title;
  final String? photoUrl;
  final bool isGroup;

  const ConversationScreen({super.key, required this.title, this.photoUrl, this.isGroup = false});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _scroll = ScrollController();
  final _openedAt = DateTime.now();
  int _shown = 0;
  String? _myPhoto;

  ConversationCubit get _cubit => context.read<ConversationCubit>();

  @override
  void initState() {
    super.initState();
    PilgrimAccountController.savedPhoto().then((photo) {
      if (mounted && photo != null) setState(() => _myPhoto = photo);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// أول ما توصل رسالة جديدة بننزل لآخر المحادثة
  void _followNewMessages(int count) {
    if (count == _shown) return;
    _shown = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    final c = FigmaCanvas(s);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                SizedBox(
                  height: s.y(104 - FigmaCanvas.statusBar),
                  child: Stack(clipBehavior: Clip.none, children: _header(c)),
                ),
                Expanded(
                  child: BlocBuilder<ConversationCubit, ConversationState>(
                    builder: (context, state) {
                      _followNewMessages(state.messages.length);
                      final error = state.error;
                      return ChatMessageList(
                        s: s,
                        messages: state.messages,
                        controller: _scroll,
                        openedAt: _openedAt,
                        // فاصل الوقت (y125) وأول فقاعة (y161)
                        topPadding: 21.5,
                        firstGap: 161 - 138,
                        myPhoto: _myPhoto,
                        otherPhotoUrl: widget.isGroup ? null : widget.photoUrl,
                        footer: error == null || state.messages.isNotEmpty
                            ? null
                            : Text(
                                ApiErrorText.of(error)(),
                                textAlign: TextAlign.center,
                                style: figmaText(s, size: 12, weight: FigmaWeight.sfRegular, color: ChatsColors.time, lineHeight: null, letterSpacing: 0),
                              ),
                        onRetry: _cubit.retry,
                        onOpenLocation: (message) => ChatsController.openLocation(context, message),
                        onLongPress: (message) => _actions(message, state),
                      );
                    },
                  ),
                ),
                BlocBuilder<ConversationCubit, ConversationState>(
                  buildWhen: (a, b) => a.room != b.room,
                  builder: (context, state) => state.room.canPost
                      ? ConversationInputBar(s: s, onSend: _cubit.sendText, onMic: () => ChatsController.voiceSoon(context))
                      : _blockedNote(s, state),
                ),
                SizedBox(height: s.y(16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ليش ما بقدر أكتب (مكان خانة الكتابة)
  Widget _blockedNote(DesignScale s, ConversationState state) {
    final room = state.room;
    final until = room.mutedUntil;
    final text = room.readOnly
        ? ConversationText.readOnly()
        : room.isMuted && until != null
            ? ConversationText.mutedUntil('${until.day}/${until.month} ${until.hour.toString().padLeft(2, '0')}:${until.minute.toString().padLeft(2, '0')}')
            : ConversationText.supervisorOnly();
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: s.x(16)),
      padding: EdgeInsets.symmetric(horizontal: s.x(12), vertical: s.y(10)),
      decoration: BoxDecoration(color: ChatsColors.bubbleIn, borderRadius: BorderRadius.circular(s.x(12))),
      child: Text(text, textAlign: TextAlign.center, style: figmaText(s, size: 13, weight: FigmaWeight.sfRegular, color: ChatsColors.time, lineHeight: null, letterSpacing: 0)),
    );
  }

  /// الضغط المطوّل: حذف الرسالة / كتم صاحبها (حسب صلاحياتي)
  Future<void> _actions(ChatMessage message, ConversationState state) async {
    final canDelete = state.canDelete(message);
    final canMute = state.canMute(message);
    if (!canDelete && !canMute) return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canDelete) _action(ctx, 'delete', Icons.delete_outline_rounded, ConversationText.deleteMessage(), danger: true),
            if (canMute) ...[
              _action(ctx, '60', Icons.volume_off_outlined, ConversationText.mute1h()),
              _action(ctx, '1440', Icons.volume_off_outlined, ConversationText.mute1d()),
              _action(ctx, '0', Icons.volume_up_outlined, ConversationText.unmute()),
            ],
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    try {
      if (choice == 'delete') {
        await _cubit.delete(message);
        if (mounted) ChatsController.showMessage(context, ConversationText.deleted);
      } else {
        final minutes = int.parse(choice);
        await _cubit.mute(message, minutes: minutes);
        if (mounted) ChatsController.showMessage(context, minutes == 0 ? ConversationText.unmuted : ConversationText.muted);
      }
    } catch (_) {
      if (mounted) ChatsController.showMessage(context, ConversationText.actionFailed);
    }
  }

  Widget _action(BuildContext ctx, String value, IconData icon, String label, {bool danger = false}) {
    final color = danger ? const Color(0xFFD32F2F) : ChatsColors.green;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 15, color: color)),
      onTap: () => Navigator.pop(ctx, value),
    );
  }

  Future<void> _toggleLock(bool value) async {
    try {
      await _cubit.setOnlySupervisorCanPost(value);
      if (mounted) ChatsController.showMessage(context, value ? ConversationText.lockOn : ConversationText.lockOff);
    } catch (_) {
      if (mounted) ChatsController.showMessage(context, ConversationText.actionFailed);
    }
  }

  // "Frame 2147227395" (x211 → 129×45): الاسم + 6 + الصورة 45 — والسهم ">" بـ "Frame 38" (x340)
  List<Widget> _header(FigmaCanvas c) {
    return [
      c.rect(
        left: 295,
        top: 59,
        width: 45,
        height: 45,
        child: Center(
          child: ChatAvatar(url: widget.photoUrl, size: c.s.x(45), group: widget.isGroup),
        ),
      ),
      c.text(widget.title, left: 52, top: 59, width: 237, height: 45, dy: 0, style: c.style(19, FigmaWeight.sfBold, Colors.black, lineHeight: null, letterSpacing: 0)),
      // المشرف بالمجموعة: قفل "الكتابة للمشرف فقط"
      c.rect(
        left: 8,
        top: 61.5,
        width: 40,
        height: 40,
        child: BlocBuilder<ConversationCubit, ConversationState>(
          buildWhen: (a, b) => a.room != b.room,
          builder: (context, state) {
            final room = state.room;
            if (!room.isGroup || !room.isSupervisor) return const SizedBox.shrink();
            return IconButton(
              tooltip: ConversationText.lockTooltip(),
              padding: EdgeInsets.zero,
              onPressed: () => _toggleLock(!room.onlySupervisorCanPost),
              icon: Icon(room.onlySupervisorCanPost ? Icons.lock_rounded : Icons.lock_open_rounded, size: c.s.x(22), color: ChatsColors.green),
            );
          },
        ),
      ),
      figmaBackChevron(c, context, left: 358, top: 71.5, width: 8.5, height: 17, stroke: 2, color: Colors.black),
    ];
  }
}
