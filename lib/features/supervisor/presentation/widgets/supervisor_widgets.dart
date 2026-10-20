import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import 'supervisor_colors.dart';

// -------------------------------------------------------------
// عناصر مشتركة بين شاشات المشرف (كلها بمقاسات Figma)
// -------------------------------------------------------------

const supAssets = 'assets/images/supervisor';

/// ستايل نصوص SF Compact بـ Figma (line height "auto")
TextStyle supText(FigmaCanvas c, double size, double weight, Color color) => c.style(size, weight, color, lineHeight: null, letterSpacing: 0);

/// سهم الرجوع (Back Icon 18×24 — منطقة الضغط 32×42)
/// [trailing] = false: يسار الشاشة "<" باللغتين (زي هيدر وضع الميدان)
/// [trailing] = true: يمين الشاشة ">" بالعربي (تفاصيل الإعلان، تعديل الملف، الإعدادات) — وبالإنجليزي بينعكس لليسار "<"
List<Widget> supBackArrow(FigmaCanvas c, BuildContext context, {required double left, required double top, Color color = SupColors.green, bool trailing = false, VoidCallback? onTap}) {
  final s = c.s;
  void back() => onTap != null ? onTap() : Navigator.maybePop(context);
  final icon = Image.asset('assets/images/field_mode/ic_back.png', width: s.x(18), height: s.x(24), color: color, colorBlendMode: BlendMode.srcIn);
  final iconTop = s.y(top - c.originTop + 12) - s.x(12);
  final tapTop = s.y(top - 9 - c.originTop);

  if (!trailing) {
    return [
      Positioned(left: s.x(left), top: iconTop, child: IgnorePointer(child: icon)),
      Positioned(left: s.x(left - 7), top: tapTop, width: s.x(32), height: s.y(42), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: back)),
    ];
  }
  // بالعربي السهم بيتأشر لليمين (مقلوب)، وبالإنجليزي بيرجع "<" يسار الشاشة
  return [
    PositionedDirectional(
      start: s.x(393 - left - 18),
      top: iconTop,
      child: IgnorePointer(
        child: Builder(builder: (context) => Transform.flip(flipX: Directionality.of(context) == TextDirection.rtl, child: icon)),
      ),
    ),
    PositionedDirectional(start: s.x(393 - left - 18 - 7), top: tapTop, width: s.x(32), height: s.y(42), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: back)),
  ];
}

/// سهم "التالي" بالكروت والقوائم: نفس أيقونة الرجوع 18×24 ("<" بالعربي، وبالإنجليزي بينعكس ">" للجهة الثانية)
List<Widget> supChevron(FigmaCanvas c, {required double left, required double top, Color color = SupColors.green}) {
  return [c.image('assets/images/field_mode/ic_back.png', left: left, top: top, width: 18, height: 24, flipInLtr: true, color: color)];
}

/// كل الصور الشخصية المصغّرة بتنفك بنفس الحجم — فالقوائم والصفحات والعارض بيشاركوا نسخة وحدة بالذاكرة
/// (العارض بيعرضها فوراً لحد ما تجهز الصورة الكاملة)
const supThumbPixels = 320;

/// مزود الصورة حسب مصدرها: asset تجريبي / رابط من الباك إند / ملف على الجهاز
/// [cacheWidth]: بتنفك بحجم عرضها بالشاشة بس (أسرع وأخف)
ImageProvider supImageProvider(String photo, {int? cacheWidth}) {
  final ImageProvider provider = photo.startsWith('http')
      ? NetworkImage(photo)
      : photo.startsWith('assets/')
          ? AssetImage(photo)
          : FileImage(File(photo));
  return cacheWidth == null ? provider : ResizeImage(provider, width: cacheWidth, policy: ResizeImagePolicy.fit);
}

/// صورة شخص دائرية. لو ما في صورة: دايرة رمادية (#D9D9D9) فيها أول حرف من الاسم (أو أيقونة شخص)
/// [heroTag]: للانتقال الناعم لعارض الصور (تكبير الصورة زي انستغرام)
class SupPhoto extends StatelessWidget {
  final String? photo;
  final double size;
  final String? name;
  final Object? heroTag;

  const SupPhoto({super.key, required this.photo, required this.size, this.name, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final p = photo;
    Widget child;
    if (p == null || p.isEmpty) {
      child = _SupInitial(name: name, size: size);
    } else {
      child = Image(
        image: supImageProvider(p, cacheWidth: supThumbPixels),
        filterQuality: FilterQuality.medium,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _SupInitial(name: name, size: size),
      );
      if (heroTag != null) child = Hero(tag: heroTag!, flightShuttleBuilder: supPhotoFlight, child: child);
    }
    // دايرة بحجمها حتى لو المستطيل حولها مش مربع بالظبط (sx ≠ sy)
    return Center(child: SizedBox(width: size, height: size, child: ClipOval(child: child)));
  }
}

/// أثناء التكبير/التصغير: الدايرة بتتحول لمربع (والعكس) بنعومة
Widget supPhotoFlight(BuildContext flightContext, Animation<double> animation, HeroFlightDirection direction, BuildContext fromContext, BuildContext toContext) {
  final hero = (direction == HeroFlightDirection.push ? toContext.widget : fromContext.widget) as Hero;
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) => LayoutBuilder(
      builder: (context, box) => ClipRRect(
        borderRadius: BorderRadius.circular(box.biggest.shortestSide / 2 * (1 - Curves.easeOut.transform(animation.value))),
        child: child,
      ),
    ),
    child: hero.child,
  );
}

class _SupInitial extends StatelessWidget {
  final String? name;
  final double size;

  const _SupInitial({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final letter = (name ?? '').trim().isEmpty ? null : name!.trim().characters.first;
    return Container(
      width: size,
      height: size,
      color: SupColors.avatarPlaceholder,
      alignment: Alignment.center,
      child: letter == null
          ? Icon(Icons.person_rounded, size: size * 0.6, color: Colors.white)
          : Text(
              letter,
              style: TextStyle(fontFamily: 'NotoSansArabic', fontVariations: const [FontVariation('wght', FigmaWeight.semiBold)], fontSize: size * 0.42, color: SupColors.green, height: 1.2),
            ),
    );
  }
}

/// تبويبات iOS (Segmented Control): خلفية رمادية radius 9 — المختار أخضر radius 7 مع ظل — فواصل بين غير المختارة
/// مربوطة بـ [controller] (PageView): المؤشر بيمشي مع السحب، والضغط على تبويب بينقل الصفحة
/// الحجم من المستطيل اللي حوله (c.rect)، والتبويب الأول بيبدأ من البداية (يمين بالعربي)
class SupSegmented extends StatelessWidget {
  final DesignScale s;
  final List<String> labels;
  final PageController controller;
  final Color fill;
  final TextStyle labelStyle;

  const SupSegmented({super.key, required this.s, required this.labels, required this.controller, required this.labelStyle, this.fill = SupColors.searchFill});

  void _go(int i) => controller.animateToPage(i, duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth, h = box.maxHeight;
          final inset = s.x(2);
          final segment = (w - 2 * inset) / labels.length;
          return DecoratedBox(
            decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(s.x(8.91))),
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                // أثناء إعادة البناء ممكن يكون في أكتر من PageView لحظياً — بنقرأ الموضع بس لما يكون واحد جاهز
                var page = controller.initialPage.toDouble();
                if (controller.positions.length == 1 && controller.position.haveDimensions) page = controller.page ?? page;
                final selected = page.round();
                return Stack(
                  children: [
                    // الفواصل (بتختفي جنب التبويب المختار)
                    for (var i = 1; i < labels.length; i++)
                      if (i != selected && i != selected + 1)
                        PositionedDirectional(
                          start: w * i / labels.length - s.x(0.5),
                          top: (h - s.y(16)) / 2,
                          width: s.x(1),
                          height: s.y(16),
                          child: const ColoredBox(color: SupColors.segmentSeparator),
                        ),
                    PositionedDirectional(
                      start: inset + segment * page.clamp(0, labels.length - 1),
                      top: inset,
                      width: segment,
                      height: h - 2 * inset,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: SupColors.green,
                          borderRadius: BorderRadius.circular(s.x(6.93)),
                          boxShadow: [
                            BoxShadow(color: const Color(0x1F000000), offset: Offset(0, s.y(3)), blurRadius: s.x(8)),
                            BoxShadow(color: const Color(0x0A000000), offset: Offset(0, s.y(3)), blurRadius: s.x(1)),
                          ],
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      start: inset,
                      end: inset,
                      top: 0,
                      bottom: 0,
                      child: Row(
                        children: [
                          for (var i = 0; i < labels.length; i++)
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _go(i),
                                // Figma بيرسم النص أوطى بـ 1 من نص التبويب (مقاس)
                                child: Transform.translate(
                                  offset: Offset(0, s.y(1)),
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(labels[i], maxLines: 1, style: labelStyle.copyWith(color: i == selected ? Colors.white : labelStyle.color)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// حقل البحث (SearchField بـ iOS): 345×36 — #EEEEEF radius 10
/// النص بصندوق 285 بيبدأ بعد 8 من البداية، والعدسة بعده بـ 6 (نفس ترتيب Figma)
class SupSearchField extends StatelessWidget {
  final DesignScale s;
  final String hint;
  final double fontSize;
  final ValueChanged<String> onChanged;

  const SupSearchField({super.key, required this.s, required this.hint, required this.onChanged, this.fontSize = 16});

  @override
  Widget build(BuildContext context) {
    final hintStyle = figmaText(s, size: fontSize, weight: FigmaWeight.sfRegular, color: SupColors.secondaryLabel, lineHeight: 22, letterSpacing: 0);
    return DecoratedBox(
      decoration: BoxDecoration(color: SupColors.searchFill, borderRadius: BorderRadius.circular(s.x(10))),
      child: Stack(
        children: [
          // بالعربي: النص من x8 لـ x293 بالحقل (من اليسار) والعدسة من x299 — يعني من البداية (اليمين) 52 و 30.37
          PositionedDirectional(
            start: s.x(345 - 8 - 285),
            width: s.x(285),
            top: 0,
            bottom: 0,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextField(
                onChanged: onChanged,
                cursorColor: SupColors.green,
                textAlignVertical: TextAlignVertical.center,
                textInputAction: TextInputAction.search,
                style: hintStyle.copyWith(color: Colors.black),
                decoration: InputDecoration.collapsed(hintText: hint, hintStyle: hintStyle),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
            ),
          ),
          PositionedDirectional(
            start: s.x(345 - 8 - 285 - 6 - 15.63),
            top: 0,
            bottom: 0,
            child: IgnorePointer(child: Center(child: Image.asset('$supAssets/ic_search.png', width: s.x(15.63), height: s.x(15.78)))),
          ),
        ],
      ),
    );
  }
}

/// تمرير عمودي بارتداد خفيف — بيتحرك حتى لو المحتوى أقصر من الشاشة (زي iOS)
const supScrollPhysics = BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

/// بيحافظ على صفحة PageView لما يسحب لغيرها (ما بتنبني من جديد كل مرة)
class SupKeepAlive extends StatefulWidget {
  final Widget child;

  const SupKeepAlive({super.key, required this.child});

  @override
  State<SupKeepAlive> createState() => _SupKeepAliveState();
}

class _SupKeepAliveState extends State<SupKeepAlive> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
