import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_lines.dart';
import '../controllers/company_controller.dart';
import '../cubits/company_groups_cubit.dart';
import '../l10n/company_groups_text.dart';
import '../widgets/company_box.dart';
import '../widgets/company_colors.dart';
import '../widgets/company_group_card.dart';
import '../widgets/company_page.dart';
import '../widgets/company_search_field.dart';
import '../widgets/company_tab_bar.dart';

// -------------------------------------------------------------
// تبويب "المجموعات" — مطابقة لـ Figma 473:4874 (977 بتتمرر) / 624:3419 / 624:3553
// العنوان ← البحث ← الفلترة (الكل / مكتملة / غير مكتملة) ← كروت المجموعات (كل 174) ← زر "إنشاء مجموعة" ثابت فوق شريط التنقل
// -------------------------------------------------------------
class CompanyGroupsScreen extends StatelessWidget {
  const CompanyGroupsScreen({super.key});

  static const _cardsTop = 223.0;
  static const _buttonTop = 696.0;

  // (الفلتر، x، العرض) — Frame 2147227408 من x16: 282/192/86 → 298/208/102
  static const _chips = [
    (CompanyGroupsFilter.all, 298.0, 80.0, CompanyGroupsText.all),
    (CompanyGroupsFilter.complete, 208.0, 80.0, CompanyGroupsText.complete),
    (CompanyGroupsFilter.incomplete, 102.0, 96.0, CompanyGroupsText.incomplete),
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CompanyGroupsCubit>();
    return BlocBuilder<CompanyGroupsCubit, CompanyGroupsState>(
      builder: (context, state) {
        final groups = state.visible;
        final lastBottom = groups.isEmpty ? _cardsTop : _cardsTop + (groups.length - 1) * CompanyGroupCard.pitch + CompanyGroupCard.height;
        final scrollHeight = math.max(852.0, lastBottom + 16 + 50 + (852 - CompanyTabBar.top) + 16);
        return CompanyPage(
          inShell: true,
          scrollHeight: scrollHeight,
          builder: (c) => [
            c.text(CompanyGroupsText.title(), left: 96, top: 59, width: 201, height: 24, align: TextAlign.center, dy: 0, style: c.style(20, FigmaWeight.sfBold, CompanyColors.green, lineHeight: null, letterSpacing: 0)),
            c.rect(left: 25, top: 99, width: 345, height: 36, child: CompanySearchField(s: c.s, hint: CompanyGroupsText.search(), onChanged: cubit.search)),
            ..._filterChips(c, state.filter, cubit.select),
            if (state.loaded && groups.isEmpty)
              c.text(
                state.groups.isEmpty ? CompanyGroupsText.empty() : CompanyGroupsText.noResults(),
                left: 16,
                top: _cardsTop + 8,
                width: 361,
                height: 22,
                align: TextAlign.center,
                style: c.style(14, FigmaWeight.sfRegular, const Color(0xFF717171), lineHeight: null, letterSpacing: 0),
              ),
            for (final (i, group) in groups.indexed)
              ...CompanyGroupCard.build(c, group, top: _cardsTop + i * CompanyGroupCard.pitch, onTap: () => CompanyController.openGroupDetail(context, group)),
          ],
          fixed: (c) => [c.button(CompanyGroupsText.createGroup(), left: 16, top: _buttonTop, figmaSpacing: true, onTap: () => CompanyController.createGroups(context))],
        );
      },
    );
  }

  // المختار #1F3B2E ونصه أبيض — الباقي أبيض بحد #1F3B2E (نفس فلاتر الرحلات)
  static List<Widget> _filterChips(FigmaCanvas c, CompanyGroupsFilter selected, ValueChanged<CompanyGroupsFilter> onSelect) => [
        for (final (filter, left, width, label) in _chips) ...[
          companyBox(c, left: left, top: 151, width: width, height: 48, radius: 14, color: filter == selected ? CompanyColors.green : Colors.white, borderColor: filter == selected ? null : CompanyColors.green),
          FigmaLines.build(c, label(), left: left + 4, top: 151 + 13, width: width - 8, align: TextAlign.center, style: c.style(16, FigmaWeight.semiBold, filter == selected ? Colors.white : CompanyColors.green), wrap: false),
          c.tapArea(left: left, top: 151, width: width, height: 48, onTap: () => onSelect(filter)),
        ],
      ];
}
