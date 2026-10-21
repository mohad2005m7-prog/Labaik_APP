import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/figma_spaced_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/content_direction.dart';
import '../../../../core/utils/design_scale.dart';
import 'chats_colors.dart';

enum ChatAvatarPlacement { centered, hanging }

// -------------------------------------------------------------
// مكان صورة المرسل جنب الفقاعة (أرقام Figma):
//   helpGreeting — مركز المساعدة 372:7286: الصورة 45 من x25 بنص الفقاعة، والفقاعة من x77.5
//   incoming     — المحادثة الفردية 111:7045: صورة الطرف التاني من x24 والفقاعة من x73 — الصورة نازلة تحت الفقاعة
//   outgoing     — رسائلي: الفقاعة لحد x317 وصورتي من x320 (هامش 28) — نازلة تحت الفقاعة
// "نازلة": أعلى الصورة قبل آخر الفقاعة بـ 8
// -------------------------------------------------------------
class ChatBubbleLayout {
  final double avatarInset;
  final double gap;
  final ChatAvatarPlacement placement;

  const ChatBubbleLayout({required this.avatarInset, required this.gap, required this.placement});

  static const helpGreeting = ChatBubbleLayout(avatarInset: 25, gap: 7.5, placement: ChatAvatarPlacement.centered);
  static const incoming = ChatBubbleLayout(avatarInset: 24, gap: 4, placement: ChatAvatarPlacement.hanging);
  static const outgoing = ChatBubbleLayout(avatarInset: 28, gap: 3, placement: ChatAvatarPlacement.hanging);

  static const avatarSize = 45.0;

  /// كم بتنزل الصورة تحت الفقاعة
  static double overhang(DesignScale s) => s.x(avatarSize) - s.y(8);
}

// -------------------------------------------------------------
// فقاعة رسالة (Figma "Bubble + Tail" — iOS): radius 18 وذيل تحت من جهة المرسل
// الطرف التاني: يسار بلون #E9E9EB ونص أسود — رسائلي: يمين بلون #1F3B2E ونص أبيض (111:7045)
// النص 17 بـ line height 22 وحشوة 12 × 6 — بيلتف بعرض Figma (letter spacing -0.408 — شوف FigmaSpacedText)
// الجهات ثابتة باللغتين (الطرف التاني يسار وأنا يمين) زي Figma
// [avatar]: صورة المرسل — null = بدونها (رسالة بنص سلسلة رسائل من نفس الشخص) بس مكانها محجوز
// -------------------------------------------------------------
class ChatBubble extends StatelessWidget {
  /// مقاس الشاشة من فوق الـ Scaffold (جوّا SafeArea الحساب بيطلع غلط)
  final DesignScale s;
  final bool fromMe;
  final ChatBubbleLayout layout;
  final Widget? avatar;

  /// النص — أو [child] لمحتوى تاني (الموقع)
  final String? text;
  final Widget? child;
  final double opacity;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// الفقاعة بعرضها الكامل 267 (رسالة المشرف الأولى بـ Figma) بدل ما تلفّ على النص
  final bool fullWidth;

  const ChatBubble({super.key, required this.s, required this.fromMe, required this.layout, this.avatar, this.text, this.child, this.opacity = 1, this.onTap, this.onLongPress, this.fullWidth = false});

  static const maxWidth = 267.3;
  static const padX = 12.0;
  static const padY = 6.0;

  static TextStyle textStyle(DesignScale s, {required bool fromMe}) => figmaText(s, size: 17, weight: 400, color: fromMe ? Colors.white : Colors.black, lineHeight: 22, letterSpacing: -0.408);

  @override
  Widget build(BuildContext context) {
    final style = textStyle(s, fromMe: fromMe);
    final outer = Directionality.of(context);
    final content = child == null ? _text(context, style) : Directionality(textDirection: outer, child: child!);
    final bubble = GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          painter: _BubblePainter(color: fromMe ? ChatsColors.green : ChatsColors.bubbleIn, tailOnRight: fromMe, scale: s.x(1)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: s.x(padX), vertical: s.y(padY)),
            child: content,
          ),
        ),
      ),
    );
    final size = s.x(ChatBubbleLayout.avatarSize);
    final inset = s.x(layout.avatarInset), gap = s.x(layout.gap);
    final picture = avatar == null ? SizedBox(width: size) : SizedBox.square(dimension: size, child: avatar);
    Widget limited(Widget w) => Flexible(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: s.x(maxWidth)),
        child: w,
      ),
    );

    final Widget row;
    if (layout.placement == ChatAvatarPlacement.centered) {
      row = Row(
        mainAxisAlignment: fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!fromMe) ...[SizedBox(width: inset), picture, SizedBox(width: gap)],
          limited(bubble),
          if (fromMe) ...[SizedBox(width: gap), picture, SizedBox(width: inset)],
        ],
      );
    } else {
      final overhang = ChatBubbleLayout.overhang(s);
      final side = inset + size + gap;
      final framed = Stack(
        clipBehavior: Clip.none,
        children: [
          bubble,
          if (avatar != null) Positioned(bottom: -overhang, left: fromMe ? null : -(gap + size), right: fromMe ? -(gap + size) : null, child: picture),
        ],
      );
      row = Padding(
        padding: EdgeInsets.only(bottom: avatar == null ? 0 : overhang),
        child: Row(
          mainAxisAlignment: fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!fromMe) SizedBox(width: side),
            limited(framed),
            if (fromMe) SizedBox(width: side),
          ],
        ),
      );
    }
    return Directionality(textDirection: TextDirection.ltr, child: row);
  }

  /// النص بعرض أطول سطر فيه (لحد عرض الفقاعة) — سطور Figma المكسورة بـ "\n" بتضل زي ما هي
  Widget _text(BuildContext context, TextStyle style) {
    final value = text ?? '';
    final direction = contentDirection(value) ?? Directionality.of(context);
    final room = s.x(maxWidth - 2 * padX);
    final ls = s.x(-0.408);
    final parts = value.split('\n');
    var width = 0.0;
    for (final part in parts) {
      width = math.max(width, FigmaSpacedText.lineWidth(context, part, style, ls));
    }
    width = fullWidth ? room : math.min(room, width + 1);
    return Directionality(
      textDirection: direction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final part in parts) FigmaSpacedText(part, style: style, letterSpacing: ls, width: width, direction: direction)],
      ),
    );
  }
}

/// جسم الفقاعة (radius 18) + الذيل المنحني بالزاوية التحتانية
class _BubblePainter extends CustomPainter {
  final Color color;
  final bool tailOnRight;
  final double scale;

  _BubblePainter({required this.color, required this.tailOnRight, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final r = math.min(18 * scale, size.height / 2);
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(r)), paint);
    final h = size.height, k = scale;
    // الذيل بجهة اليسار (وبينعكس لرسالتي)
    final tail = Path()
      ..moveTo(0, h - 16 * k)
      ..quadraticBezierTo(0.5 * k, h - 3 * k, -5 * k, h)
      ..quadraticBezierTo(4 * k, h + 0.6 * k, 11 * k, h - 3.5 * k)
      ..close();
    if (tailOnRight) {
      canvas.save();
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
      canvas.drawPath(tail, paint);
      canvas.restore();
    } else {
      canvas.drawPath(tail, paint);
    }
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.color != color || old.tailOnRight != tailOnRight || old.scale != scale;
}
