import 'package:flutter/material.dart';

import '../../../../core/utils/design_scale.dart';
import '../l10n/assistant_text.dart';
import '../pages/assistant_screen.dart';

// -------------------------------------------------------------
// التنقل بشاشة المساعد الذكي (بروتوتايب Figma): الرئيسية (كرت "المساعد الذكي") → المساعد الذكي
// السؤال (مكتوب أو من الأسئلة المقترحة) بيوصل لـ [ask] — هون بينربط جواب المساعد لما يتوفر:
// ما في endpoint للمساعد بالباك إند، ولا تصميم بـ Figma لشاشة المحادثة/الجواب
// -------------------------------------------------------------
class AssistantController {
  static Future<void> open(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssistantScreen()));

  static void ask(BuildContext context, String question) {
    FocusScope.of(context).unfocus();
    _showMessage(context, question.trim().isEmpty ? AssistantText.emptyQuestion() : AssistantText.unavailable());
  }

  // الرسالة فوق شريط الكتابة (طوله 61 من تحت) حتى ما تغطيه
  static void _showMessage(BuildContext context, String text) {
    final s = DesignScale.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(s.x(16), 0, s.x(16), s.y(61 + 8)),
        duration: const Duration(milliseconds: 1600),
      ));
  }
}
