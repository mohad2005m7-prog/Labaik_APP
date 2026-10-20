import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/company_group.dart';
import '../../domain/repositories/company_repository.dart';

/// فلتر المجموعات: الكل / النشطة / المنتهية
enum CompanyGroupsFilter { all, active, ended }

class CompanyGroupsState extends Equatable {
  final bool loaded;
  final List<CompanyGroup> groups;
  final CompanyGroupsFilter filter;
  final String query;

  const CompanyGroupsState({this.loaded = false, this.groups = const [], this.filter = CompanyGroupsFilter.all, this.query = ''});

  List<CompanyGroup> get visible {
    final q = query.trim();
    return [
      for (final g in groups)
        if ((filter == CompanyGroupsFilter.all ||
                (filter == CompanyGroupsFilter.active && g.status == CompanyGroupStatus.active) ||
                (filter == CompanyGroupsFilter.ended && g.status == CompanyGroupStatus.ended)) &&
            (q.isEmpty || g.name.contains(q) || g.tripName.contains(q)))
          g,
    ];
  }

  CompanyGroupsState copyWith({bool? loaded, List<CompanyGroup>? groups, CompanyGroupsFilter? filter, String? query}) =>
      CompanyGroupsState(loaded: loaded ?? this.loaded, groups: groups ?? this.groups, filter: filter ?? this.filter, query: query ?? this.query);

  @override
  List<Object?> get props => [loaded, groups, filter, query];
}

class CompanyGroupsCubit extends Cubit<CompanyGroupsState> {
  CompanyGroupsCubit(this._repository) : super(const CompanyGroupsState());

  final CompanyRepository _repository;

  Future<void> load() async {
    try {
      final groups = await _repository.groups();
      if (!isClosed) emit(state.copyWith(loaded: true, groups: groups));
    } catch (_) {
      if (!isClosed) emit(state.copyWith(loaded: true));
    }
  }

  void select(CompanyGroupsFilter filter) => emit(state.copyWith(filter: filter));

  void search(String query) => emit(state.copyWith(query: query));
}
