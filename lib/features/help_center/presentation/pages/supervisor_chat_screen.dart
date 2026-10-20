import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_back_chevron.dart';
import '../../../chats/presentation/controllers/chats_controller.dart';
import '../../../chats/presentation/cubits/conversation_cubit.dart';
import '../../../chats/presentation/widgets/chat_avatar.dart';
import '../../../chats/presentation/widgets/chat_bubble.dart';
import '../../../chats/presentation/widgets/chat_message_list.dart';
import '../../../pilgrim_account/presentation/controllers/pilgrim_account_controller.dart';
import '../../domain/entities/supervisor_contact.dart';
import '../controllers/help_location.dart';
import '../l10n/help_messages_text.dart';
import '../l10n/supervisor_chat_text.dart';
import '../widgets/help_colors.dart';
import '../widgets/location_input_bar.dart';

// -------------------------------------------------------------
// "المحادثة الفردية" مع المشرف من مركز المساعدة (Figma 372:7286):
// الهيدر: ">" + صورة المشرف 34 + اسمه — فاصل الوقت — رسالة المشرف الأولى (من التصميم، صورته بنص الفقاعة)
// — الرسائل الفعلية (نفس محادثة المشرف بالدردشات — فقاعات 111:7045) — شريط "إرسال موقعي الحالي" تحت (فوق الكيبورد بـ 15)
// -------------------------------------------------------------
class SupervisorChatScreen extends StatefulWidget {
  final SupervisorContact supervisor;

  const SupervisorChatScreen({super.key, required this.supervisor});

  @override
  State<SupervisorChatScreen> createState() => _SupervisorChatScreenState();
}

class _SupervisorChatScreenState extends State<SupervisorChatScreen> {
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

  Future<void> _sendLocation() async {
    if (_cubit.state.locating) return;
    _cubit.setLocating(true);
    final point = await HelpLocation.current(context);
    if (!mounted) return;
    _cubit.setLocating(false);
    if (point != null) await _cubit.sendLocation(point);
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
    final supervisor = widget.supervisor;
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
                        // فاصل الوقت (y125) ورسالة المشرف الأولى (y170)
                        topPadding: 21.5,
                        firstGap: 170 - 138,
                        header: [
                          ChatBubble(
                            s: s,
                            fromMe: false,
                            layout: ChatBubbleLayout.helpGreeting,
                            avatar: ChatAvatar(url: supervisor.photoUrl, size: s.x(ChatBubbleLayout.avatarSize)),
                            text: SupervisorChatText.greeting(),
                            fullWidth: true,
                          ),
                        ],
                        footer: error == null || state.messages.isNotEmpty
                            ? null
                            : Padding(
                                padding: EdgeInsets.only(top: s.y(16)),
                                child: Text(
                                  HelpMessagesText.forError(error)(),
                                  textAlign: TextAlign.center,
                                  style: figmaText(s, size: 12, weight: FigmaWeight.sfRegular, color: HelpColors.grey, lineHeight: null, letterSpacing: 0),
                                ),
                              ),
                        myPhoto: _myPhoto,
                        otherPhotoUrl: supervisor.photoUrl,
                        onRetry: _cubit.retry,
                        onOpenLocation: (message) => ChatsController.openLocation(context, message),
                      );
                    },
                  ),
                ),
                BlocBuilder<ConversationCubit, ConversationState>(
                  buildWhen: (a, b) => a.locating != b.locating,
                  builder: (context, state) => LocationInputBar(s: s, locating: state.locating, onSendText: _cubit.sendText, onSendLocation: _sendLocation),
                ),
                SizedBox(height: s.y(15)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // "Frame 2147227395": الاسم (SF Compact 790) + 6 + الصورة 34×34 — والسهم ">" بـ "Frame 38" (x340)
  List<Widget> _header(FigmaCanvas c) {
    return [
      c.rect(
        left: 301,
        top: 59,
        width: 34,
        height: 34,
        child: Center(
          child: ChatAvatar(url: widget.supervisor.photoUrl, size: c.s.x(34)),
        ),
      ),
      c.text(widget.supervisor.name, left: 16, top: 60, width: 276.5, height: 34, dy: 0, style: c.style(19, FigmaWeight.sfBold, Colors.black, lineHeight: null, letterSpacing: 0)),
      figmaBackChevron(c, context, left: 357.5, top: 71.5, width: 8.5, height: 17, stroke: 2, color: Colors.black),
    ];
  }
}
