import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/common_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_line.dart';
import '../../../auth/data/models/trip_type.dart';
import '../../../auth/presentation/l10n/trip_type_text.dart';
import '../../domain/entities/trip.dart';
import '../controllers/trip_details_controller.dart';
import '../cubits/trip_edit_cubit.dart';
import '../l10n/trip_edit_text.dart';
import '../widgets/trip_colors.dart';
import '../widgets/trip_edit_page.dart';
import '../widgets/trip_type_option.dart';

// -------------------------------------------------------------
// 1تعديل تفاصيل الرحلة — Figma (1:8178): "لا تقلق…" — "نوع الرحلة": عمرة / حج → متابعة
// -------------------------------------------------------------
class EditTripTypeScreen extends StatelessWidget {
  const EditTripTypeScreen({super.key});

  void _next(BuildContext context) {
    if (context.read<TripEditCubit>().state.type == null) {
      TripDetailsController.showMessage(ScaffoldMessenger.of(context), TripTypeText.chooseFirst());
      return;
    }
    TripDetailsController.toArrivalMethod(context);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TripEditCubit>();
    return BlocBuilder<TripEditCubit, Trip>(
      builder: (context, trip) => TripEditPage(
        infoTop: 148,
        infoRight: 375.5,
        cardTop: 198,
        button: CommonText.continueLabel(),
        buttonTop: 657,
        onNext: () => _next(context),
        content: (c) => [
          // Poppins 600 16 #1F3B2E
          c.line(TripEditText.reassure(), left: 25.5, top: 110, width: 350, height: 22, style: c.style(16, FigmaWeight.semiBold, TripColors.green)),
          // SF Compact 556 20 #1F3B2E
          c.line(TripTypeText.title(), left: 151.5, top: 226, width: 200, height: 22, style: c.style(20, FigmaWeight.semiBold, TripColors.green)),
          // "Frame 38": خيارين 56 بينهم 16
          for (final (i, type) in TripType.values.indexed)
            Positioned.fill(
              child: TripTypeOption(
                c: c,
                top: 269 + i * 72.0,
                label: type == TripType.umrah ? TripTypeText.umrah() : TripTypeText.hajj(),
                icon: type == TripType.umrah ? 'assets/images/trip/ic_umrah.png' : 'assets/images/trip/ic_hajj.png',
                selected: trip.type == type,
                onTap: () => cubit.setType(type),
              ),
            ),
        ],
      ),
    );
  }
}
