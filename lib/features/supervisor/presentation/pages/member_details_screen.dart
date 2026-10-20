import 'package:flutter/material.dart';

import '../../../../core/l10n/tx.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../domain/entities/group_member.dart';
import '../controllers/supervisor_controller.dart';
import '../l10n/member_details_text.dart';
import '../widgets/supervisor_colors.dart';
import '../widgets/supervisor_page.dart';
import '../widgets/supervisor_widgets.dart';

// -------------------------------------------------------------
// صفحة أحد الأعضاء — مطابقة لـ Figma "صفحة احد الاعضاء" (234:3268)
// الصورة 80 (الضغط عليها بيكبّرها) والاسم ورقم المعتمر والإيميل، كرت "معلومات إضافية"، وزر "تواصل"
// المعلومة الناقصة بتطلع "—"، والإيميل بيختفي لو ما في
// -------------------------------------------------------------
class MemberDetailsScreen extends StatelessWidget {
  final GroupMember member;

  const MemberDetailsScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final m = member;
    final photo = m.photo;
    final heroTag = 'member-${m.id}';
    return SupervisorPage(
      builder: (c) => [
        c.rect(left: 157, top: 117, width: 80, height: 80, child: SupPhoto(photo: photo, size: c.s.x(80), name: m.name, heroTag: heroTag)),
        if (photo != null) c.tapArea(left: 157, top: 117, width: 80, height: 80, onTap: () => SupervisorController.viewPhoto(context, photo: photo, heroTag: heroTag, title: m.name)),
        c.text(m.name, left: 96, top: 204, width: 201, height: 19, align: TextAlign.center, style: supText(c, 16, FigmaWeight.sfBold, SupColors.green)),
        // رقم المعتمر لسا مش بالسيرفر — السطر بيطلع لما يوصل
        if (m.number != null)
          c.text(MemberDetailsText.pilgrimNumber(m.number!, female: m.gender == MemberGender.female), left: 96, top: 229.5, width: 201, height: 22, align: TextAlign.center, style: c.style(16, FigmaWeight.poppinsRegular, SupColors.green)),
        if (m.email != null) c.rect(left: 40, top: 260, width: 313, height: 22, child: _emailRow(c, m.email!)),

        // معلومات إضافية
        c.box(left: 16, top: 315, width: 361, height: 177, color: SupColors.cardFill, radius: 10, hasShadow: true),
        c.text(MemberDetailsText.moreInfo(), left: 112, top: 339, width: 240, height: 24, style: supText(c, 20, FigmaWeight.sfBold, SupColors.green)),
        ..._info(c, 377, MemberDetailsText.nationality, m.nationality),
        ..._info(c, 411.5, MemberDetailsText.health, m.health),
        ..._info(c, 447, MemberDetailsText.notes, m.notes),

        c.button(MemberDetailsText.contact(), left: 16, top: 524, onTap: () => SupervisorController.comingSoon(context)),
        ...supBackArrow(c, context, left: 19, top: 68, color: Colors.black),
      ],
    );
  }

  // أيقونة الإيميل ثم الإيميل (خط النظام اللاتيني) — المجموعة كلها بنص الشاشة
  Widget _emailRow(FigmaCanvas c, String email) {
    final s = c.s;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: TextDirection.ltr,
      children: [
        Image.asset('$supAssets/ic_mail_member.png', width: s.x(24), height: s.x(22)),
        SizedBox(width: s.x(7)),
        Flexible(
          child: Text(
            email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr,
            style: TextStyle(fontSize: s.x(16), color: SupColors.green, letterSpacing: s.x(0.6), height: 1.2),
          ),
        ),
      ],
    );
  }

  // العنوان SemiBold 16 يمين (طرفه x352) والقيمة SF Compact Regular 14 يسار (طرفها x96.5)
  List<Widget> _info(FigmaCanvas c, double top, Tx label, String? value) {
    return [
      c.text(label(), left: 200, top: top, width: 152, height: 22, style: c.style(16, FigmaWeight.semiBold, SupColors.green)),
      c.text(value ?? '—', left: 16, top: top + 0.5, width: 80.5, height: 19, style: supText(c, 14, FigmaWeight.sfRegular, SupColors.green)),
    ];
  }
}
