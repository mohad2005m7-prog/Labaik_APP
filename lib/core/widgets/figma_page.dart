import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/figma_text.dart';
import '../utils/design_scale.dart';
import '../utils/figma_canvas.dart';
import 'figma_back_chevron.dart';

// -------------------------------------------------------------
// صفحة Figma (إطار 393×852) بهيدر "Frame 38": العنوان وبآخره سهم ">" للرجوع — بالإنجليزي بينعكسوا
// (الأدعية، الميزانية...) — [body]: باقي الشاشة بأرقام Figma (من تحت شريط الحالة y59)
// الشاشة ما بتتحرك إلا لما الكيبورد يغطي جزء منها: بيترك مساحة تحته والمحتوى بيتمرر لحتى الحقل يضل ظاهر
// (والإطار الأطول من 852 — [frameHeight] — بيتمرر بمقدار الفرق)
// مكان العنوان والسهم بيختلف شوي بين الإطارات ("Frame 38" عرضه 360 أو 372) — كل شاشة بتمرّر أرقامها المقاسة
// -------------------------------------------------------------
class FigmaPage extends StatelessWidget {
  final String title;
  final List<Widget> Function(FigmaCanvas c) body;

  /// طرف صندوق العنوان اليمين (حبر النص أقل بـ 1.5)
  final double titleRight;

  /// بداية سهم الرجوع (خطه 8.5×17 بسماكة 2 → حبره 10.5×19)
  final double chevronLeft;

  /// إزاحة الهيدر لتحت (بإطارات دائرة العائلة "Frame 38" من y61 بدل y59)
  final double headerDy;

  /// حجم خط العنوان (20 — وبشاشات دائرة العائلة 24)
  final double titleSize;

  /// طول إطار Figma — الأطول من 852 (مثل الشروط والأحكام 948) بيتمرر بمقدار الفرق بالظبط
  final double frameHeight;

  const FigmaPage({super.key, required this.title, required this.body, this.titleRight = 351, this.chevronLeft = 365.15, this.headerDy = 0, this.titleSize = 20, this.frameHeight = 852});

  static const _green = Color(0xFF1F3B2E);

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
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: s.y(frameHeight - 852 + DesignScale.designSafeHeight),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ...body(c),
                      // العنوان (SF Compact 790 20 أو [titleSize] #1F3B2E) + سهم الرجوع ">" بآخر الهيدر
                      c.text(title, left: titleRight - 336, top: 67 + headerDy - (titleSize - 20) / 2, width: 336, height: 26 + titleSize - 20, dy: 0.5, style: c.style(titleSize, FigmaWeight.sfBold, _green, lineHeight: null, letterSpacing: 0)),
                      figmaBackChevron(c, context, left: chevronLeft, top: 71.5 + headerDy, width: 8.5, height: 17, stroke: 2, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
