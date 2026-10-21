import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../domain/entities/chat_message.dart';
import '../l10n/conversation_text.dart';
import 'chat_avatar.dart';
import 'chat_bubble.dart';
import 'chat_location_content.dart';
import 'chat_time_label.dart';

// -------------------------------------------------------------
// رسائل المحادثة (Figma 111:7045): فاصل الوقت فوق ("Yesterday 9:41" — y125)، بعده الفقاعات
// - صورة المرسل بتطلع على آخر رسالة من سلسلة رسائل نفس الشخص (زي iOS) — والفقاعة اللي بعدها بعد 8 من الصورة
// - رسائل نفس الشخص ورا بعض: 4 بينهم — وفرق ساعة أو أكتر: فاصل وقت جديد
// - "لم تُرسل" تحت رسالتي اللي ما وصلت (الضغط بيعيد الإرسال) — والموقع بينفتح على الخريطة
// [header]: محتوى ثابت تحت فاصل الوقت (رسالة المشرف الأولى بمركز المساعدة)
// -------------------------------------------------------------
class ChatMessageList extends StatelessWidget {
  final DesignScale s;
  final List<ChatMessage> messages;
  final ScrollController controller;

  /// وقت الفاصل الأول لو المحادثة فاضية (وقت فتحها)
  final DateTime openedAt;

  /// من أعلى القائمة لأعلى صندوق فاصل الوقت، ومن تحته لأول فقاعة (أرقام Figma)
  final double topPadding;
  final double firstGap;
  final List<Widget> header;
  final Widget? footer;

  /// صورتي (من ملفي الشخصي على الجهاز) — وصورة الطرف التاني لو الرسالة ما فيها صورة مرسل
  final String? myPhoto;
  final String? otherPhotoUrl;

  final ValueChanged<ChatMessage> onRetry;
  final ValueChanged<ChatMessage> onOpenLocation;

  /// الضغط المطوّل على فقاعة (حذف / كتم) — null = ما في
  final ValueChanged<ChatMessage>? onLongPress;

  const ChatMessageList({
    super.key,
    required this.s,
    required this.messages,
    required this.controller,
    required this.openedAt,
    required this.topPadding,
    required this.firstGap,
    required this.onRetry,
    required this.onOpenLocation,
    this.header = const [],
    this.footer,
    this.myPhoto,
    this.otherPhotoUrl,
    this.onLongPress,
  });

  static bool _sameSender(ChatMessage a, ChatMessage b) => a.fromMe == b.fromMe && (a.fromMe || a.senderName == b.senderName);
  static bool _newTime(ChatMessage previous, ChatMessage next) => next.sentAt.difference(previous.sentAt).inMinutes >= 60;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      Center(
        child: ChatTimeLabel(s: s, time: messages.isEmpty ? openedAt : messages.first.sentAt),
      ),
      SizedBox(height: s.y(firstGap)),
      ...header,
      ?footer,
    ];
    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      final previous = i > 0 ? messages[i - 1] : null;
      final next = i + 1 < messages.length ? messages[i + 1] : null;
      if (previous != null && _newTime(previous, message)) {
        items
          ..add(SizedBox(height: s.y(24)))
          ..add(
            Center(
              child: ChatTimeLabel(s: s, time: message.sentAt),
            ),
          )
          ..add(SizedBox(height: s.y(16)));
      } else if (previous != null || header.isNotEmpty) {
        final grouped = previous != null && _sameSender(previous, message);
        items.add(SizedBox(height: s.y(grouped ? 4 : 8)));
      }
      // الصورة على آخر رسالة من السلسلة
      final last = next == null || !_sameSender(message, next) || _newTime(message, next);
      items.add(_bubble(message, showAvatar: last));
    }
    return ListView(
      controller: controller,
      padding: EdgeInsets.only(top: s.y(topPadding), bottom: s.y(16)),
      children: items,
    );
  }

  Widget _bubble(ChatMessage message, {required bool showAvatar}) {
    final failed = message.status == ChatMessageStatus.failed;
    final size = s.x(ChatBubbleLayout.avatarSize);
    final bubble = ChatBubble(
      s: s,
      fromMe: message.fromMe,
      layout: message.fromMe ? ChatBubbleLayout.outgoing : ChatBubbleLayout.incoming,
      avatar: !showAvatar
          ? null
          : message.fromMe
          ? ChatAvatar(file: myPhoto, size: size)
          : ChatAvatar(url: message.senderPhotoUrl ?? otherPhotoUrl, size: size),
      text: message.text,
      opacity: message.status == ChatMessageStatus.sending ? 0.6 : 1,
      onTap: failed
          ? () => onRetry(message)
          : message.isLocation
          ? () => onOpenLocation(message)
          : null,
      onLongPress: onLongPress == null || failed ? null : () => onLongPress!(message),
      child: message.isLocation ? ChatLocationContent(s: s, location: message.location!, fromMe: message.fromMe, note: message.text) : null,
    );
    if (!failed) return bubble;
    // "لم تُرسل" تحت فقاعتي (يمين باللغتين زي الفقاعة نفسها)
    return Column(
      children: [
        bubble,
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(top: s.y(4), right: s.x(ChatBubbleLayout.outgoing.avatarInset + ChatBubbleLayout.avatarSize + ChatBubbleLayout.outgoing.gap)),
            child: GestureDetector(
              onTap: () => onRetry(message),
              child: Text(
                ConversationText.notSent(),
                style: figmaText(s, size: 11, weight: FigmaWeight.sfRegular, color: const Color(0xFFD32F2F), lineHeight: null, letterSpacing: 0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
