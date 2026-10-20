import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';

// -------------------------------------------------------------
// الهيكل المشترك لشاشات الشركة: خلفية بيضا + العناصر بأرقام إطار Figma (FigmaCanvas)
// - إطار 852: الشاشة ثابتة (لو الجهاز قصير المحتوى بيصغر بدل ما يطلع برا)
// - [scrollHeight] أطول من 852 (قائمة طويلة): المحتوى بيتمرر — و[fixed] بيضل ثابت فوقه (زر "إنشاء رحلة جديدة")
// - [inShell]: صفحات التبويبات جوّا CompanyShell (هو اللي فيه الـ Scaffold وشريط التنقل)
// -------------------------------------------------------------
class CompanyPage extends StatelessWidget {
  final List<Widget> Function(FigmaCanvas c) builder;
  final List<Widget> Function(FigmaCanvas c)? fixed;
  final double scrollHeight;
  final bool inShell;

  const CompanyPage({super.key, required this.builder, this.fixed, this.scrollHeight = 852, this.inShell = false});

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    final c = FigmaCanvas(s);
    final width = MediaQuery.sizeOf(context).width;
    SizedBox frame(double height, List<Widget> children) =>
        SizedBox(width: width, height: s.y(height - FigmaCanvas.statusBar - 34), child: Stack(clipBehavior: Clip.none, children: children));

    final Widget body;
    if (scrollHeight > 852) {
      final keyboard = math.max(0.0, MediaQuery.viewInsetsOf(context).bottom - MediaQuery.paddingOf(context).bottom);
      body = Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: keyboard),
            child: SingleChildScrollView(physics: const ClampingScrollPhysics(), child: frame(scrollHeight, builder(c))),
          ),
          // الفاضي بين العناصر الثابتة بيمرر اللمس للقائمة اللي تحته
          if (fixed != null) frame(852, fixed!(c)),
        ],
      );
    } else {
      body = FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.topCenter, child: frame(852, [...builder(c), ...?fixed?.call(c)]));
    }

    final page = SafeArea(child: body);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: inShell ? ColoredBox(color: Colors.white, child: page) : Scaffold(backgroundColor: Colors.white, resizeToAvoidBottomInset: false, body: page),
    );
  }
}
