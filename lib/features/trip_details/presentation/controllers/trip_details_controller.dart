import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/data/models/arrival_method_enum.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../domain/repositories/trip_repository.dart';
import '../cubits/trip_details_cubit.dart';
import '../cubits/trip_edit_cubit.dart';
import '../pages/edit_about_trip_screen.dart';
import '../pages/edit_arrival_method_screen.dart';
import '../pages/edit_arrival_place_screen.dart';
import '../pages/edit_departure_screen.dart';
import '../pages/edit_stay_places_screen.dart';
import '../pages/edit_stay_types_screen.dart';
import '../pages/edit_trip_route_screen.dart';
import '../pages/edit_trip_type_screen.dart';
import '../pages/trip_details_screen.dart';
import '../widgets/trip_success_dialog.dart';

// -------------------------------------------------------------
// التنقل بشاشات تفاصيل الرحلة (بروتوتايب Figma):
// الرئيسية (كرت "تفاصيل الرحلة") → تفاصيل الرحلة → "تعديل تفاصيل الرحلة":
//   نوع الرحلة → كيف ستصل → (مطار الوصول | منفذ الدخول | نقطة الوصول — حسب الوسيلة) → مسار الرحلة
//   → موعد الوصول → أين ستقيم؟ → (أماكن الإقامة — لو اختار فندق أو مكان اخر بأي مدينة) → أخبرنا اكثر عن رحلتك؟
//   → بتنحفظ الرحلة و"تمت إضافة التفاصيل بنجاح!" → "الذهاب للرئيسية"
// -------------------------------------------------------------
class TripDetailsController {
  static final TripRepository _repository = TripRepositoryImpl();

  static Future<void> open(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => TripDetailsCubit(_repository)..load(), child: const TripDetailsScreen())),
      );

  /// شاشات التعديل بتشتغل على نسخة من الرحلة — وتفاصيل الرحلة بتنقرا من جديد لما يرجع
  static Future<void> edit(BuildContext context) async {
    final details = context.read<TripDetailsCubit>();
    final draft = TripEditCubit(_repository, details.state);
    await Navigator.push(context, _route(draft, const EditTripTypeScreen()));
    await draft.close();
    await details.load();
  }

  static Future<void> toArrivalMethod(BuildContext context) => _next(context, const EditArrivalMethodScreen());

  static Future<void> toArrivalPlace(BuildContext context, ArrivalMethod method) => _next(context, EditArrivalPlaceScreen(method: method));

  static Future<void> toRoute(BuildContext context) => _next(context, const EditTripRouteScreen());

  static Future<void> toDeparture(BuildContext context) => _next(context, const EditDepartureScreen());

  static Future<void> toStays(BuildContext context) => _next(context, const EditStayTypesScreen());

  static Future<void> toStayPlaces(BuildContext context) => _next(context, const EditStayPlacesScreen());

  static Future<void> toAbout(BuildContext context) => _next(context, const EditAboutTripScreen());

  /// آخر خطوة: حفظ الرحلة → "تمت إضافة التفاصيل بنجاح!" → الرئيسية
  static Future<void> finish(BuildContext context) async {
    final navigator = Navigator.of(context);
    await context.read<TripEditCubit>().save();
    if (!context.mounted) return;
    await showTripSuccess(context, onHome: () => navigator.popUntil((route) => route.isFirst));
  }

  static void showMessage(ScaffoldMessengerState messenger, String text) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), duration: const Duration(milliseconds: 1600)));
  }

  static Future<void> _next(BuildContext context, Widget screen) => Navigator.push(context, _route(context.read<TripEditCubit>(), screen));

  static MaterialPageRoute<void> _route(TripEditCubit cubit, Widget screen) => MaterialPageRoute(builder: (_) => BlocProvider.value(value: cubit, child: screen));
}
