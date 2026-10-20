import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';

// -------------------------------------------------------------
// هيكل شاشات حساب المعتمر: خلفية بيضا والعناصر بأرقام إطار Figma
// الإطار أطول من 852 (الإعدادات 938، تعديل البيانات 915) → بتتمرر بمقدار الفرق بالظبط
// الكيبورد ما بيصغّر الشاشة، وبيترك مساحة تحته حتى الحقل يضل ظاهر
// -------------------------------------------------------------
class PilgrimPage extends StatelessWidget {
  final List<Widget> Function(FigmaCanvas c) builder;
  final double frameHeight;

  const PilgrimPage({super.key, required this.builder, required this.frameHeight});

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    final c = FigmaCanvas(s);
    final keyboard = math.max(0.0, MediaQuery.viewInsetsOf(context).bottom - MediaQuery.paddingOf(context).bottom);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Padding(
              padding: EdgeInsets.only(bottom: keyboard),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: s.y(frameHeight - FigmaCanvas.statusBar - 34),
                  child: Stack(clipBehavior: Clip.none, children: builder(c)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
