import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_chevron.dart';
import '../../domain/entities/conversation_summary.dart';
import '../l10n/chats_text.dart';
import 'chat_avatar.dart';
import 'chats_colors.dart';
import 'pin_icon.dart';
import 'unread_badge.dart';

// -------------------------------------------------------------
// صف محادثة (Figma "_Messages-threadRow" 343×76 من x45 — كل 82) — الأرقام نسبةً لأعلى الصف:
// الصورة 45 من x316.5 (+15) — الاسم (#1F3B2E) وآخر رسالة (أسود) طرفهم x305
// الوقت (#3C3C43 60%) طرفه x133 و"<" قبله — والمثبّتة: 📌 + عدد غير المقروء تحت الوقت
// فاصل 0.5 تحت الصف (x45..304)
// -------------------------------------------------------------
class ChatThreadRow extends StatelessWidget {
  final FigmaCanvas c;
  final ConversationSummary conversation;
  final String time;
  final VoidCallback onTap;

  const ChatThreadRow({super.key, required this.c, required this.conversation, required this.time, required this.onTap});

  static const height = 76.0;
  static const pitch = 82.0;

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    final t = conversation;
    final last = t.lastMessage;
    final preview = last == null ? '' : (last.isLocation && (last.text ?? '').isEmpty ? ChatsText.location() : last.text ?? '');
    TextStyle style(double size, double weight, Color color) => c.style(size, weight, color, lineHeight: null, letterSpacing: 0);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.rect(
          left: 316.5,
          top: 15,
          width: 45,
          height: 45,
          child: Center(
            child: ChatAvatar(url: t.photoUrl, size: s.x(45), group: t.isGroup),
          ),
        ),
        c.text(t.title, left: 150, top: 8, width: 155, height: 22, dy: 0, style: style(15, FigmaWeight.sfBold, ChatsColors.green)),
        c.text(preview, left: 95, top: 29, width: 206.5, height: 24, dy: 0, style: style(14, FigmaWeight.sfRegular, Colors.black)),
        // الوقت لاتيني ("9:12 AM") معزول LTR حتى ما ينقلب جوّا السطر العربي
        c.text(
          String.fromCharCode(0x2066) + time + String.fromCharCode(0x2069),
          left: 73,
          top: 9.5,
          width: 60,
          height: 18,
          dy: 0,
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: s.x(14), height: 1.2, color: ChatsColors.time),
        ),
        c.rect(
          left: 62,
          top: 15,
          width: 4.5,
          height: 8.5,
          child: IgnorePointer(
            child: Center(
              child: FigmaChevron(width: s.x(4.5), height: s.x(8.5), stroke: s.x(2), color: Colors.black, pointsToEnd: true),
            ),
          ),
        ),
        if (t.isPinned)
          c.rect(
            left: 50,
            top: 36.5,
            width: 11,
            height: 22,
            child: IgnorePointer(
              child: PinIcon(width: s.x(11), height: s.y(22)),
            ),
          ),
        if (t.unreadCount > 0)
          c.rect(
            left: 67.5,
            top: 39,
            width: 40,
            height: 20,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: UnreadBadge(s: s, count: t.unreadCount),
            ),
          ),
        c.box(left: 45, top: height - 0.25, width: 259, height: 0.5, color: ChatsColors.separator),
        c.tapArea(left: 16, top: 0, width: 361, height: height, onTap: onTap),
      ],
    );
  }
}
