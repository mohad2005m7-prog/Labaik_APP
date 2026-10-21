import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/api_error_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../pilgrim_tabs/presentation/controllers/pilgrim_tabs_controller.dart';
import '../../../pilgrim_tabs/presentation/widgets/pilgrim_tab_bar.dart';
import '../controllers/chats_controller.dart';
import '../cubits/chats_list_cubit.dart';
import '../l10n/chats_text.dart';
import '../widgets/chat_list_time.dart';
import '../widgets/chat_search_field.dart';
import '../widgets/chat_thread_row.dart';
import '../widgets/chats_colors.dart';

// -------------------------------------------------------------
// "قائمة المحادثات" (Figma 111:6879) — تبويب الدردشات:
// المحادثات (SF Compact 790 20 #1F3B2E) — خانة البحث (16,112 361×48) — الصفوف من y184 كل 82 — شريط التنقل
// المحادثات فعلية من السيرفر (المشرف، المجموعة، الأفراد) — المثبّتة فوق وبعدين الأحدث
// -------------------------------------------------------------
class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  static const _listTop = 184.0;

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    final c = FigmaCanvas(s);
    final cubit = context.read<ChatsListCubit>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              height: s.y(DesignScale.designSafeHeight),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // "Frame 16": المحادثات (SF Compact 790 24)
                  c.text(ChatsText.title(), left: 40.5, top: 60.25, width: 336, height: 29, dy: 0, style: c.style(24, FigmaWeight.sfBold, ChatsColors.green, lineHeight: null, letterSpacing: 0)),
                  c.rect(
                    left: 16,
                    top: 112,
                    width: 361,
                    height: 48,
                    child: ChatSearchField(s: s, hint: ChatsText.search(), onChanged: cubit.search),
                  ),
                  c.rect(
                    left: 0,
                    top: _listTop,
                    width: FigmaCanvas.frameWidth,
                    height: PilgrimTabBar.top - _listTop,
                    child: BlocBuilder<ChatsListCubit, ChatsListState>(builder: (context, state) => _list(context, s, state)),
                  ),
                  Positioned.fill(
                    child: PilgrimTabBar(c: c, selected: PilgrimTab.chats, onTab: (tab) => PilgrimTabsController.open(context, tab)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _list(BuildContext context, DesignScale s, ChatsListState state) {
    final chats = state.visible;
    if (chats.isEmpty) {
      // ما في محادثات: لسا بيحمّل / خطأ السيرفر / فاضية / ما في نتائج للبحث
      final error = state.error;
      final text = state.loading
          ? null
          : error != null && state.all.isEmpty
          ? ApiErrorText.of(error)()
          : state.query.trim().isNotEmpty
          ? ChatsText.noResults()
          : ChatsText.empty();
      return Padding(
        padding: EdgeInsets.only(top: s.y(40)),
        child: Align(
          alignment: Alignment.topCenter,
          child: text == null
              ? SizedBox.square(
                  dimension: s.x(24),
                  child: const CircularProgressIndicator(strokeWidth: 2.5, color: ChatsColors.green),
                )
              : Text(
                  text,
                  textAlign: TextAlign.center,
                  style: figmaText(s, size: 14, weight: FigmaWeight.sfRegular, color: ChatsColors.time, lineHeight: null, letterSpacing: 0),
                ),
        ),
      );
    }
    final row = FigmaCanvas(s, originTop: 0);
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      itemCount: chats.length,
      itemExtent: s.y(ChatThreadRow.pitch),
      itemBuilder: (context, i) => ChatThreadRow(
        c: row,
        conversation: chats[i],
        time: ChatListTime.format(chats[i].updatedAt),
        onTap: () => ChatsController.openConversation(context, chats[i]),
        onLongPress: () => ChatsController.conversationOptions(context, chats[i]),
      ),
    );
  }
}
