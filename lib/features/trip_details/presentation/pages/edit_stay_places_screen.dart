import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/common_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../auth/data/models/stay_type.dart';
import '../../../auth/data/sources/city_hotels.dart';
import '../../../auth/presentation/l10n/stay_text.dart';
import '../../domain/entities/trip.dart';
import '../controllers/trip_details_controller.dart';
import '../cubits/trip_edit_cubit.dart';
import '../l10n/trip_stay_text.dart';
import '../widgets/trip_edit_page.dart';
import '../widgets/trip_picker_sheet.dart';
import '../widgets/trip_question.dart';
import '../widgets/trip_stay_chip.dart';
import '../widgets/trip_stay_field.dart';

// -------------------------------------------------------------
// 9تعديل تفاصيل الرحلة — Figma (1:8038): "أين ستقيم؟" — لكل مدينة اختار فيها فندق أو مكان اخر:
// "إقامتك في …" وتحتها الفندق (قائمة منسدلة بفنادق المدينة، أو يكتبه) أو المكان (كتابة) → التالي (لازم يعبّي الكل)
// المدن اللي "لم أحدد مكان إقامتي بعد" ما بتطلع هون — ولو كترت بتتمرر جوّا الكرت
// -------------------------------------------------------------
class EditStayPlacesScreen extends StatefulWidget {
  const EditStayPlacesScreen({super.key});

  @override
  State<EditStayPlacesScreen> createState() => _EditStayPlacesScreenState();
}

class _EditStayPlacesScreenState extends State<EditStayPlacesScreen> {
  static const _listTop = 318.0;
  static const _listBottom = 628.0;
  static const _firstChip = 324.6;
  static const _pitch = 105.0;
  static const _fieldGap = 47.65;

  final Map<String, TextEditingController> _written = {};

  TripEditCubit get _cubit => context.read<TripEditCubit>();

  /// المدن اللي اختار فيها نوع إقامة
  List<String> get _cities {
    final trip = _cubit.state;
    return [for (final city in trip.stayCities) if (trip.stayTypes[city] != null) city];
  }

  /// "مكان اخر" بيكتبه — والفندق دايماً من القائمة المنسدلة (زي Figma)
  bool _writes(String city) => _cubit.state.stayTypes[city] == StayType.other;

  @override
  void dispose() {
    for (final controller in _written.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controller(String city) => _written.putIfAbsent(city, () => TextEditingController(text: _cubit.state.stayPlaces[city] ?? ''));

  /// فنادق المدينة (CityHotels) — ولو فندقه مش بالقائمة (أو المدينة ما إلها فنادق فيها) بيكتبه بالبحث ويختاره
  Future<void> _pickHotel(String city) async {
    final groups = [for (final g in CityHotels.forCity(city)) TripPickerGroup(g.title, [for (final h in g.hotels) (h, h)])];
    final hotel = await showTripPicker(context, hint: StayText.search(), groups: groups, selected: _cubit.state.stayPlaces[city], allowTyped: true);
    if (hotel != null && mounted) _cubit.setStayPlace(city, hotel);
  }

  void _next() {
    final trip = _cubit.state;
    if (_cities.any((city) => (trip.stayPlaces[city] ?? '').isEmpty)) {
      TripDetailsController.showMessage(ScaffoldMessenger.of(context), TripStayText.enterStay());
      return;
    }
    TripDetailsController.toAbout(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripEditCubit, Trip>(
      builder: (context, trip) {
        final cities = _cities;
        return TripEditPage(
          steps: 6,
          button: CommonText.next(),
          onNext: _next,
          content: (c) {
            final k = c.at(_listTop);
            final bottom = _firstChip + (cities.length - 1) * _pitch + _fieldGap + TripStayField.height + 8;
            return [
              TripQuestion.title(c, StayText.title(), end: 372.5),
              TripQuestion.spaced(c, TripStayText.placesDescription(), width: 330, lines: 2, top: 265.5, end: 372.5),
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
                        for (final (i, city) in cities.indexed) ...[
                          Positioned.fill(child: TripStayChip(c: k, left: 213, top: _firstChip + i * _pitch, city: city)),
                          Positioned.fill(
                            child: _writes(city)
                                ? TripStayField.write(
                                    c: k,
                                    top: _firstChip + i * _pitch + _fieldGap,
                                    controller: _controller(city),
                                    hint: StayText.enterPlace(),
                                    onChanged: (place) => _cubit.setStayPlace(city, place),
                                  )
                                : TripStayField.pick(
                                    c: k,
                                    top: _firstChip + i * _pitch + _fieldGap,
                                    text: trip.stayPlaces[city] ?? StayText.search(),
                                    empty: trip.stayPlaces[city] == null,
                                    onTap: () => _pickHotel(city),
                                  ),
                          ),
                        ],
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
