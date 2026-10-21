import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../domain/entities/supervisor_inbox.dart';
import '../controllers/supervisor_controller.dart';
import '../cubits/supervisor_content_cubits.dart';
import '../l10n/sup_chats_text.dart';
import '../widgets/supervisor_colors.dart';
import '../widgets/supervisor_page.dart';
import '../widgets/supervisor_widgets.dart';

// -------------------------------------------------------------
// الدردشات — مطابقة لـ Figma "الدردشات" (234:3541)
// صفوف iOS (_Messages-threadRow) 361×76 كل 84: الصورة 45 يمين، الاسم والرسالة، الوقت والسهم يسار
// البحث بيفلتر حسب الاسم أو آخر رسالة — مجموعاتي + المحادثات الفردية مع المعتمرين — الضغط بيفتح المحادثة
// (بنفس شاشة محادثة المعتمر Figma 111:7045 — فيها حذف الرسائل وكتم المعتمر وقفل الكتابة للمشرف)
// -------------------------------------------------------------
class SupervisorChatsScreen extends StatelessWidget {
  const SupervisorChatsScreen({super.key});

  static const _listTop = 164.0;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SupervisorChatsCubit>();
    return SupervisorPage(
      inShell: true,
      builder: (c) => [
        // SF Compact Medium 24 — بالنص
        c.text(SupChatsText.title(), left: 96, top: 59, width: 201, height: 29, align: TextAlign.center, style: supText(c, 24, FigmaWeight.semiBold, SupColors.green)),
        c.rect(left: 24, top: 104, width: 345, height: 36, child: SupSearchField(s: c.s, hint: SupChatsText.search(), onChanged: cubit.search)),
        // القائمة لحد شريط التنقل
        c.rect(
          left: 0,
          top: _listTop,
          width: 393,
          height: 769 - _listTop,
          child: BlocBuilder<SupervisorChatsCubit, ListState<ChatThread>>(
            builder: (context, state) {
              final chats = state.visible;
              return ListView.builder(
                padding: EdgeInsets.zero,
                physics: supScrollPhysics,
                itemCount: chats.length,
                itemExtent: c.s.y(84),
                itemBuilder: (context, i) => Stack(children: _row(context, c.at(_listTop), chats[i])),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _row(BuildContext context, FigmaCanvas c, ChatThread t) {
    const top = _listTop;
    final secondary = c.style(15, FigmaWeight.poppinsRegular, SupColors.secondaryLabel, lineHeight: 20, letterSpacing: -0.24);
    return [
      c.box(left: 306, top: top + 15.5, width: 45, height: 45, color: SupColors.avatarPlaceholder, radius: 22.5),
      // SF Compact Regular 17 — line height 22 — أسود — طرفه x294
      c.text(t.name, left: 130, top: top + 8, width: 164, height: 22, style: c.style(17, FigmaWeight.sfRegular, Colors.black)),
      // الوقت لاتيني ("9:12 AM") — معزول LTR حتى ما ينقلب لـ "AM 9:12" جوّا سطر عربي — Poppins Regular 15 بيبدأ عند x52.4
      c.text(String.fromCharCode(0x2066) + t.time + String.fromCharCode(0x2069), left: 52.4, top: top + 9, width: 70, height: 20, align: TextAlign.end, dy: 0, poppinsLatin: true, latinWeight: FontWeight.w400, style: secondary),
      c.image('$supAssets/ic_chevron_small_left.png', left: 32, top: top + 13.5, width: 6.42, height: 11, flipInLtr: true),
      // آخر رسالة — Poppins Regular 15 — طرفها x294
      c.text(t.lastMessage, left: 82, top: top + 30, width: 212, height: 20, dy: 0, style: secondary),
      // فاصل 0.5 تحت المحتوى (x16..294)
      c.box(left: 16, top: top + 75.5, width: 278, height: 0.5, color: SupColors.chatSeparator),
      c.tapArea(left: 16, top: top, width: 361, height: 76, onTap: () => SupervisorController.openChat(context, t)),
    ];
  }
}
