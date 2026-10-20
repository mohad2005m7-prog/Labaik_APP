import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_lines.dart';
import '../../domain/entities/company_group.dart';
import '../controllers/company_controller.dart';
import '../cubits/company_groups_cubit.dart';
import '../l10n/company_groups_text.dart';
import '../widgets/company_box.dart';
import '../widgets/company_colors.dart';
import '../widgets/company_page.dart';
import '../widgets/company_search_field.dart';
import '../widgets/company_tab_bar.dart';

// -------------------------------------------------------------
// تبويب "المجموعات" — Figma المجموعات (393×852) / المجموعات2 (393×977)
// فارغة: زر "إنشاء مجموعة" وسط الشاشة (بيختار الرحلة ويكتب الاسم ← رمز الانضمام)
// مليانة (977px تتمرر): بحث + فلاتر + كروت المجموعات + زر ثابت
// -------------------------------------------------------------
class CompanyGroupsScreen extends StatelessWidget {
  const CompanyGroupsScreen({super.key});

  static const _cardsTop = 223.0;
  static const _cardHeight = 158.0;
  static const _cardPitch = 174.0;
  static const _buttonTop = 761.0;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CompanyGroupsCubit>();
    return BlocBuilder<CompanyGroupsCubit, CompanyGroupsState>(
      builder: (context, state) {
        if (state.groups.isEmpty) {
          // حالة فارغة
          return CompanyPage(
            inShell: true,
            builder: (c) => [
              c.button(CompanyGroupsText.createGroup(), left: 16, top: 529, figmaSpacing: true, onTap: () => CompanyController.createGroups(context)),
            ],
          );
        }

        final groups = state.visible;
        final lastBottom = groups.isEmpty ? _cardsTop : _cardsTop + (groups.length - 1) * _cardPitch + _cardHeight;
        final scrollHeight = math.max(852.0, lastBottom + (_cardPitch - _cardHeight) + (852 - CompanyTabBar.top));

        return CompanyPage(
          inShell: true,
          scrollHeight: scrollHeight,
          builder: (c) => [
            c.text(
              CompanyGroupsText.title(),
              left: 96,
              top: 59,
              width: 201,
              height: 24,
              align: TextAlign.center,
              dy: 0,
              style: c.style(20, FigmaWeight.sfBold, CompanyColors.green, lineHeight: null, letterSpacing: 0),
            ),
            c.rect(left: 25, top: 99, width: 345, height: 36, child: CompanySearchField(s: c.s, hint: CompanyGroupsText.search(), onChanged: cubit.search)),
            ..._filterChips(c, state.filter, cubit.select),
            if (groups.isEmpty && state.loaded)
              c.text(
                CompanyGroupsText.empty(),
                left: 16,
                top: _cardsTop + 8,
                width: 361,
                height: 22,
                align: TextAlign.center,
                style: c.style(14, FigmaWeight.sfRegular, const Color(0xFF717171), lineHeight: null, letterSpacing: 0),
              ),
            for (final (i, group) in groups.indexed) ..._groupCard(c, context, group, top: _cardsTop + i * _cardPitch),
          ],
          fixed: (c) => [
            c.button(CompanyGroupsText.createGroup(), left: 16, top: _buttonTop, figmaSpacing: true, onTap: () => CompanyController.createGroups(context)),
          ],
        );
      },
    );
  }

  // ── فلاتر المجموعات: الكل / النشطة / المنتهية ──
  // أماكن (من Figma): x=298(80px) / x=208.5(79px) / x=102.5(95px)  y=151.5 h=47
  static List<Widget> _filterChips(FigmaCanvas c, CompanyGroupsFilter selected, ValueChanged<CompanyGroupsFilter> onSelect) {
    const chips = [
      (CompanyGroupsFilter.all, 298.0, 80.0, CompanyGroupsText.all),
      (CompanyGroupsFilter.active, 208.5, 79.0, CompanyGroupsText.active),
      (CompanyGroupsFilter.ended, 102.5, 95.0, CompanyGroupsText.ended),
    ];
    return [
      for (final (filter, left, width, label) in chips) ...[
        companyBox(c, left: left, top: 151.5, width: width, height: 47, radius: 14, color: filter == selected ? CompanyColors.green : Colors.white, borderColor: filter == selected ? null : CompanyColors.green),
        FigmaLines.build(c, label(), left: left + 5, top: 151.5 + 14, width: width - 10, align: TextAlign.center, style: c.style(16, FigmaWeight.semiBold, filter == selected ? Colors.white : CompanyColors.green), wrap: false),
        c.tapArea(left: left, top: 151.5, width: width, height: 47, onTap: () => onSelect(filter)),
      ],
    ];
  }

  // ── كرت مجموعة (361×158) ──
  static List<Widget> _groupCard(FigmaCanvas c, BuildContext context, CompanyGroup group, {required double top}) {
    const cardLeft = 16.0;
    const cardWidth = 361.0;
    return [
      // خلفية الكرت
      c.box(left: cardLeft, top: top, width: cardWidth, height: _cardHeight, radius: 12, color: CompanyColors.card, hasShadow: true),
      // شارة الحالة (83×21 rx=10) — x=16+16=32 من أعلى الشاشة
      c.box(
        left: cardLeft + 16,
        top: top + 17,
        width: 83,
        height: 21,
        radius: 10,
        color: group.status == CompanyGroupStatus.active ? CompanyColors.green : const Color(0xFF9E9E9E),
      ),
      c.text(
        group.status == CompanyGroupStatus.active ? CompanyGroupsText.active() : CompanyGroupsText.ended(),
        left: cardLeft + 16,
        top: top + 17,
        width: 83,
        height: 21,
        align: TextAlign.center,
        dy: 0,
        style: c.style(11, FigmaWeight.sfBold, Colors.white, lineHeight: null, letterSpacing: 0),
      ),
      // صورة مصغّرة (45×45 rx=10) — x=cardLeft+300 من أعلى الشاشة
      c.box(left: cardLeft + 300, top: top + 18, width: 45, height: 45, radius: 10, color: CompanyColors.cardInset),
      // اسم المجموعة
      c.text(
        group.name,
        left: cardLeft + 16,
        top: top + 52,
        width: 270,
        height: 22,
        align: TextAlign.end,
        style: c.style(16, FigmaWeight.sfBold, CompanyColors.green, lineHeight: null, letterSpacing: 0),
      ),
      // اسم الرحلة
      c.text(
        group.tripName,
        left: cardLeft + 16,
        top: top + 78,
        width: 270,
        height: 20,
        align: TextAlign.end,
        style: c.style(13, FigmaWeight.sfRegular, CompanyColors.secondaryLabel, lineHeight: null, letterSpacing: 0),
      ),
      // عدد الأعضاء
      c.text(
        '${group.memberCount} ${CompanyGroupsText.memberCount()}',
        left: cardLeft + 16,
        top: top + 108,
        width: 200,
        height: 20,
        align: TextAlign.end,
        style: c.style(13, FigmaWeight.sfRegular, CompanyColors.green, lineHeight: null, letterSpacing: 0),
      ),
      c.tapArea(left: cardLeft, top: top, width: cardWidth, height: _cardHeight, onTap: () => CompanyController.openGroupDetail(context, group)),
    ];
  }
}
