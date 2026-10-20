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
import '../cubits/conversation_cubit.dart';
import '../widgets/chat_avatar.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chats_colors.dart';
import '../widgets/conversation_input_bar.dart';

// -------------------------------------------------------------
// "المحادثة الفردية" (Figma 111:7045) — من قائمة المحادثات:
// الهيدر: ">" + صورة المحادثة 45 + اسمها — فاصل الوقت — الرسائل (الطرف التاني يسار رمادي، رسائلي يمين أخضر — كل وحدة مع صورة صاحبها)
// خانة الكتابة تحت (فوق الكيبورد بـ 16 زي Figma)
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
                      );
                    },
                  ),
                ),
                ConversationInputBar(s: s, onSend: _cubit.sendText, onMic: () => ChatsController.voiceSoon(context)),
                SizedBox(height: s.y(16)),
              ],
            ),
          ),
        ),
      ),
    );
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
      c.text(widget.title, left: 16, top: 59, width: 273, height: 45, dy: 0, style: c.style(19, FigmaWeight.sfBold, Colors.black, lineHeight: null, letterSpacing: 0)),
      figmaBackChevron(c, context, left: 358, top: 71.5, width: 8.5, height: 17, stroke: 2, color: Colors.black),
    ];
  }
}
