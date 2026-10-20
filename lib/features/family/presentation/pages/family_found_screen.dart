import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../../help_center/presentation/widgets/help_text.dart';
import '../../domain/entities/family_circle.dart';
import '../controllers/family_controller.dart';
import '../l10n/family_found_text.dart';
import '../widgets/family_button.dart';
import '../widgets/family_colors.dart';
import '../widgets/family_icons.dart';

// -------------------------------------------------------------
// "تم العثور على دائرة عائلتك" (Figma 111:5199): كرت الدائرة (16,173 361×152 — أيقونة العائلة واسمها من السيرفر)
// "انضمام إلى الدائرة" (11.5,411) → الانضمام بالسيرفر → مشاركة موقعك مع عائلتك
// -------------------------------------------------------------
class FamilyFoundScreen extends StatefulWidget {
  final FamilyCircleSummary circle;

  const FamilyFoundScreen({super.key, required this.circle});

  @override
  State<FamilyFoundScreen> createState() => _FamilyFoundScreenState();
}

class _FamilyFoundScreenState extends State<FamilyFoundScreen> {
  bool _joining = false;

  Future<void> _join() async {
    if (_joining) return;
    setState(() => _joining = true);
    await FamilyController.join(context, widget.circle);
    if (mounted) setState(() => _joining = false);
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: FamilyFoundText.title(),
      titleRight: 350.5,
      chevronLeft: 368,
      headerDy: 2,
      titleSize: 24,
      body: (c) => [
        HelpText.paragraph(c, FamilyFoundText.description(), left: 71, top: 119, width: 306, lines: 1, style: c.style(14, FigmaWeight.semiBold, Colors.black)),
        c.box(left: 16, top: 173, width: 361, height: 152, color: FamilyColors.cardFill, radius: 10, hasShadow: true),
        // "Vector" العائلة (حبره 48.35×34.8 من 174.9,203.9)
        c.rect(left: 174.9, top: 203.9, width: 48.35, height: 34.8, child: IgnorePointer(child: FamilyGroupIcon(width: c.s.x(48.35), color: FamilyColors.green))),
        c.text(widget.circle.name, left: 29.5, top: 257, width: 337, height: 28, dy: 0, align: TextAlign.center, style: c.style(19, FigmaWeight.semiBold, FamilyColors.green, lineHeight: null, letterSpacing: 0)),
        HelpText.paragraph(c, FamilyFoundText.stayInTouch(), left: 28, top: 357, width: 337, lines: 1, align: TextAlign.center, style: c.style(14, FigmaWeight.semiBold, Colors.black)),
        familyButton(c, FamilyFoundText.join(), left: 11.5, top: 411, busy: _joining, onTap: _join),
      ],
    );
  }
}
