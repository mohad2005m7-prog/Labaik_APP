import 'package:flutter/material.dart';

import '../../../../core/utils/content_direction.dart';
import '../../../../core/utils/design_scale.dart';
import 'chats_colors.dart';

// -------------------------------------------------------------
// خانة البحث بقائمة المحادثات (Figma "SearchField" 361×48 — #D9D9D9 53% radius 10):
// العدسة يمين (حبرها 16×15.5) و"البحث" (#3C3C43 60%) قبلها — الكتابة بتفلتر القائمة
// -------------------------------------------------------------
class ChatSearchField extends StatefulWidget {
  final DesignScale s;
  final String hint;
  final ValueChanged<String> onChanged;

  const ChatSearchField({super.key, required this.s, required this.hint, required this.onChanged});

  @override
  State<ChatSearchField> createState() => _ChatSearchFieldState();
}

class _ChatSearchFieldState extends State<ChatSearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final style = TextStyle(fontFamily: 'NotoSansArabic', fontVariations: const [FontVariation('wght', 450)], fontSize: s.x(15), height: 1.2, color: Colors.black);
    return Container(
      decoration: BoxDecoration(color: ChatsColors.searchFill, borderRadius: BorderRadius.circular(s.x(10))),
      padding: EdgeInsetsDirectional.only(start: s.x(13.5), end: s.x(12)),
      child: Row(
        children: [
          // عدسة iOS (نفس أيقونة Figma)
          Image.asset('assets/images/supervisor/ic_search.png', width: s.x(16), height: s.x(16), color: ChatsColors.time, colorBlendMode: BlendMode.srcIn),
          SizedBox(width: s.x(7)),
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) => TextField(
                controller: _controller,
                textDirection: contentDirection(value.text),
                onChanged: widget.onChanged,
                style: style,
                cursorColor: ChatsColors.green,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: widget.hint,
                  hintStyle: style.copyWith(color: ChatsColors.time),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
