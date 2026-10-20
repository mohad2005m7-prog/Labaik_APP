import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/common_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../auth/data/sources/saudi_cities.dart';
import '../../../auth/presentation/l10n/trip_route_text.dart';
import '../controllers/trip_details_controller.dart';
import '../cubits/trip_edit_cubit.dart';
import '../l10n/trip_edit_text.dart';
import '../widgets/trip_edit_page.dart';
import '../widgets/trip_picker_sheet.dart';
import '../widgets/trip_question.dart';
import '../widgets/trip_route_stop.dart';

// -------------------------------------------------------------
// 6تعديل تفاصيل الرحلة — Figma (1:7867): "ما مسار رحلتك؟" — وجهتك الاولى — وجهتك التالية — "+ إضافة محطة" → التالي
// كل محطة زيادة (مش مصممة بـ Figma) بنفس شكل "وجهتك التالية" وتحتها بـ 76 — ولو كترت بتتمرر جوّا الكرت
// -------------------------------------------------------------
class EditTripRouteScreen extends StatefulWidget {
  const EditTripRouteScreen({super.key});

  @override
  State<EditTripRouteScreen> createState() => _EditTripRouteScreenState();
}

class _EditTripRouteScreenState extends State<EditTripRouteScreen> {
  // المحطات بالترتيب (null = لسا ما اختارها) — أقل شي حقلين زي Figma
  late final List<String?> _stops = [...context.read<TripEditCubit>().state.routeCities];

  static const _listTop = 315.0;
  static const _listBottom = 626.0;

  @override
  void initState() {
    super.initState();
    while (_stops.length < 2) {
      _stops.add(null);
    }
  }

  List<TripPickerGroup> get _cities => [for (final r in SaudiCitiesData.regions) TripPickerGroup(r.region, [for (final city in r.cities) (city, city)])];

  void _save() {
    final cities = <String>[];
    for (final city in _stops) {
      if (city != null && !cities.contains(city)) cities.add(city);
    }
    context.read<TripEditCubit>().setRoute(cities);
  }

  Future<void> _pick(int index) async {
    final city = await showTripPicker(context, hint: index == 0 ? TripRouteText.searchFirst() : TripRouteText.searchNext(), groups: _cities, selected: _stops[index]);
    if (city == null || !mounted) return;
    setState(() => _stops[index] = city);
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return TripEditPage(
      steps: 3,
      button: CommonText.next(),
      onNext: () => TripDetailsController.toDeparture(context),
      content: (c) {
        final k = c.at(_listTop);
        final addTop = 475 + 76.0 * (_stops.length - 2);
        return [
          TripQuestion.title(c, TripRouteText.title()),
          TripQuestion.spaced(c, TripEditText.routeDescription(), width: 331, lines: 2),
          // المحطات و"+ إضافة محطة" — بتتمرر جوّا الكرت لما ما توسع
          c.rect(
            left: 0,
            top: _listTop,
            width: FigmaCanvas.frameWidth,
            height: _listBottom - _listTop,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                height: c.s.y(addTop + 22 - _listTop),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (var i = 0; i < _stops.length; i++)
                      Positioned.fill(
                        child: TripRouteStop(
                          c: k,
                          top: 323 + 76.0 * i,
                          label: i == 0 ? TripEditText.firstDestination() : TripEditText.nextDestination(),
                          city: _stops[i],
                          hint: i == 0 ? TripRouteText.searchFirst() : TripRouteText.searchNext(),
                          onTap: () => _pick(i),
                        ),
                      ),
                    Positioned.fill(child: TripAddStop(c: k, top: addTop, onTap: () => setState(() => _stops.add(null)))),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
    );
  }
}
