import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../domain/entities/group_preview.dart';
import '../controllers/group_controller.dart';
import '../l10n/group_join_text.dart';

// -------------------------------------------------------------
// "تم الانضمام بنجاح !" (Figma) — بدون هيدر:
//   العنوان (134) — الوصف #4C7A75 252×44 (187) — ✓ 148×148 (122.5,245) — رؤية المجموعة (17,426)
// -------------------------------------------------------------
class GroupJoinedScreen extends StatelessWidget {
  final GroupPreview group;

  const GroupJoinedScreen({super.key, required this.group});

  static const _green = Color(0xFF1F3B2E);
  static const _accent = Color(0xFF4C7A75);

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    final c = FigmaCanvas(s);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              c.text(GroupJoinText.joinedTitle(), left: 15, top: 134, width: 363, height: 29, align: TextAlign.center, dy: 0, style: c.style(24, FigmaWeight.sfBold, _green, lineHeight: null, letterSpacing: 0)),
              c.text(
                GroupJoinText.joinedBody(group.name, group.memberCount),
                left: 70,
                top: 186,
                width: 252,
                height: 44,
                align: TextAlign.center,
                style: c.style(15, FigmaWeight.semiBold, _accent, letterSpacing: -0.41),
              ),
              c.image('assets/images/tawaf/ic_done.png', left: 122.5, top: 245, width: 148, height: 148, color: _green),
              c.button(GroupJoinText.viewGroup(), left: 17, top: 426, figmaSpacing: true, onTap: () => GroupController.showMembers(context)),
            ],
          ),
        ),
      ),
    );
  }
}
