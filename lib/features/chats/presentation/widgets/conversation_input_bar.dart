import 'package:flutter/material.dart';

import '../../../../core/utils/content_direction.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../assistant/presentation/widgets/send_plane_icon.dart';
import '../l10n/conversation_text.dart';
import 'chats_colors.dart';
import 'mic_icon.dart';

// -------------------------------------------------------------
// خانة الكتابة بالمحادثة (Figma "_Messages-sendField" 387×36 من x1 — أبيض بحد #1F3B2E و radius 18):
// "iMessage" (placeholder iOS #3C3C43 60%) — الميكروفون — زر الإرسال (مربع #1F3B2E 27.5 radius 6 وطيارة بيضا)
// ترتيبها ثابت زي Figma باللغتين (الإرسال يمين) — والكتابة نفسها باتجاه لغتها
// [onMic]: الرسائل الصوتية لسا مش مدعومة
// -------------------------------------------------------------
class ConversationInputBar extends StatefulWidget {
  final DesignScale s;
  final ValueChanged<String> onSend;
  final VoidCallback onMic;

  const ConversationInputBar({super.key, required this.s, required this.onSend, required this.onMic});

  static const height = 36.0;

  @override
  State<ConversationInputBar> createState() => _ConversationInputBarState();
}

class _ConversationInputBarState extends State<ConversationInputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final style = TextStyle(fontFamily: 'NotoSansArabic', fontVariations: const [FontVariation('wght', 450)], fontSize: s.x(17), height: 1.25, color: Colors.black);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        constraints: BoxConstraints(minHeight: s.y(ConversationInputBar.height)),
        margin: EdgeInsets.only(left: s.x(1), right: s.x(5)),
        padding: EdgeInsets.only(left: s.x(12), right: s.x(12.5)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(s.x(18)),
          border: Border.all(color: ChatsColors.green, width: s.x(1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) => TextField(
                  controller: _controller,
                  textDirection: contentDirection(value.text) ?? TextDirection.ltr,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  style: style,
                  cursorColor: ChatsColors.green,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: s.y(5)),
                    hintText: ConversationText.hint(),
                    hintStyle: style.copyWith(color: ChatsColors.time, fontFamily: 'Poppins', fontVariations: const [], fontSize: s.x(15.6)),
                  ),
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onMic,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: s.x(6), vertical: s.y(8.25)),
                child: MicIcon(width: s.x(11.5), height: s.x(17.5), color: ChatsColors.time),
              ),
            ),
            SizedBox(width: s.x(6)),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _send,
              child: Container(
                width: s.x(27.5),
                height: s.x(27.5),
                decoration: BoxDecoration(color: ChatsColors.green, borderRadius: BorderRadius.circular(s.x(6))),
                alignment: Alignment.center,
                child: SendPlaneIcon(size: s.x(21), color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
