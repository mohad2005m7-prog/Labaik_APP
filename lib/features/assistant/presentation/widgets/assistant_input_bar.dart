import 'package:flutter/material.dart';

import '../../../../core/theme/figma_spaced_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/content_direction.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../l10n/assistant_text.dart';
import 'assistant_colors.dart';
import 'send_plane_icon.dart';

// -------------------------------------------------------------
// شريط كتابة السؤال ("Rectangle 127" — 362×61 #EEF2F2 radius 10 بدون ظل):
// "اكتب سؤالك هنا..." (SF Compact 457 14 #717171) وزر الإرسال (مربع #1F3B2E 29×29 radius 5 وطيارة بيضا)
// الضغط بأي مكان بالشريط بيفتح الكتابة
// -------------------------------------------------------------
class AssistantInputBar extends StatefulWidget {
  final FigmaCanvas c;
  final TextEditingController controller;
  final VoidCallback onSend;

  const AssistantInputBar({super.key, required this.c, required this.controller, required this.onSend});

  @override
  State<AssistantInputBar> createState() => _AssistantInputBarState();
}

class _AssistantInputBarState extends State<AssistantInputBar> {
  final _focus = FocusNode();

  // من بعد زر الإرسال (x70) لطرف صندوق النص بـ Figma (x369)
  static const _textWidth = 299.0;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    TextStyle style(Color color) => c.style(14, FigmaWeight.sfRegular, color, letterSpacing: 0);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.rect(
          left: 16,
          top: 757,
          width: 362,
          height: 61,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _focus.requestFocus,
            child: DecoratedBox(decoration: BoxDecoration(color: AssistantColors.cardFill, borderRadius: BorderRadius.circular(c.s.x(10)))),
          ),
        ),
        // صندوق النص بـ Figma 774..796 (طرفه عند 369) — بيبدأ بعد زر الإرسال
        c.rect(
          left: 369 - _textWidth,
          top: 774 + FigmaCanvas.baselineFix,
          width: _textWidth,
          height: 22,
          // اتجاه الكتابة حسب لغة اللي بينكتب
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, _) => TextField(
              controller: widget.controller,
              focusNode: _focus,
              textDirection: contentDirection(value.text),
              maxLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => widget.onSend(),
              style: style(Colors.black),
              cursorColor: AssistantColors.green,
              // الـ placeholder بنفس ضغط حروف Figma (letter spacing -0.408)
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hint: FigmaSpacedText(AssistantText.hint(), style: style(AssistantColors.grey), letterSpacing: c.s.x(-0.408), width: c.s.x(_textWidth), maxLines: 1),
              ),
            ),
          ),
        ),
        c.box(left: 35, top: 772, width: 29, height: 29, color: AssistantColors.green, radius: 5),
        c.rect(left: 39, top: 774, width: 23.05, height: 23.05, child: IgnorePointer(child: Center(child: SendPlaneIcon(size: c.s.x(23.05), color: Colors.white)))),
        // منطقة ضغط 44×44 حوالين الزر
        c.tapArea(left: 27, top: 764.5, width: 44, height: 44, onTap: widget.onSend),
      ],
    );
  }
}
