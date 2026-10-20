import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/company_trip.dart';
import '../../domain/repositories/company_repository.dart';

/// أزرار الفلترة فوق القائمة: الكل / القادمة / الراحلة
enum CompanyTripsFilter { all, upcoming, departed }

class CompanyTripsState extends Equatable {
  final bool loaded;
  final List<CompanyTrip> trips;
  final CompanyTripsFilter filter;
  final String query;

  const CompanyTripsState({this.loaded = false, this.trips = const [], this.filter = CompanyTripsFilter.all, this.query = ''});

  /// حسب الفلتر والبحث (باسم الرحلة أو وجهاتها)
  List<CompanyTrip> get visible {
    final q = query.trim();
    return [
      for (final t in trips)
        if ((filter == CompanyTripsFilter.all ||
                (filter == CompanyTripsFilter.upcoming && t.status == CompanyTripStatus.upcoming) ||
                (filter == CompanyTripsFilter.departed && t.status == CompanyTripStatus.departed)) &&
            (q.isEmpty || t.title.contains(q) || t.destinations.contains(q)))
          t,
    ];
  }

  CompanyTripsState copyWith({bool? loaded, List<CompanyTrip>? trips, CompanyTripsFilter? filter, String? query}) =>
      CompanyTripsState(loaded: loaded ?? this.loaded, trips: trips ?? this.trips, filter: filter ?? this.filter, query: query ?? this.query);

  @override
  List<Object?> get props => [loaded, trips, filter, query];
}

// -------------------------------------------------------------
// تبويب "الرحلات": رحلات الشركة + الفلترة والبحث (بدون ما يعيد التحميل)
// -------------------------------------------------------------
class CompanyTripsCubit extends Cubit<CompanyTripsState> {
  CompanyTripsCubit(this._repository) : super(const CompanyTripsState());

  final CompanyRepository _repository;

  Future<void> load() async {
    try {
      final trips = await _repository.trips();
      if (!isClosed) emit(state.copyWith(loaded: true, trips: trips));
    } catch (_) {
      if (!isClosed) emit(state.copyWith(loaded: true));
    }
  }

  void select(CompanyTripsFilter filter) => emit(state.copyWith(filter: filter));

  void search(String query) => emit(state.copyWith(query: query));
}
