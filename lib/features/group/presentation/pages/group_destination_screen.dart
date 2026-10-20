import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../../family/presentation/widgets/family_colors.dart';
import '../../../family/presentation/widgets/family_icons.dart';
import '../../../field_mode/presentation/controllers/route_navigation_controller.dart';
import '../../../field_mode/presentation/widgets/route_format.dart';
import '../../../field_mode/presentation/widgets/route_path.dart';
import '../../../help_center/presentation/widgets/help_text.dart';
import '../../domain/entities/group_info.dart';
import '../controllers/group_controller.dart';
import '../l10n/group_destination_text.dart';
import '../widgets/group_meeting_place.dart';
import '../widgets/group_path_arrow.dart';

// -------------------------------------------------------------
// "وجهتك القادمة" لنقطة التجمع (Figma 111:6735) — كل الأرقام من Figma:
// "نقطة تجمع مجموعتك." (مستطيل أخضر 192,118) — الوصف — الكرت (18,209 360×264):
//   📌 نقطة وصولك : (اسم نقطة التجمع من المشرف) — 📍 يبعد عنك — 🕒 الوقت المتوقع (من موقعك الفعلي — بيتحدّثوا وإنت ماشي)
//   الرسم: الأفراد (نقطة تجمع مجموعتك) ← المسار المنقّط ← العلم (موقعك الحالي)
// "ماذا ستفعل عند الوصول؟" (155,497) — الشرح الرمادي — ابدأ الطريق (18,640)
// -------------------------------------------------------------
class GroupDestinationScreen extends StatefulWidget {
  final GroupMeetingPoint point;

  const GroupDestinationScreen({super.key, required this.point});

  @override
  State<GroupDestinationScreen> createState() => _GroupDestinationScreenState();
}

class _GroupDestinationScreenState extends State<GroupDestinationScreen> {
  static const _assets = 'assets/images/field_mode';

  late final _navigation = RouteNavigationController(groupMeetingPlace(widget.point))..start();

  @override
  void dispose() {
    _navigation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: GroupDestinationText.title(),
      titleRight: 348.5,
      chevronLeft: 367,
      headerDy: 0,
      titleSize: 24,
      body: (c) {
        final bold = c.style(14, FigmaWeight.sfBold, Colors.black);
        final semi = c.style(14, FigmaWeight.sfSemibold, Colors.black);
        final regular = c.style(14, FigmaWeight.sfRegular, Colors.black);
        // Poppins 400 14 بـ Figma — بالعربي 13.4 حتى يطلع بنفس عرض حبر Figma
        final label = c.style(13.4, FigmaWeight.poppinsRegular, Colors.black);

        // سطر بالكرت: العنوان SF Compact 790 والقيمة بعده — طرفه اليمين عند x326
        Widget row(String label, String value, double top, {TextStyle? valueStyle}) => c.rich(
              TextSpan(children: [TextSpan(text: label, style: bold), TextSpan(text: value, style: valueStyle ?? semi)]),
              left: 6,
              top: top,
              width: 320,
              height: 22,
            );

        return [
          // نقطة تجمع مجموعتك. (SF Compact 556 16 أبيض)
          c.box(left: 192, top: 118, width: 185, height: 37, color: FamilyColors.green, radius: 10),
          _pillText(c, GroupDestinationText.pill(), left: 200, top: 124, width: 157, style: c.style(16, FigmaWeight.semiBold, Colors.white)),
          HelpText.paragraph(c, GroupDestinationText.intro(), left: 15, top: 170, width: 361, lines: 1, style: c.style(14, FigmaWeight.semiBold, Colors.black)),

          // الكرت
          c.box(left: 18, top: 209, width: 360, height: 264, color: FamilyColors.cardFill, radius: 10, hasShadow: true),
          c.image('$_assets/ic_pushpin.png', left: 327, top: 232, width: 28, height: 28, color: Colors.black),
          row(GroupDestinationText.arrivalLabel(), widget.point.title, 235),
          c.image('$_assets/ic_distance.png', left: 334.56, top: 279, width: 16.88, height: 24, color: Colors.black),
          c.image('$_assets/ic_time.png', left: 331, top: 319, width: 24, height: 24, color: Colors.black),
          Positioned.fill(
            child: ListenableBuilder(
              listenable: _navigation,
              builder: (context, _) {
                final meters = _navigation.remainingMeters, seconds = _navigation.remainingSeconds;
                return Stack(
                  children: [
                    row(GroupDestinationText.distanceLabel(), meters == null ? GroupDestinationText.unknown() : RouteFormat.distance(meters), 272, valueStyle: regular),
                    row(GroupDestinationText.timeLabel(), seconds == null ? GroupDestinationText.unknown() : GroupDestinationText.about(RouteFormat.duration(seconds)), 315, valueStyle: regular),
                  ],
                );
              },
            ),
          ),

          // الرسم: نقطة تجمع مجموعتك ← المسار ← موقعك الحالي
          c.rect(left: 57.5, top: 372.5, width: 31.5, height: 22.7, child: IgnorePointer(child: FamilyGroupIcon(width: c.s.x(31.5), color: Colors.black))),
          c.text(GroupDestinationText.groupPoint(), left: 17, top: 400, width: 120, height: 22, align: TextAlign.center, style: label),
          ...RoutePath.build(c, shift: const Offset(1, -14), color: Colors.black, arrow: null),
          c.rect(left: 116, top: 376.5, width: 15, height: 17, child: IgnorePointer(child: GroupPathArrow(width: c.s.x(15)))),
          c.image('$_assets/ic_flag.png', left: 327, top: 388, width: 24.61, height: 28),
          c.text(GroupDestinationText.currentLocation(), left: 285, top: 416, width: 87, height: 22, align: TextAlign.center, style: label),

          // ماذا ستفعل عند الوصول؟
          c.box(left: 155, top: 497, width: 223, height: 37, color: FamilyColors.green, radius: 10),
          _pillText(c, GroupDestinationText.question(), left: 160, top: 502, width: 212, style: c.style(20, FigmaWeight.semiBold, Colors.white)),
          HelpText.paragraph(c, GroupDestinationText.outro(), left: 18, top: 547, width: 361, lines: 2, style: c.style(16, FigmaWeight.sfRegular, FamilyColors.grey)),

          c.button(GroupDestinationText.start(), left: 18, top: 640, figmaSpacing: true, onTap: () => GroupController.startRoute(context, widget.point)),
        ];
      },
    );
  }

  /// نص المستطيل الأخضر: طرفه بمكان Figma، ولو أطول من المستطيل (الإنجليزي) بيصغر جوّاه
  static Widget _pillText(FigmaCanvas c, String text, {required double left, required double top, required double width, required TextStyle style}) => c.rect(
        left: left,
        top: top,
        width: width,
        height: 22,
        child: IgnorePointer(
          child: Transform.translate(
            offset: Offset(0, c.s.y(FigmaCanvas.baselineFix)),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: Text(text, maxLines: 1, style: style)),
            ),
          ),
        ),
      );
}
