import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/common_text.dart';
import '../../../auth/data/models/arrival_method_enum.dart';
import '../../../auth/presentation/l10n/arrival_method_text.dart';
import '../../domain/entities/trip.dart';
import '../controllers/trip_details_controller.dart';
import '../cubits/trip_edit_cubit.dart';
import '../l10n/trip_edit_text.dart';
import '../widgets/arrival_method_option.dart';
import '../widgets/trip_edit_page.dart';
import '../widgets/trip_question.dart';

// -------------------------------------------------------------
// 2تعديل تفاصيل الرحلة — Figma (1:7694): "كيف ستصل إلى السعودية؟" طائرة / حافلة / سيارة خاصة → متابعة
// الوسيلة بتحدد الخطوة الجاية: مطار الوصول | منفذ الدخول | نقطة الوصول
// -------------------------------------------------------------
class EditArrivalMethodScreen extends StatelessWidget {
  const EditArrivalMethodScreen({super.key});

  // أماكن "Group 19/20/21" — والأيقونة جوّا كل خيار: اسمها، مكانها من أعلاه، طولها
  static const _tops = [301.62, 364.14, 426.67];
  static const _icons = [('ic_plane', 17.34, 23.0), ('ic_bus', 13.82, 22.0), ('ic_car', 16.29, 23.0)];
  static const _labelDy = [-3.5, -0.25, -0.25];

  static String _label(ArrivalMethod method) => switch (method) {
        ArrivalMethod.airplane => ArrivalMethodText.airplane(),
        ArrivalMethod.bus => ArrivalMethodText.bus(),
        ArrivalMethod.privateCar => ArrivalMethodText.privateCar(),
      };

  void _next(BuildContext context) {
    final method = context.read<TripEditCubit>().state.arrivalMethod;
    if (method == null) {
      TripDetailsController.showMessage(ScaffoldMessenger.of(context), ArrivalMethodText.chooseFirst());
      return;
    }
    TripDetailsController.toArrivalPlace(context, method);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TripEditCubit>();
    return BlocBuilder<TripEditCubit, Trip>(
      builder: (context, trip) => TripEditPage(
        steps: 1,
        infoRight: 375.5,
        cardTop: 206,
        button: CommonText.continueLabel(),
        buttonLeft: 16,
        onNext: () => _next(context),
        content: (c) => [
          TripQuestion.title(c, ArrivalMethodText.title()),
          TripQuestion.spaced(c, TripEditText.arrivalMethodDescription(), width: 320, end: 361),
          for (final (i, method) in ArrivalMethod.values.indexed)
            Positioned.fill(
              child: ArrivalMethodOption(
                c: c,
                top: _tops[i],
                label: _label(method),
                icon: 'assets/images/trip/${_icons[i].$1}.png',
                iconTop: _icons[i].$2,
                iconHeight: _icons[i].$3,
                labelDy: _labelDy[i],
                selected: trip.arrivalMethod == method,
                onTap: () => cubit.setArrivalMethod(method),
              ),
            ),
        ],
      ),
    );
  }
}
