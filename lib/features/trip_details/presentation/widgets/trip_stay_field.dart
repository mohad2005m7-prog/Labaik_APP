import 'package:flutter/material.dart';

import '../../../../core/theme/figma_spaced_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/content_direction.dart';
import '../../../../core/utils/figma_canvas.dart';
import 'chevron_down_icon.dart';
import 'trip_colors.dart';

// -------------------------------------------------------------
// حقل مكان الإقامة (Figma 9تعديل — 335.82×38 من x38 أبيض بحد #1F3B2E 1 radius 10):
// الفندق: الاسم (SF Compact 16 #1F3B2E — طرفه عند x330.5) وسهم "⌄" مركزه عند x349 — الضغط بيفتح قائمة الفنادق
// [controller] (مكان اخر): حقل كتابة بنفس الشكل
// -------------------------------------------------------------
class TripStayField extends StatelessWidget {
  final FigmaCanvas c;
  final double top;
  final String text;
  final bool empty;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;

  const TripStayField.pick({super.key, required this.c, required this.top, required this.text, required this.empty, required VoidCallback this.onTap})
      : controller = null,
        hint = null,
        onChanged = null;

  const TripStayField.write({super.key, required this.c, required this.top, required TextEditingController this.controller, required String this.hint, required ValueChanged<String> this.onChanged})
      : text = '',
        empty = false,
        onTap = null;

  static const left = 38.0;
  static const width = 335.82;
  static const height = 38.0;
  static const _hintColor = Color(0x993C3C43);

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    final style = c.style(16, 450, TripColors.green, lineHeight: null, letterSpacing: 0);
    final input = controller;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.box(left: left, top: top, width: width, height: height, radius: 10, color: Colors.white, borderColor: TripColors.green),
        if (input == null) ...[
          c.rect(left: 338, top: top + 7, width: 24, height: 24, child: Center(child: ChevronDownIcon(width: s.x(9.7), height: s.x(5), stroke: s.x(1.5), color: TripColors.green))),
          c.rect(
            left: 46,
            top: top,
            width: 330.5 - 46,
            height: height,
            child: IgnorePointer(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: FigmaSpacedText(
                  text,
                  style: c.style(16, 450, empty ? _hintColor : TripColors.green, lineHeight: null),
                  letterSpacing: s.x(-0.408),
                  width: s.x(330.5 - 46),
                  maxLines: 1,
                ),
              ),
            ),
          ),
          c.tapArea(left: left, top: top, width: width, height: height, onTap: onTap!),
        ] else
          c.rect(
            left: left + 12,
            top: top,
            width: width - 24,
            height: height,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: input,
                builder: (context, value, _) => TextField(
                  controller: input,
                  textDirection: contentDirection(value.text),
                  maxLines: 1,
                  style: style,
                  cursorColor: TripColors.green,
                  onChanged: onChanged,
                  decoration: InputDecoration.collapsed(hintText: hint, hintStyle: c.style(16, FigmaWeight.sfLight, _hintColor, lineHeight: null, letterSpacing: 0)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
