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
// "مشاركة موقعك مع عائلتك" (Figma 111:5228): كرت (16,173 361×152) فيه الدبوس بحلقتين والشرح بـ 3 سطور
//   مشاركة موقعي (16,357) → صلاحية الموقع → السيرفر → موقعي الفعلي بينبعت لعائلتي → أفراد عائلتي
//   ليس الآن (16,431 أبيض بحد أسود) → بدون مشاركة → أفراد عائلتي
// -------------------------------------------------------------
class FamilyShareLocationScreen extends StatefulWidget {
  final FamilyCircle circle;

  const FamilyShareLocationScreen({super.key, required this.circle});

  @override
  State<FamilyShareLocationScreen> createState() => _FamilyShareLocationScreenState();
}

class _FamilyShareLocationScreenState extends State<FamilyShareLocationScreen> {
  /// الزر اللي عم يستنى (true = مشاركة، false = ليس الآن)
  bool? _busy;

  Future<void> _run(bool share) async {
    if (_busy != null) return;
    setState(() => _busy = share);
    if (share) {
      await FamilyController.shareMyLocation(context);
    } else {
      await FamilyController.notNow(context);
    }
    if (mounted) setState(() => _busy = null);
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: FamilyFoundText.shareTitle(),
      titleRight: 344,
      chevronLeft: 367,
      headerDy: 2,
      titleSize: 24,
      body: (c) => [
        HelpText.paragraph(c, FamilyFoundText.shareDescription(), left: 99, top: 119, width: 278, lines: 1, style: c.style(14, FigmaWeight.semiBold, Colors.black)),
        c.box(left: 16, top: 173, width: 361, height: 152, color: FamilyColors.cardFill, radius: 10, hasShadow: true),
        c.rect(left: 174.5, top: 186, width: 43.5, height: 43.5, child: IgnorePointer(child: LocationRingsIcon(size: c.s.x(43.5)))),
        HelpText.paragraph(c, FamilyFoundText.shareNote(), left: 28, top: 247.5, width: 337, lines: 3, align: TextAlign.center, style: c.style(14, FigmaWeight.semiBold, Colors.black)),
        familyButton(c, FamilyFoundText.shareMine(), left: 16, top: 357, busy: _busy == true, onTap: () => _run(true)),
        familyButton(c, FamilyFoundText.notNow(), left: 16, top: 431, outlined: true, borderColor: Colors.black, busy: _busy == false, onTap: () => _run(false)),
      ],
    );
  }
}
