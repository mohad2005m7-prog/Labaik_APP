import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../l10n/family_members_text.dart';
import 'family_colors.dart';
import 'family_icons.dart';

/// [stopSharing]/[startSharing]: بكرتي أنا بس (مش بـ Figma)
enum MemberAction { chat, location, remove, stopSharing, startSharing }

// -------------------------------------------------------------
// قائمة الثلاث نقاط (Figma "Group 82" 145×106 — 111:5373): أبيض بحد أسود 1 و radius 7، 3 صفوف 35.3 بينها خط:
// بدء محادثة 💬 / عرض الموقع 📍 / حذف من الدائرة 🗑 — النص بأول السطر (هامش 7) والأيقونة بآخره (مركزها 29.5 من الطرف)
// بتطلع جنب الثلاث نقاط (بعدها بـ 15.6 وأوطى بـ 4.2 زي Figma) — [actions]: الخيارات المسموحة لهالفرد
// -------------------------------------------------------------
/// [placement]: مكانها من الثلاث نقاط بـ Figma (العائلة 111:5373 — المجموعة 111:6394)
Future<MemberAction?> showMemberMenu(BuildContext context, {required Rect anchor, required List<MemberAction> actions, MenuPlacement placement = MenuPlacement.family}) {
  return showGeneralDialog<MemberAction>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 120),
    transitionBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: child),
    pageBuilder: (context, _, _) => _MenuLayout(anchor: anchor, actions: actions, placement: placement),
  );
}

class _MenuLayout extends StatelessWidget {
  final Rect anchor;
  final List<MemberAction> actions;

  final MenuPlacement placement;

  const _MenuLayout({required this.anchor, required this.actions, required this.placement});


  static const _row = 35.3;

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    final screen = MediaQuery.sizeOf(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final width = s.x(placement.width);
    final height = s.y(_row) * actions.length;
    // بالعربي يمين الثلاث نقاط، وبالإنجليزي (الشاشة معكوسة) يسارها — ولو ما وسعت تحت بتطلع فوق
    final gap = s.x(placement.gap);
    final left = (rtl ? anchor.right + gap : anchor.left - gap - width).clamp(s.x(8), screen.width - width - s.x(8)).toDouble();
    var top = anchor.top + s.y(placement.dy);
    if (top + height > screen.height - s.y(40)) top = anchor.bottom - height;
    final style = figmaText(s, size: 14.2, weight: FigmaWeight.sfRegular, color: Colors.black, lineHeight: null, letterSpacing: 0);
    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          width: width,
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(s.x(7)), side: BorderSide(color: Colors.black, width: s.x(1))),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (i, action) in actions.indexed) ...[
                  if (i > 0) Container(height: s.x(1), color: Colors.black),
                  InkWell(
                    onTap: () => Navigator.pop(context, action),
                    child: SizedBox(
                      height: s.y(_row) - (i > 0 ? s.x(1) : 0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(start: s.x(placement.textPad), end: s.x(17)),
                        child: Row(
                          children: [
                            // النص أعلى من نص الصف بـ 1.5 (زي Figma)
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: s.y(3)),
                                child: FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: Text(_label(action), maxLines: 1, style: style)),
                              ),
                            ),
                            SizedBox(width: s.x(4)),
                            SizedBox(width: s.x(25), height: s.x(25), child: Center(child: _icon(s, action))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _label(MemberAction action) => switch (action) {
        MemberAction.chat => FamilyMembersText.startChat(),
        MemberAction.location => FamilyMembersText.showLocation(),
        MemberAction.remove => FamilyMembersText.remove(),
        MemberAction.stopSharing => FamilyMembersText.stopSharing(),
        MemberAction.startSharing => FamilyMembersText.startSharing(),
      };

  // الأيقونات بحجم حبرها بـ Figma: الفقاعة 25×24 — الدبوس 17.5×24.5 — السلة 21×22.5
  static Widget _icon(DesignScale s, MemberAction action) => switch (action) {
        MemberAction.chat => ChatDotsIcon(size: s.x(25)),
        MemberAction.location => MapPinIcon(width: s.x(17.5), height: s.x(24.5), color: Colors.black),
        MemberAction.remove => TrashIcon(size: s.x(22.5)),
        MemberAction.stopSharing => MapPinIcon(width: s.x(17.5), height: s.x(24.5), color: FamilyColors.grey),
        MemberAction.startSharing => MapPinIcon(width: s.x(17.5), height: s.x(24.5), color: FamilyColors.green),
      };
}

/// مكان القائمة من الثلاث نقاط وعرضها (مقاسة من Figma)
class MenuPlacement {
  final double gap; // من طرف النقاط لطرف القائمة
  final double dy; // من أعلى النقاط لأعلى القائمة
  final double width;
  final double textPad; // من طرف القائمة لأول النص

  const MenuPlacement._(this.gap, this.dy, this.width, this.textPad);

  static const family = MenuPlacement._(15.6, 4.2, 145, 7);
  static const group = MenuPlacement._(25.9, 9.2, 144, 5.8);
}
