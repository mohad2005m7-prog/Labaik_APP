import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_page.dart';
import '../controllers/help_center_controller.dart';
import '../cubits/supervisor_contact_cubit.dart';
import '../l10n/help_messages_text.dart';
import '../l10n/quick_contact_text.dart';
import '../widgets/help_colors.dart';
import '../widgets/help_text.dart';
import '../../../chats/presentation/widgets/chat_avatar.dart';

// -------------------------------------------------------------
// "التواصل السريع مع المشرف" (Figma 111:5972):
// صورة المشرف 80×80 + اسمه (SF Compact 790 16) + "مشرف المجموعة" (SF Compact 457 16) — من السيرفر
// اتصال هاتفي (رقمه الفعلي) / محادثة المشرف (المحادثة الفردية)
// لحد ما توصل بيانات المشرف: دايرة فاضية ومكان الاسم بيبيّن الحالة (تحميل / مش مربوط / خطأ)
// -------------------------------------------------------------
class QuickContactScreen extends StatelessWidget {
  const QuickContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: QuickContactText.title(),
      titleRight: 349,
      chevronLeft: 367,
      body: (c) => [
        HelpText.paragraph(c, QuickContactText.description(), left: 16, top: 104, width: 361, lines: 2, style: c.style(14, FigmaWeight.semiBold, Colors.black)),
        Positioned.fill(
          child: BlocBuilder<SupervisorContactCubit, SupervisorContactState>(
            builder: (context, state) {
              final contact = state.contact;
              final name =
                  contact?.name ??
                  switch (state.status) {
                    SupervisorStatus.loading => HelpMessagesText.loadingSupervisor(),
                    SupervisorStatus.notLinked => HelpMessagesText.notLinked(),
                    _ => HelpMessagesText.forError(state.error ?? Object())(),
                  };
              final nameStyle = contact == null
                  ? c.style(13, FigmaWeight.sfRegular, HelpColors.grey, lineHeight: null, letterSpacing: 0)
                  : c.style(16, FigmaWeight.sfBold, HelpColors.green, lineHeight: null, letterSpacing: 0);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  c.rect(
                    left: 157,
                    top: 172,
                    width: 80,
                    height: 80,
                    child: Center(
                      child: ChatAvatar(url: contact?.photoUrl, size: c.s.x(80)),
                    ),
                  ),
                  c.text(name, left: 16, top: 260, width: 361, height: 19, dy: 0, align: TextAlign.center, style: nameStyle),
                  c.text(
                    QuickContactText.role(),
                    left: 16,
                    top: 287,
                    width: 361,
                    height: 19,
                    dy: 0,
                    align: TextAlign.center,
                    style: c.style(16, FigmaWeight.sfRegular, HelpColors.green, lineHeight: null, letterSpacing: 0),
                  ),
                  c.button(QuickContactText.call(), left: 17, top: 338, figmaSpacing: true, onTap: () => HelpCenterController.call(context, state)),
                  c.button(QuickContactText.chat(), left: 17, top: 396, figmaSpacing: true, onTap: () => HelpCenterController.toChat(context, state)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
