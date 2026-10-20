import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/top_popup.dart';
import '../l10n/track_choice_text.dart';
import 'family_colors.dart';

typedef TrackChoiceAction = Future<void> Function(BuildContext dialog);

// -------------------------------------------------------------
// "مع من تريد التتبع؟" (Figma 356:3148) — أول ما يضغط تبويب "الأفراد":
// كرت 391×216 #ECF4F1 بينزل من فوق الشاشة وبيثبت بنصها — "العائلة" (يمين x203) و"المجموعة" (x23) 173×48
// الزر المضغوط عليه دوّارة لحد ما نعرف وين نوديه — الضغط برا النافذة بيسكّرها (بتطلع لفوق)
// -------------------------------------------------------------
Future<void> showTrackChoice(BuildContext context, {required TrackChoiceAction onFamily, required TrackChoiceAction onGroup}) {
  return showTopPopup<void>(context, label: TrackChoiceText.title(), builder: (_) => _ChoiceCard(onFamily: onFamily, onGroup: onGroup));
}

class _ChoiceCard extends StatefulWidget {
  final TrackChoiceAction onFamily;
  final TrackChoiceAction onGroup;

  const _ChoiceCard({required this.onFamily, required this.onGroup});

  @override
  State<_ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<_ChoiceCard> {
  /// الزر اللي عم يستنى (true = العائلة)
  bool? _busy;

  Future<void> _run(bool family) async {
    if (_busy != null) return;
    setState(() => _busy = family);
    try {
      await (family ? widget.onFamily : widget.onGroup)(context);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    final c = FigmaCanvas(s, originTop: 0);
    // الكرت من x1 بإطار الشاشة (393)
    const x = 1.0;
    final label = c.style(13.1, FigmaWeight.sfBold, Colors.white, lineHeight: null, letterSpacing: 0);
    Widget button(String text, {required double left, required VoidCallback onTap, bool busy = false}) => c.rect(
          left: x + left,
          top: 108,
          width: 173,
          height: 48,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: DecoratedBox(
              decoration: BoxDecoration(color: FamilyColors.green, borderRadius: BorderRadius.circular(s.x(12))),
              child: Center(
                child: busy
                    ? SizedBox.square(dimension: s.x(20), child: const CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                    // حبر النص بـ Figma أوطى بـ 2 وأيمن بـ 1.75 من نص الزر
                    : Padding(padding: EdgeInsets.only(left: s.x(3.5), top: s.y(4)), child: Text(text, style: label)),
              ),
            ),
          ),
        );
    return TopPopup(
      height: 216,
      child: Stack(
        children: [
          // الضغط على الكرت نفسه ما بيسكّره
          c.rect(left: x, top: 0, width: 391, height: 216, child: GestureDetector(onTap: () {}, child: DecoratedBox(decoration: BoxDecoration(color: FamilyColors.dialogFill, borderRadius: BorderRadius.circular(s.x(16)))))),
          c.text(TrackChoiceText.title(), left: x + 16, top: 52, width: 359, height: 30, dy: 0, align: TextAlign.center, style: c.style(19, FigmaWeight.sfBold, Colors.black, lineHeight: null, letterSpacing: 0)),
          button(TrackChoiceText.family(), left: 203, onTap: () => _run(true), busy: _busy == true),
          button(TrackChoiceText.group(), left: 23, onTap: () => _run(false), busy: _busy == false),
        ],
      ),
    );
  }
}
