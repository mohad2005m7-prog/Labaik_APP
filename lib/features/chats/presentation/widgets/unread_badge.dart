import 'package:flutter/material.dart';

import '../../../../core/utils/design_scale.dart';
import 'chats_colors.dart';

// -------------------------------------------------------------
// عدد الرسائل غير المقروءة: دايرة #1F3B2E قطرها 20 والرقم أبيض بالنص (أكتر من 99 → "99+")
// -------------------------------------------------------------
class UnreadBadge extends StatelessWidget {
  final DesignScale s;
  final int count;

  const UnreadBadge({super.key, required this.s, required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      constraints: BoxConstraints(minWidth: s.x(20)),
      height: s.x(20),
      padding: EdgeInsets.symmetric(horizontal: s.x(label.length > 1 ? 5 : 0)),
      decoration: BoxDecoration(color: ChatsColors.green, borderRadius: BorderRadius.circular(s.x(10))),
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          textDirection: TextDirection.ltr,
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: s.x(13), height: 1, color: Colors.white),
        ),
      ),
    );
  }
}
