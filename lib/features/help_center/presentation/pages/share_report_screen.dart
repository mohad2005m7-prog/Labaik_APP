import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_page.dart';
import '../controllers/help_center_controller.dart';
import '../cubits/lost_child_report_cubit.dart';
import '../l10n/share_report_text.dart';
import '../widgets/help_colors.dart';
import '../widgets/help_text.dart';

// -------------------------------------------------------------
// "مشاركة البلاغ مع المستخدمين القريبين" (Figma 111:6094):
// كرت 361×382 (#4C7A75 10% وظل) فيه أيقونة المجموعة 50.67×38 والدرع 51×51 والشرح (SF Compact 457 14 #717171)
// نعم , مشاركة البلاغ → البلاغ بيروح للسيرفر → تم إرسال البلاغ بنجاح! — لا , شكرا → بيلغي البلاغ ← مركز المساعدة
// -------------------------------------------------------------
class ShareReportScreen extends StatelessWidget {
  const ShareReportScreen({super.key});

  static const _icons = 'assets/images/help';

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: ShareReportText.title(),
      titleRight: 349.5,
      chevronLeft: 367,
      body: (c) {
        final grey = c.style(14, FigmaWeight.sfRegular, HelpColors.grey);
        return [
          HelpText.paragraph(c, ShareReportText.description(), left: 16, top: 115, width: 361, lines: 2, style: c.style(14, FigmaWeight.semiBold, Colors.black)),
          c.box(left: 16, top: 171, width: 361, height: 382, color: HelpColors.cardFill, radius: 10, hasShadow: true),
          c.image('$_icons/ic_family_big.png', left: 170, top: 207, width: 51, height: 38, color: HelpColors.green),
          HelpText.paragraph(c, ShareReportText.nearby(), left: 17, top: 292, width: 360, lines: 2, align: TextAlign.center, style: grey),
          c.image('$_icons/ic_shield.png', left: 170, top: 367, width: 51, height: 51, color: HelpColors.green),
          HelpText.line(c, ShareReportText.beforeTitle(), right: 233, top: 434, boxWidth: 74, room: 300, align: TextAlign.center, style: c.style(14, FigmaWeight.semiBold, HelpColors.green)),
          HelpText.paragraph(c, ShareReportText.before(), left: 18, top: 465, width: 358, lines: 2, align: TextAlign.center, style: grey),
          c.button(ShareReportText.yes(), left: 17, top: 597, figmaSpacing: true, onTap: () => HelpCenterController.shareReport(context)),
          c.button(ShareReportText.no(), left: 17, top: 663, outlined: true, figmaSpacing: true, onTap: () => HelpCenterController.cancelReport(context)),
          // أثناء الإرسال: دوّارة مكان نص الزر وما بينضغط شي
          BlocBuilder<LostChildReportCubit, LostChildFormState>(
            buildWhen: (a, b) => a.submitting != b.submitting,
            builder: (context, state) => !state.submitting
                ? const SizedBox.shrink()
                : c.rect(
                    left: 17,
                    top: 597,
                    width: 361,
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: HelpColors.green, borderRadius: BorderRadius.circular(c.s.x(14))),
                      child: Center(
                        child: SizedBox.square(
                          dimension: c.s.x(24),
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        ),
                      ),
                    ),
                  ),
          ),
        ];
      },
    );
  }
}
