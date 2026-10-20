import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../controllers/company_controller.dart';
import '../cubits/company_trips_cubit.dart';
import '../l10n/company_trips_text.dart';
import '../widgets/company_colors.dart';
import '../widgets/company_filter_chips.dart';
import '../widgets/company_page.dart';
import '../widgets/company_search_field.dart';
import '../widgets/company_tab_bar.dart';
import '../widgets/company_trip_card.dart';

// -------------------------------------------------------------
// تبويب "الرحلات" — مطابقة لـ Figma: الكل (467:4774)، القادمة (560:2964)، الراحلة (563:3629)
// العنوان ← البحث ← الفلترة ← ("جميع الرحلات" بالكل بس) ← الكروت
// بالكل: زر "+ إنشاء رحلة جديدة" ثابت فوق شريط التنقل والكروت بتتمرر من تحته
// -------------------------------------------------------------
class CompanyTripsScreen extends StatelessWidget {
  const CompanyTripsScreen({super.key});

  // أعلى أول كرت: بالكل تحت "جميع الرحلات"، وبالقادمة/الراحلة تحت الفلترة مباشرة
  static const _cardsTopAll = 266.25;
  static const _cardsTopFiltered = 222.5;
  static const _buttonTop = 710.0;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CompanyTripsCubit>();
    return BlocBuilder<CompanyTripsCubit, CompanyTripsState>(
      builder: (context, state) {
        final all = state.filter == CompanyTripsFilter.all;
        final trips = state.visible;
        final cardsTop = all ? _cardsTopAll : _cardsTopFiltered;
        // آخر كرت بيقدر يطلع فوق الزر (أو شريط التنقل) بنفس المسافة اللي بين الكروت
        final lastBottom = trips.isEmpty ? cardsTop : cardsTop + (trips.length - 1) * CompanyTripCard.pitch + CompanyTripCard.height;
        final above = all ? _buttonTop : CompanyTabBar.top;
        final scrollHeight = math.max(852.0, lastBottom + (CompanyTripCard.pitch - CompanyTripCard.height) + (852 - above));
        return CompanyPage(
          inShell: true,
          scrollHeight: scrollHeight,
          builder: (c) => [
            // SF Compact 790 20 — بالنص
            c.text(CompanyTripsText.title(), left: 96, top: 59, width: 201, height: 24, align: TextAlign.center, dy: 0, style: c.style(20, FigmaWeight.sfBold, CompanyColors.green, lineHeight: null, letterSpacing: 0)),
            c.rect(left: 24, top: 99.25, width: 345, height: 36, child: CompanySearchField(s: c.s, hint: CompanyTripsText.search(), onChanged: cubit.search)),
            ...CompanyFilterChips.build(c, selected: state.filter, onSelect: cubit.select),
            if (all)
              c.text(CompanyTripsText.allTrips(), left: 56, top: 223.3, width: 321, height: 24, dy: 0, style: c.style(20, FigmaWeight.sfBold, CompanyColors.green, lineHeight: null, letterSpacing: 0)),
            if (trips.isEmpty && state.loaded)
              c.text(
                state.query.trim().isEmpty ? CompanyTripsText.empty() : CompanyTripsText.noResults(),
                left: 16,
                top: cardsTop + 8,
                width: 361,
                height: 22,
                align: TextAlign.center,
                style: c.style(14, FigmaWeight.sfRegular, const Color(0xFF717171), lineHeight: null, letterSpacing: 0),
              ),
            for (final (i, trip) in trips.indexed) ...CompanyTripCard.build(c, trip, top: cardsTop + i * CompanyTripCard.pitch, onDetails: () => CompanyController.openTrip(context, trip)),
          ],
          fixed: all ? (c) => [c.button(CompanyTripsText.createTrip(), left: 16, top: _buttonTop, figmaSpacing: true, onTap: () => CompanyController.createTrip(context))] : null,
        );
      },
    );
  }
}
