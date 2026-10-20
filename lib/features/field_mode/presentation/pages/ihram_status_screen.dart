import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../data/models/field_mode_data.dart';
import '../../data/models/ihram_status.dart';
import '../controllers/field_mode_controller.dart';
import '../l10n/ihram_status_text.dart';
import '../widgets/field_colors.dart';
import '../widgets/field_mode_page.dart';

// -------------------------------------------------------------
// شاشة "ما حالة إحرامك؟" — مطابقة لـ Figma (21:1025)
// الاختيار إجباري قبل "متابعة" (نفس شاشات إعداد الرحلة)، والكرت المختار حدّه 1.5 بدل 1
// (نفس IconOptionCard بالمشروع)
// -------------------------------------------------------------
class IhramStatusScreen extends StatefulWidget {
  const IhramStatusScreen({super.key});

  @override
  State<IhramStatusScreen> createState() => _IhramStatusScreenState();
}

class _IhramStatusScreenState extends State<IhramStatusScreen> {
  final _data = FieldModeData.instance;

  static const _assets = 'assets/images/field_mode';

  @override
  Widget build(BuildContext context) {
    return FieldModePage(
      title: IhramStatusText.title(),
      builder: (c) => [
        // SF Compact 556 14 أسود — طرفه عند x377
        c.text(IhramStatusText.description(), left: 82, top: 117, width: 295, height: 22, style: c.style(14, FigmaWeight.semiBold, Colors.black)),

        ..._option(
          c,
          status: IhramStatus.notYet,
          top: 171,
          icon: 'ic_not_muhrim.png',
          title: IhramStatusText.notMuhrimTitle(),
          titleLeft: 224,
          titleWidth: 90,
          desc: IhramStatusText.notMuhrimDesc(),
          descLeft: 161,
          descWidth: 153,
        ),
        ..._option(
          c,
          status: IhramStatus.muhrim,
          top: 271,
          icon: 'ic_muhrim.png',
          title: IhramStatusText.muhrimTitle(),
          titleLeft: 253,
          titleWidth: 61,
          desc: IhramStatusText.muhrimDesc(),
          descLeft: 73,
          descWidth: 241,
        ),

        // متابعة: 361×50 عند x17 y387
        c.button(IhramStatusText.continueLabel(), left: 17, top: 387, onTap: () => FieldModeController.continueFromIhramStatus(context)),
      ],
    );
  }

  // كرت الاختيار: 361×84 — #4C7A75 10% — حد #1F3B2E 1 (Inside) — radius 10
  // مربع الأيقونة 40×40 أبيض بحد 1 عند x322 (top+22) والأيقونة 24×24 جوّاه
  // العنوان SF Compact 556 20 (top+16) والوصف SF Compact 457 14 (top+46) — طرفهم عند x314
  List<Widget> _option(
    FigmaCanvas c, {
    required IhramStatus status,
    required double top,
    required String icon,
    required String title,
    required double titleLeft,
    required double titleWidth,
    required String desc,
    required double descLeft,
    required double descWidth,
  }) {
    final selected = _data.ihramStatus == status;
    return [
      c.box(
        left: 17,
        top: top,
        width: 361,
        height: 84,
        color: FieldColors.cardFill,
        radius: 10,
        borderColor: selected ? FieldColors.green : null,
        borderWidth: 1.5,
      ),
      c.box(left: 322, top: top + 22, width: 40, height: 40, color: Colors.white, borderColor: FieldColors.green),
      c.image('$_assets/$icon', left: 330, top: top + 30, width: 24, height: 24),
      c.text(title, left: titleLeft, top: top + 16, width: titleWidth, height: 22, style: c.style(20, FigmaWeight.semiBold, FieldColors.green)),
      c.text(desc, left: descLeft, top: top + 46, width: descWidth, height: 22, style: c.style(14, FigmaWeight.sfRegular, FieldColors.green)),
      c.tapArea(left: 17, top: top, width: 361, height: 84, onTap: () => setState(() => _data.ihramStatus = status)),
    ];
  }
}
