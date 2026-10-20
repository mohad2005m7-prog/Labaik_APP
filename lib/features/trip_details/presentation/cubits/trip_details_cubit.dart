import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';

// -------------------------------------------------------------
// رحلة المعتمر المعروضة بشاشة "تفاصيل الرحلة" (بتنقرا من جديد بعد التعديل)
// -------------------------------------------------------------
class TripDetailsCubit extends Cubit<Trip> {
  TripDetailsCubit(this._repository) : super(Trip.empty);

  final TripRepository _repository;

  /// اللي على الجهاز فوراً — ولو ما في رحلة على الجهاز بنجيبها من السيرفر
  Future<void> load() async {
    final trip = await _repository.load();
    if (isClosed) return;
    emit(trip);
    if (trip != Trip.empty) return;
    final restored = await _repository.restore();
    if (!isClosed && restored != null) emit(restored);
  }
}
