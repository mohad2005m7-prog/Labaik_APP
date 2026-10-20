import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';

// -------------------------------------------------------------
// الهيكل المشترك لشاشات المشرف: خلفية بيضا + العناصر بأرقام إطار Figma عن طريق FigmaCanvas
// - إطار 852: الشاشة ثابتة (لو الجهاز قصير كتير المحتوى بيصغر بدل ما يطلع برا) — زي FieldModePage
// - إطار أطول (إنشاء إعلان 896، الإعدادات 938): بتتمرر بمقدار الفرق بالظبط
// - [alwaysBounce]: الرئيسية بتنسحب بارتداد خفيف زي رئيسية المعتمر
// - [inShell]: صفحات التبويبات جوّا SupervisorShell (هو اللي فيه الـ Scaffold وشريط التنقل)
// الكيبورد ما بيصغّر الشاشة (المقاسات بتضل ثابتة)، وبالشاشات اللي بتتمرر بيترك مساحة تحته.
// -------------------------------------------------------------
class SupervisorPage extends StatelessWidget {
  final List<Widget> Function(FigmaCanvas c) builder;
  final double frameHeight;
  final bool alwaysBounce;
  final bool inShell;

  const SupervisorPage({super.key, required this.builder, this.frameHeight = 852, this.alwaysBounce = false, this.inShell = false});

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    final c = FigmaCanvas(s);
    final width = MediaQuery.sizeOf(context).width;
    final content = SizedBox(
      width: width,
      height: s.y(frameHeight - FigmaCanvas.statusBar - 34),
      child: Stack(clipBehavior: Clip.none, children: builder(c)),
    );

    final Widget body;
    if (frameHeight > 852 || alwaysBounce) {
      final keyboard = math.max(0.0, MediaQuery.viewInsetsOf(context).bottom - MediaQuery.paddingOf(context).bottom);
      body = Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: SingleChildScrollView(
          physics: alwaysBounce ? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()) : const BouncingScrollPhysics(),
          child: content,
        ),
      );
    } else {
      body = FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.topCenter, child: content);
    }

    final page = SafeArea(child: body);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: inShell ? ColoredBox(color: Colors.white, child: page) : Scaffold(backgroundColor: Colors.white, resizeToAvoidBottomInset: false, body: page),
    );
  }
}
