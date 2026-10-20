import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/data/models/arrival_method_enum.dart';
import '../../../auth/data/models/stay_type.dart';
import '../../../auth/data/models/trip_type.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';

// -------------------------------------------------------------
// مسودة الرحلة خلال شاشات التعديل — بتنحفظ بس بآخر خطوة
// -------------------------------------------------------------
class TripEditCubit extends Cubit<Trip> {
  TripEditCubit(this._repository, Trip trip) : super(trip);

  final TripRepository _repository;

  void setType(TripType type) => emit(state.copyWith(type: type));

  /// تغيير الوسيلة بيمسح مكان الوصول (المطار مش منفذ برّي)
  void setArrivalMethod(ArrivalMethod method) {
    if (method != state.arrivalMethod) emit(state.copyWith(arrivalMethod: method, arrivalPlace: () => null));
  }

  void setArrivalPlace(String place) => emit(state.copyWith(arrivalPlace: () => place));

  void setRoute(List<String> cities) => emit(state.copyWith(routeCities: List.unmodifiable(cities)));

  void setDepartureDate(DateTime date) => emit(state.copyWith(departureDate: () => date, departureNotDecided: false));

  void setDepartureMinute(int minute) => emit(state.copyWith(departureMinute: () => minute, departureNotDecided: false));

  /// "لم أحدد موعد الوصول بعد" بيمسح التاريخ والوقت
  void setDepartureNotDecided(bool notDecided) => emit(
        notDecided ? state.copyWith(departureDate: () => null, departureMinute: () => null, departureNotDecided: true) : state.copyWith(departureNotDecided: false),
      );

  /// "فندق" / "مكان اخر" بمدينة (بيلغي "لم أحدد" فيها، وتغيير النوع بيمسح المكان)
  void setStayType(String city, StayType type) {
    if (state.stayTypes[city] == type && !state.stayUndecided.contains(city)) return;
    emit(state.copyWith(
      stayTypes: {...state.stayTypes, city: type},
      stayPlaces: {...state.stayPlaces}..remove(city),
      stayUndecided: [...state.stayUndecided]..remove(city),
    ));
  }

  /// "لم أحدد مكان إقامتي بعد" بمدينة — بيمسح نوع ومكان الإقامة فيها
  void setStayUndecided(String city, bool undecided) => emit(state.copyWith(
        stayTypes: undecided ? ({...state.stayTypes}..remove(city)) : state.stayTypes,
        stayPlaces: undecided ? ({...state.stayPlaces}..remove(city)) : state.stayPlaces,
        stayUndecided: undecided ? {...state.stayUndecided, city}.toList() : ([...state.stayUndecided]..remove(city)),
      ));

  void setStayPlace(String city, String place) {
    final value = place.trim();
    emit(state.copyWith(stayPlaces: value.isEmpty ? ({...state.stayPlaces}..remove(city)) : {...state.stayPlaces, city: value}));
  }

  void setTravelerName(String name) => emit(state.copyWith(travelerName: name.trim()));

  void setFirstTime(bool first) => emit(state.copyWith(firstTime: first));

  void toggleCompanion(TravelCompanion companion) {
    final companions = {...state.companions};
    if (!companions.remove(companion)) companions.add(companion);
    emit(state.copyWith(companions: companions));
  }

  Future<void> save() => _repository.save(state);
}
