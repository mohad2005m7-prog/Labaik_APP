import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_line.dart';
import '../../../../core/widgets/figma_page.dart';
import '../controllers/assistant_controller.dart';
import '../l10n/assistant_text.dart';
import '../widgets/assistant_input_bar.dart';
import '../widgets/assistant_welcome_card.dart';
import '../widgets/suggested_question_card.dart';

// -------------------------------------------------------------
// المساعد الذكي — Figma (111:6047): كرت الترحيب — "أسئلة مقترحة" (4 أسئلة) — شريط "اكتب سؤالك هنا..."
// الضغط على سؤال مقترح أو زر الإرسال بيسأل المساعد (AssistantController.ask)
// -------------------------------------------------------------
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _question = TextEditingController();

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  void _ask(String question) => AssistantController.ask(context, question);

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: AssistantText.title(),
      // "Frame 38" عرضه 372 بهالإطار: العنوان والسهم أبعد شوي (مقاس)
      titleRight: 349,
      chevronLeft: 367,
      body: (c) {
        // SF Compact 556 أسود
        TextStyle label(double size) => c.style(size, FigmaWeight.semiBold, Colors.black);
        return [
          c.line(AssistantText.subtitle(), left: 177, top: 107, width: 200, height: 22, style: label(14)),
          Positioned.fill(child: AssistantWelcomeCard(c: c)),
          c.line(AssistantText.suggested(), left: 177, top: 264, width: 200, height: 22, style: label(13)),
          for (var i = 0; i < AssistantText.questions.length; i++)
            Positioned.fill(
              child: SuggestedQuestionCard(c: c, index: i, question: AssistantText.questions[i](), onTap: () => _ask(AssistantText.questions[i]())),
            ),
          Positioned.fill(child: AssistantInputBar(c: c, controller: _question, onSend: () => _ask(_question.text))),
        ];
      },
    );
  }
}
