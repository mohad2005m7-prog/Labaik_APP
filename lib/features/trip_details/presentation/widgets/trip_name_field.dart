import 'package:flutter/material.dart';

import '../../../../core/utils/content_direction.dart';
import '../../../../core/utils/figma_canvas.dart';
import 'trip_colors.dart';

// -------------------------------------------------------------
// حقل الاسم (Figma 10تعديل — 329×43.5 من x48 أبيض بحد #1F3B2E 1 radius 10)
// النص 16 ويبدأ قبل طرف الحقل بـ 16.5 — والـ placeholder "محمد احمد" #3C3C43 60%
// -------------------------------------------------------------
class TripNameField extends StatelessWidget {
  final FigmaCanvas c;
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const TripNameField({super.key, required this.c, required this.controller, required this.hint, required this.onChanged});

  static const _hintColor = Color(0x993C3C43);

  @override
  Widget build(BuildContext context) {
    TextStyle style(Color color) => c.style(16, 450, color, lineHeight: null, letterSpacing: 0);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.box(left: 48, top: 303, width: 329, height: 43.5, radius: 10, color: Colors.white, borderColor: TripColors.green),
        c.rect(
          left: 48 + 16.5,
          top: 303,
          width: 329 - 33,
          height: 43.5,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) => TextField(
                controller: controller,
                textDirection: contentDirection(value.text),
                maxLines: 1,
                textInputAction: TextInputAction.done,
                style: style(Colors.black),
                cursorColor: TripColors.green,
                onChanged: onChanged,
                decoration: InputDecoration.collapsed(hintText: hint, hintStyle: style(_hintColor)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
