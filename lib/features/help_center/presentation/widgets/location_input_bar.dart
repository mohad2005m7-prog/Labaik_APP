import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/content_direction.dart';
import '../../../../core/utils/design_scale.dart';
import '../l10n/supervisor_chat_text.dart';
import 'help_colors.dart';
import 'send_outline_icon.dart';

// -------------------------------------------------------------
// شريط الكتابة بالمحادثة (Figma "Group 36804" 343×55 من x26 — #4C7A75 10% radius 10):
// 📍 + "إرسال موقعي الحالي" (الـ placeholder) — وزر الإرسال: دايرة #1F3B2E 43.98 من x31 فيها طيارة بخط
// الإرسال والخانة فاضية بيبعت الموقع الحالي (زي ما بيقول الـ placeholder) — وفيها نص بيبعت النص
// الضغط على 📍 كمان بيبعت الموقع
// -------------------------------------------------------------
class LocationInputBar extends StatefulWidget {
  final ValueChanged<String> onSendText;
  final VoidCallback onSendLocation;
  final bool locating;

  /// مقاس الشاشة من فوق الـ Scaffold (جوّا SafeArea الحساب بيطلع غلط)
  final DesignScale s;

  const LocationInputBar({super.key, required this.s, required this.onSendText, required this.onSendLocation, required this.locating});

  static const height = 55.0;

  @override
  State<LocationInputBar> createState() => _LocationInputBarState();
}

class _LocationInputBarState extends State<LocationInputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      widget.onSendLocation();
      return;
    }
    widget.onSendText(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final style = figmaText(s, size: 19.5, weight: FigmaWeight.sfRegular, color: Colors.black, lineHeight: null, letterSpacing: 0);
    return Container(
      height: s.y(LocationInputBar.height),
      margin: EdgeInsetsDirectional.only(start: s.x(24), end: s.x(26)),
      decoration: BoxDecoration(color: HelpColors.cardFill, borderRadius: BorderRadius.circular(s.x(10))),
      // المحتوى بـ Figma أوطى من نص الشريط بـ 3.5
      padding: EdgeInsets.only(top: s.y(7)),
      child: Row(
        children: [
          // 📍 (بداية الشريط: 23 من الطرف — صندوقه 16 وبعده 7.5 للنص)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.locating ? null : widget.onSendLocation,
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: s.x(23), end: s.x(7.5)),
              child: SizedBox(
                width: s.x(16),
                child: Center(
                  child: Text('📍', style: TextStyle(fontSize: s.x(15), height: 1)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) => TextField(
                controller: _controller,
                textDirection: contentDirection(value.text),
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: style,
                cursorColor: HelpColors.green,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: widget.locating ? SupervisorChatText.locating() : SupervisorChatText.hint(),
                  hintStyle: style.copyWith(color: HelpColors.inputHint),
                  hintMaxLines: 1,
                ),
              ),
            ),
          ),
          SizedBox(width: s.x(10)),
          // زر الإرسال (طرف الشريط)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.locating ? null : _send,
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: s.x(5)),
              child: Container(
                width: s.x(43.98),
                height: s.x(43.98),
                decoration: const BoxDecoration(color: HelpColors.green, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: widget.locating
                    ? SizedBox.square(
                        dimension: s.x(18),
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : SendOutlineIcon(size: s.x(15.5), color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
