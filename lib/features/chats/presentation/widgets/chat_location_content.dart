import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/geo_utils.dart';
import '../l10n/conversation_text.dart';
import 'chat_bubble.dart';

// -------------------------------------------------------------
// محتوى فقاعة الموقع: "📍 موقعي الحالي" وتحتها الإحداثيات (الضغط بيفتح الخريطة)
// (ما في تصميم لرسالة الموقع بـ Figma — بنفس خط الفقاعات)
// -------------------------------------------------------------
class ChatLocationContent extends StatelessWidget {
  final GeoPoint location;
  final bool fromMe;

  /// نص مع الموقع (لو السيرفر بعته)
  final String? note;

  /// مقاس الشاشة من فوق الـ Scaffold (جوّا SafeArea الحساب بيطلع غلط)
  final DesignScale s;

  const ChatLocationContent({super.key, required this.s, required this.location, required this.fromMe, this.note});

  @override
  Widget build(BuildContext context) {
    final style = ChatBubble.textStyle(s, fromMe: fromMe);
    final small = figmaText(s, size: 12, weight: FigmaWeight.sfRegular, color: style.color!.withValues(alpha: 0.75), lineHeight: null, letterSpacing: 0);
    final title = (note ?? '').trim().isEmpty ? ConversationText.myLocation() : note!.trim();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📍 $title',
          style: style.copyWith(decoration: TextDecoration.underline, decorationColor: style.color),
        ),
        Text(
          '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}',
          textDirection: TextDirection.ltr,
          style: small.copyWith(fontFamily: 'Poppins', fontVariations: const []),
        ),
      ],
    );
  }
}
