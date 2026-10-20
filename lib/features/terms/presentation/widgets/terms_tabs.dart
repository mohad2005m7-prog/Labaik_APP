import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';

// -------------------------------------------------------------
// التبويبات (Figma "Frame 2147227408" — y119 ارتفاع 48، بينهم 10، وبتنسحب أفقياً متل البروتوتايب):
// كل تبويب 135×48 — radius 16 — المختار أخضر #1F3B2E ونصه أبيض (أوطى بـ 5 متل Figma)، والباقي أبيض بحد أخضر ونص #2E2D2D
// النص SF Compact 656 14 — الشريط بعرض الشاشة: أول تبويب على بعد 12 من طرفها وآخر واحد بيوقف على بعد 19
// -------------------------------------------------------------
class TermsTabs extends StatefulWidget {
  final FigmaCanvas c;
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  const TermsTabs({super.key, required this.c, required this.labels, required this.selected, required this.onSelect});

  static const top = 119.0;
  static const height = 48.0;
  static const chipWidth = 135.0;
  static const gap = 10.0;
  static const startPad = 12.0;
  static const endPad = 19.0;

  @override
  State<TermsTabs> createState() => _TermsTabsState();
}

class _TermsTabsState extends State<TermsTabs> {
  static const _textColor = Color(0xFF2E2D2D);
  // مكان النص عن نص التبويب (مقاس من Figma)
  static const _selectedDy = 0.5;
  static const _dy = -4.5;

  final _scroll = ScrollController();

  @override
  void didUpdateWidget(TermsTabs old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) _reveal(widget.selected);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// التبويب المختار بيبين كله (لو كان مقصوص على طرف الشاشة)
  void _reveal(int index) {
    if (!_scroll.hasClients) return;
    final s = widget.c.s;
    final start = s.x(TermsTabs.startPad + index * (TermsTabs.chipWidth + TermsTabs.gap));
    final end = start + s.x(TermsTabs.chipWidth);
    final position = _scroll.position;
    var target = position.pixels;
    if (start - s.x(TermsTabs.startPad) < target) target = start - s.x(TermsTabs.startPad);
    if (end + s.x(TermsTabs.endPad) > target + position.viewportDimension) target = end + s.x(TermsTabs.endPad) - position.viewportDimension;
    target = target.clamp(position.minScrollExtent, position.maxScrollExtent);
    if (target != position.pixels) _scroll.animateTo(target, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final s = c.s;
    return c.rect(
      left: 0,
      top: TermsTabs.top,
      width: FigmaCanvas.frameWidth,
      height: TermsTabs.height,
      child: SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsetsDirectional.only(start: s.x(TermsTabs.startPad), end: s.x(TermsTabs.endPad)),
        child: Row(
          children: [
            for (final (i, label) in widget.labels.indexed) ...[
              if (i > 0) SizedBox(width: s.x(TermsTabs.gap)),
              _chip(c, label, selected: i == widget.selected, onTap: () => widget.onSelect(i)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(FigmaCanvas c, String label, {required bool selected, required VoidCallback onTap}) {
    final s = c.s;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: s.x(TermsTabs.chipWidth),
        height: s.y(TermsTabs.height),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? FigmaCanvas.green : Colors.white,
          borderRadius: BorderRadius.circular(s.x(16)),
          border: selected ? null : Border.all(color: FigmaCanvas.green, width: s.x(1)),
        ),
        child: Transform.translate(
          offset: Offset(0, s.y(selected ? _selectedDy : _dy)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: s.x(8)),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, maxLines: 1, softWrap: false, style: c.style(14, FigmaWeight.sfSemibold, selected ? Colors.white : _textColor, lineHeight: null, letterSpacing: 0)),
            ),
          ),
        ),
      ),
    );
  }
}
