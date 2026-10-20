import 'package:flutter/material.dart';

import '../../../../core/l10n/tx.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../domain/entities/announcement.dart';
import '../controllers/supervisor_controller.dart';
import '../l10n/announcement_details_text.dart';
import '../widgets/supervisor_colors.dart';
import '../widgets/supervisor_page.dart';
import '../widgets/supervisor_widgets.dart';

// -------------------------------------------------------------
// تفاصيل الإعلان — مطابقة لـ Figma "الإعلانات" (234:3445) + نص الإعلان (234:3614)
// سهم الرجوع يمين ">" بالتصميم. دائرة البوق، العنوان، كرت (المجموعة المستهدفة/التاريخ/الوقت)،
// كرت نص الإعلان (بيتمرر لو النص أطول، وتحته الصورة المرفقة إن وجدت)، وزر "العودة إلى الإعلانات"
// ملاحظة: "إعلان مهم للمجموعة" نص ثابت بـ Figma تحت العنوان — منقول زي ما هو
// -------------------------------------------------------------
class AnnouncementDetailsScreen extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementDetailsScreen({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final a = announcement;
    return SupervisorPage(
      builder: (c) => [
        c.text(AnnouncementDetailsText.title(), left: 100, top: 67.5, width: 246, height: 24, style: supText(c, 20, FigmaWeight.sfBold, SupColors.green)),
        // الدائرة 116 والبوق
        c.box(left: 138.5, top: 133, width: 116, height: 116, color: SupColors.cardFill, radius: 58, hasShadow: true),
        c.image('$supAssets/ic_megaphone_large.png', left: 159, top: 152, width: 78, height: 78),
        c.text(a.title, left: 16, top: 265, width: 361, height: 24, align: TextAlign.center, style: supText(c, 20, FigmaWeight.semiBold, SupColors.green)),
        c.text(AnnouncementDetailsText.forGroup(), left: 16, top: 295.5, width: 361, height: 19, align: TextAlign.center, style: supText(c, 16, FigmaWeight.poppinsRegular, SupColors.green)),

        // المجموعة المستهدفة / تاريخ الإرسال / وقت الإرسال — صفوف 53 بينها خط #AEB0B0
        c.box(left: 16, top: 332, width: 361, height: 159, color: SupColors.cardFill, radius: 10, hasShadow: true),
        ..._infoRow(c, 332, AnnouncementDetailsText.targetGroup, a.target, 'ic_users_detail', const Rect.fromLTWH(338.5, 19, 20.5, 18.5), right: 327.5, labelTop: 6.5, valueTop: 26.5),
        c.box(left: 24, top: 385, width: 345, height: 1, color: SupColors.divider),
        ..._infoRow(c, 385, AnnouncementDetailsText.sendDate, a.dateLabel, 'ic_calendar_clock_detail', const Rect.fromLTWH(338, 15, 24, 24), right: 330, labelTop: 6.5, valueTop: 29.5),
        c.box(left: 24, top: 438, width: 345, height: 1, color: SupColors.divider),
        ..._infoRow(c, 438, AnnouncementDetailsText.sendTime, a.timeLabel, 'ic_clock', const Rect.fromLTWH(337, 16.5, 24, 23.5), right: 328, labelTop: 7.5, valueTop: 29),

        // نص الإعلان
        c.box(left: 16, top: 515, width: 361, height: 201, color: SupColors.cardFill, radius: 10, hasShadow: true),
        c.rect(left: 34, top: 539, width: 319, height: 168, child: _body(context, c, a)),

        c.box(left: 16, top: 748, width: 361, height: 50, color: SupColors.green, radius: 14),
        c.text(AnnouncementDetailsText.back(), left: 16, top: 762, width: 361, height: 22, align: TextAlign.center, dy: 0, style: c.style(19.25, FigmaWeight.semiBold, Colors.white)),
        c.tapArea(left: 16, top: 748, width: 361, height: 50, onTap: () => Navigator.maybePop(context)),
        ...supBackArrow(c, context, left: 358, top: 68, trailing: true),
      ],
    );
  }

  // العنوان Regular 12 فوق والقيمة SemiBold 14 تحت — طرفهم [right] — والأيقونة يمين
  List<Widget> _infoRow(FigmaCanvas c, double top, Tx label, String value, String icon, Rect iconRect, {required double right, required double labelTop, required double valueTop}) {
    return [
      c.text(label(), left: 100, top: top + labelTop, width: right - 100, height: 15, style: supText(c, 12, FigmaWeight.poppinsRegular, SupColors.green)),
      c.text(value, left: 100, top: top + valueTop, width: right - 100, height: 17, style: supText(c, 14, FigmaWeight.semiBold, SupColors.green)),
      c.image('$supAssets/$icon.png', left: iconRect.left, top: top + iconRect.top, width: iconRect.width, height: iconRect.height),
    ];
  }

  // "نص الإعلان" (SemiBold 14) ثم سطر فاضي ثم النص (SF Compact Regular 14) وسطر الختام عريض — line height auto
  Widget _body(BuildContext context, FigmaCanvas c, Announcement a) {
    final bold = supText(c, 14, FigmaWeight.semiBold, SupColors.green);
    final regular = supText(c, 14, FigmaWeight.sfRegular, SupColors.green);
    final attachment = a.attachment;
    final heroTag = 'attachment-${a.id}';
    return SingleChildScrollView(
      physics: supScrollPhysics,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${AnnouncementDetailsText.body()}\n\n', style: bold),
                TextSpan(text: a.body, style: regular),
                if (a.closing != null) TextSpan(text: '\n\n${a.closing}', style: bold),
              ],
            ),
            textAlign: TextAlign.start,
          ),
          if (attachment != null) ...[
            SizedBox(height: c.s.y(12)),
            GestureDetector(
              onTap: () => SupervisorController.viewPhoto(context, photo: attachment, heroTag: heroTag, title: a.title, avatar: false),
              child: Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(c.s.x(10)),
                  child: Image(
                    image: supImageProvider(attachment, cacheWidth: (c.s.x(319) * MediaQuery.devicePixelRatioOf(context)).round()),
                    height: c.s.x(160),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
