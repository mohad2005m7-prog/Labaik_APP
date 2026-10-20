import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../chats/presentation/widgets/chat_avatar.dart';
import '../../domain/entities/family_member.dart';
import '../l10n/family_members_text.dart';
import 'family_colors.dart';
import 'family_icons.dart';

// -------------------------------------------------------------
// كرت فرد (Figma 348×81 من x19.5 — أبيض بحد #1F3B2E 1.5 و radius 14) — الأرقام نسبةً لأعلى الكرت (العائلة — والمجموعة بـ [MemberCardLayout.group])
// (مقاسة من لقطة Figma — الكروت بالتصميم مش متطابقة تماماً، فاعتمدنا مكان واحد للكل):
// الصورة 45 (x314) — الاسم (#1F3B2E) طرفه x300 — 📍 (x290) + حالة الموقع (#717171) طرفها x285
// النقطة 15 (x137) + "متصل الان"/"اخر ظهور" طرفها x128 — الثلاث نقاط (x37.4)
// -------------------------------------------------------------
/// مكان الكرت بالإطار: العائلة (x19.5 بعرض 348) — المجموعة ("لائحة أفراد المجموعة": x17.5 بعرض 349 وكل اللي جوّاه أيسر بـ 2)
class MemberCardLayout {
  final double boxLeft;
  final double boxWidth;
  final double dx;

  /// إزاحة سطر الموقع والاتصال لتحت (المجموعة 3.5)
  final double rowDy;

  const MemberCardLayout._(this.boxLeft, this.boxWidth, this.dx, this.rowDy);

  static const family = MemberCardLayout._(19.5, 348, 0, 0);
  static const group = MemberCardLayout._(17.5, 349, -2, 3.5);
}

class FamilyMemberCard extends StatelessWidget {
  final FigmaCanvas c;
  final FamilyMember member;
  final ValueChanged<Rect> onMenu;
  final MemberCardLayout layout;

  /// بدل الاسم (مثل "مشرف المجموعة")
  final String? title;

  const FamilyMemberCard({super.key, required this.c, required this.member, required this.onMenu, this.layout = MemberCardLayout.family, this.title});

  static const height = 82.0;

  /// من أعلى الكرت لأعلى اللي بعده
  static const pitch = 98.0;

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    final m = member;
    TextStyle style(double size, double weight, Color color) => c.style(size, weight, color, lineHeight: null, letterSpacing: 0);
    final (pinColor, locationText) = switch (m.locationState()) {
      MemberLocationState.available => (FamilyColors.pinOnline, FamilyMembersText.locationAvailable()),
      MemberLocationState.unavailable => (FamilyColors.pinOffline, FamilyMembersText.locationUnavailable()),
      MemberLocationState.notShared => (FamilyColors.grey, FamilyMembersText.locationNotShared()),
    };
    final grey = style(13, FigmaWeight.sfRegular, FamilyColors.grey);
    final dx = layout.dx, dy = layout.rowDy;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.box(left: layout.boxLeft, top: 0.5, width: layout.boxWidth, height: 81, color: Colors.white, radius: 14, borderColor: FamilyColors.green, borderWidth: 1.5),
        c.rect(left: 314 + dx, top: 21.5, width: 45, height: 45, child: Center(child: ChatAvatar(url: m.photoUrl, size: s.x(45)))),
        _fit(TextSpan(text: title ?? (m.isMe ? FamilyMembersText.me() : m.name), style: style(15, FigmaWeight.sfBold, FamilyColors.green)), left: 150 + dx, top: 20.5, width: 150, height: 24),
        c.rect(left: 290 + dx, top: 50.5 + dy, width: 9, height: 14, child: IgnorePointer(child: MapPinIcon(width: s.x(9), height: s.x(14), color: pinColor))),
        _fit(TextSpan(text: locationText, style: grey), left: 159 + dx, top: 50 + dy, width: 126, height: 20),
        c.rect(left: 137 + dx, top: 55 + dy, width: 15, height: 15, child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: m.isOnline ? FamilyColors.online : FamilyColors.offline))),
        _fit(poppinsLatinSpan(m.isOnline ? FamilyMembersText.online() : FamilyMembersText.lastSeen(m.lastSeenAt), grey, latinWeight: FontWeight.w400), left: 46 + dx, top: 48.5 + dy, width: 82, height: 20),
        c.rect(left: 37.4 + dx, top: 35.5, width: 3.2, height: 15, child: IgnorePointer(child: DotsIcon(height: s.x(15), dot: s.x(3.2)))),
        // منطقة ضغط حوالين الثلاث نقاط (القائمة بتطلع جنبها)
        c.tapArea(left: layout.boxLeft, top: 18, width: 44, height: 48, onTap: () => _openMenu(context)),
      ],
    );
  }

  /// نص بصندوقه بالظبط (طرفه بمكان Figma): لو ما وسع (اسم طويل أو الإنجليزي) بيصغر بدل ما يدخل على اللي جنبه
  Widget _fit(InlineSpan span, {required double left, required double top, required double width, required double height}) => c.rect(
        left: left,
        top: top,
        width: width,
        height: height,
        child: IgnorePointer(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: Text.rich(span, maxLines: 1, softWrap: false)),
          ),
        ),
      );

  /// مكان الثلاث نقاط على الشاشة (الكرت بعرض الشاشة وأعلاه = originTop تبع [c])
  void _openMenu(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final s = c.s;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final width = s.x(3.2), height = s.y(15);
    final dots = 37.4 + layout.dx;
    final left = rtl ? s.x(dots) : box.size.width - s.x(dots) - width;
    final origin = box.localToGlobal(Offset(left, s.y(35.5 - c.originTop)));
    onMenu(origin & Size(width, height));
  }
}
