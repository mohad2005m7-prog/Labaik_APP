import 'package:flutter/material.dart';

import '../../../../core/utils/design_scale.dart';
import '../l10n/conversation_text.dart';
import 'chats_colors.dart';

// -------------------------------------------------------------
// فاصل الوقت بين الرسائل (Figma "✏️ Time": Poppins 11 #3C3C43 60% بنص الشاشة) — زي iOS:
// اليوم → "Today 9:41" — مبارح → "Yesterday 9:41" — هالأسبوع → "Mon 9:41" — أقدم → "12 Oct 2026 9:41"
// اسم اليوم Medium والوقت Regular
// -------------------------------------------------------------
class ChatTimeLabel extends StatelessWidget {
  final DateTime time;
  final DateTime? now;

  /// مقاس الشاشة من فوق الـ Scaffold (جوّا SafeArea الحساب بيطلع غلط)
  final DesignScale s;

  const ChatTimeLabel({super.key, required this.s, required this.time, this.now});

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  /// (اليوم، الوقت)
  static (String, String) format(DateTime time, DateTime now) {
    final clock = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    final day = DateTime(time.year, time.month, time.day);
    final days = DateTime(now.year, now.month, now.day).difference(day).inDays;
    final label = switch (days) {
      0 => ConversationText.today(),
      1 => ConversationText.yesterday(),
      > 1 && < 7 => _weekdays[time.weekday - 1],
      _ => '${time.day} ${_months[time.month - 1]} ${time.year}',
    };
    return (label, clock);
  }

  @override
  Widget build(BuildContext context) {
    final (day, clock) = format(time, now ?? DateTime.now());
    TextStyle style(FontWeight weight) => TextStyle(fontFamily: 'Poppins', fontWeight: weight, fontSize: s.x(11), height: 13 / 11, letterSpacing: s.x(0.066), color: ChatsColors.time);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: day, style: style(FontWeight.w500)),
          TextSpan(text: ' $clock', style: style(FontWeight.w400)),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
  }
}
