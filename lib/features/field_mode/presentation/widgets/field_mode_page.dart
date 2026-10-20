import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import 'back_title_header.dart';

// -------------------------------------------------------------
// الهيكل المشترك لشاشات وضع الميدان (إطار Figma 393×852):
// خلفية بيضا + هيدر (سهم رجوع وعنوان) + العناصر بأرقام Figma عن طريق FigmaCanvas.
// الشاشة ثابتة بدون سكرول — المساحة الآمنة بتساوي مساحة التصميم (759) عن طريق DesignScale،
// ولو جهاز قصير كتير ما بتكفيه، المحتوى كله بيصغر بنفس النسبة بدل ما يطلع برا الشاشة.
// -------------------------------------------------------------
class FieldModePage extends StatelessWidget {
  final String? title;
  final double backIconLeft;
  final double titleRight;
  final List<Widget> Function(FigmaCanvas c) builder;

  const FieldModePage({super.key, this.title, this.backIconLeft = 19, this.titleRight = 380, required this.builder});

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    final c = FigmaCanvas(s);
    final width = MediaQuery.sizeOf(context).width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width,
              height: s.y(DesignScale.designSafeHeight),
              child: Stack(
                // بعض العناصر بـ Figma بتنزل شوي تحت المساحة الآمنة (زر "انا ضائع" لـ y819) فما بنقصّها
                clipBehavior: Clip.none,
                children: [
                  ...builder(c),
                  // الهيدر مباشرة تحت شريط الحالة (y59) — آخر عنصر حتى يكون سهم الرجوع فوق كل شي
                  PositionedDirectional(
                    start: 0,
                    end: 0,
                    top: 0,
                    child: BackTitleHeader(scale: s, title: title, backIconLeft: backIconLeft, titleRight: titleRight),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
