import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/common_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../auth/presentation/l10n/stay_text.dart';
import '../../domain/entities/trip.dart';
import '../controllers/trip_details_controller.dart';
import '../cubits/trip_edit_cubit.dart';
import '../l10n/trip_stay_text.dart';
import '../widgets/trip_edit_page.dart';
import '../widgets/trip_question.dart';
import '../widgets/trip_stay_type_block.dart';

// -------------------------------------------------------------
// 8تعديل تفاصيل الرحلة — Figma (1:7984): "أين ستقيم؟" — لكل مدينة بمسار الرحلة:
// فندق / مكان اخر / لم أحدد مكان إقامتي بعد → التالي (لازم يختار لكل مدينة)
// لو كترت المدن بتتمرر جوّا الكرت
// -------------------------------------------------------------
class EditStayTypesScreen extends StatelessWidget {
  const EditStayTypesScreen({super.key});

  static const _listTop = 318.0;
  static const _listBottom = 628.0;
  static const _firstChip = 323.5;
  static const _secondChip = 458.5;

  static double _chipTop(int i) => i == 0 ? _firstChip : _secondChip + (i - 1) * StayBlockLayout.pitch;

  void _next(BuildContext context) {
    final trip = context.read<TripEditCubit>().state;
    final cities = trip.stayCities;
    if (cities.any((city) => trip.stayTypes[city] == null && !trip.stayUndecided.contains(city))) {
      TripDetailsController.showMessage(ScaffoldMessenger.of(context), TripStayText.chooseStay());
      return;
    }
    if (cities.any((city) => trip.stayTypes[city] != null)) {
      TripDetailsController.toStayPlaces(context);
    } else {
      TripDetailsController.toAbout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TripEditCubit>();
    return BlocBuilder<TripEditCubit, Trip>(
      builder: (context, trip) {
        final cities = trip.stayCities;
        return TripEditPage(
          steps: 5,
          button: CommonText.next(),
          onNext: () => _next(context),
          content: (c) {
            final k = c.at(_listTop);
            final bottom = _chipTop(cities.length - 1) + StayBlockLayout.next.undecidedTop + 24;
            return [
              TripQuestion.title(c, StayText.title(), top: 233, end: 371),
              TripQuestion.spaced(c, TripStayText.typesDescription(), width: 318, lines: 2, top: 263.5, end: 370),
              c.rect(
                left: 0,
                top: _listTop,
                width: FigmaCanvas.frameWidth,
                height: _listBottom - _listTop,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: SizedBox(
                    height: c.s.y(bottom - _listTop),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (final (i, city) in cities.indexed)
                          Positioned.fill(
                            child: TripStayTypeBlock(
                              c: k,
                              top: _chipTop(i),
                              layout: i == 0 ? StayBlockLayout.first : StayBlockLayout.next,
                              city: city,
                              type: trip.stayTypes[city],
                              undecided: trip.stayUndecided.contains(city),
                              onType: (type) => cubit.setStayType(city, type),
                              onUndecided: (undecided) => cubit.setStayUndecided(city, undecided),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
        );
      },
    );
  }
}
