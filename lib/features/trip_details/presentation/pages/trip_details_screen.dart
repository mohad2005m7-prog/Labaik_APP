import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_line.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../domain/entities/trip.dart';
import '../controllers/trip_details_controller.dart';
import '../cubits/trip_details_cubit.dart';
import '../l10n/trip_details_text.dart';
import '../widgets/trip_summary_card.dart';

// -------------------------------------------------------------
// تفاصيل الرحلة — Figma (1:8143): "معلومات الرحلة الخاصة بك" — كرت الرحلة — "تعديل تفاصيل الرحلة"
// كل القيم من رحلة المعتمر نفسه (إعداد الحساب أو آخر تعديل)
// -------------------------------------------------------------
class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripDetailsCubit, Trip>(
      builder: (context, trip) => FigmaPage(
        title: TripDetailsText.title(),
        // "Frame 38" عرضه 372 بهالإطار (مقاس)
        titleRight: 347,
        chevronLeft: 367.25,
        body: (c) => [
          // SF Compact 556 16 أسود
          c.line(TripDetailsText.info(), left: 175.5, top: 117, width: 200, height: 22, style: c.style(16, FigmaWeight.semiBold, Colors.black)),
          Positioned.fill(child: TripSummaryCard(c: c, trip: trip)),
          // زر "تعديل تفاصيل الرحلة": نصه 16 Regular (مقاس من رندر Figma)
          c.button(
            TripDetailsText.edit(),
            left: 16,
            top: 425,
            labelSize: 16,
            labelWeight: FigmaWeight.sfRegular,
            figmaSpacing: true,
            onTap: () => TripDetailsController.edit(context),
          ),
        ],
      ),
    );
  }
}
