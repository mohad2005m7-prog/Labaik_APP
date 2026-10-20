import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/common_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../auth/data/models/arrival_method_enum.dart';
import '../../../auth/data/sources/arrival_points.dart';
import '../../../auth/data/sources/saudi_airports.dart';
import '../../../auth/presentation/l10n/arrival_airport_text.dart';
import '../../../auth/presentation/l10n/arrival_point_text.dart';
import '../../../auth/presentation/l10n/entry_port_text.dart';
import '../../domain/entities/trip.dart';
import '../controllers/trip_details_controller.dart';
import '../cubits/trip_edit_cubit.dart';
import '../l10n/trip_edit_text.dart';
import '../l10n/trip_format.dart';
import '../widgets/trip_edit_page.dart';
import '../widgets/trip_picker_sheet.dart';
import '../widgets/trip_question.dart';
import '../widgets/trip_search_field.dart';

// -------------------------------------------------------------
// مكان الوصول حسب الوسيلة (3/4/5 تعديل تفاصيل الرحلة):
// طائرة → "ما مطار وصولك؟" (1:7750) | حافلة → "ما منفذ دخولك؟" (1:7789) | سيارة خاصة → "ما نقطة وصولك؟" (1:7828)
// -------------------------------------------------------------
class EditArrivalPlaceScreen extends StatelessWidget {
  final ArrivalMethod method;

  const EditArrivalPlaceScreen({super.key, required this.method});

  bool get _airport => method == ArrivalMethod.airplane;

  List<TripPickerGroup> get _groups => _airport
      ? [
          TripPickerGroup(ArrivalAirportText.international(), [for (final a in SaudiAirports.international) (a.code, a.name)]),
          TripPickerGroup(ArrivalAirportText.regional(), [for (final a in SaudiAirports.regional) (a.code, a.name)]),
        ]
      : [for (final g in ArrivalPointsData.groups) TripPickerGroup(g.country, [for (final p in g.points) (p, p)])];

  String get _hint => switch (method) {
        ArrivalMethod.airplane => ArrivalAirportText.search(),
        ArrivalMethod.bus => EntryPortText.search(),
        ArrivalMethod.privateCar => ArrivalPointText.search(),
      };

  void _next(BuildContext context) {
    if (context.read<TripEditCubit>().state.arrivalPlace == null) {
      final message = switch (method) {
        ArrivalMethod.airplane => ArrivalAirportText.chooseFirst(),
        ArrivalMethod.bus => EntryPortText.chooseFirst(),
        ArrivalMethod.privateCar => ArrivalPointText.chooseFirst(),
      };
      TripDetailsController.showMessage(ScaffoldMessenger.of(context), message);
      return;
    }
    TripDetailsController.toRoute(context);
  }

  Future<void> _pick(BuildContext context, String? selected) async {
    final cubit = context.read<TripEditCubit>();
    final place = await showTripPicker(context, hint: _hint, groups: _groups, selected: selected);
    if (place != null) cubit.setArrivalPlace(place);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripEditCubit, Trip>(
      builder: (context, trip) {
        final place = trip.arrivalPlace;
        // القيمة لازم تكون من قائمة هالوسيلة
        final valid = place != null && _groups.any((g) => g.items.any((i) => i.$1 == place));
        final text = !valid ? _hint : TripFormat.place(trip);
        return TripEditPage(
          steps: 2,
          // "معلومات الرحلة الخاصة بك" بإطار المطار أبعد بـ 4.5 عن باقي الإطارات
          infoRight: _airport ? 375.5 : 380,
          button: CommonText.next(),
          onNext: () => _next(context),
          content: (c) => [
            ...switch (method) {
              ArrivalMethod.airplane => [
                  TripQuestion.title(c, ArrivalAirportText.title()),
                  TripQuestion.plain(c, ArrivalAirportText.description(), weight: FigmaWeight.semiBold),
                ],
              ArrivalMethod.bus => [
                  TripQuestion.title(c, EntryPortText.title()),
                  TripQuestion.plain(c, TripEditText.entryPortDescription(), weight: FigmaWeight.semiBold, lines: 2),
                ],
              ArrivalMethod.privateCar => [
                  TripQuestion.title(c, ArrivalPointText.title()),
                  TripQuestion.plain(c, ArrivalPointText.description(), weight: FigmaWeight.sfRegular),
                ],
            },
            Positioned.fill(
              child: TripSearchField(
                c: c,
                left: _airport ? 31 : 35.82,
                top: method == ArrivalMethod.bus ? 313 : 296,
                text: text,
                empty: !valid,
                onTap: () => _pick(context, valid ? place : null),
              ),
            ),
          ],
        );
      },
    );
  }
}
