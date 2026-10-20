import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/geo_utils.dart';
import '../../domain/entities/lost_child_report.dart';
import '../../domain/repositories/lost_child_repository.dart';

class LostChildFormState extends Equatable {
  final LostChildReport report;
  final bool locating;
  final bool submitting;

  const LostChildFormState({this.report = LostChildReport.empty, this.locating = false, this.submitting = false});

  LostChildFormState copyWith({LostChildReport? report, bool? locating, bool? submitting}) =>
      LostChildFormState(report: report ?? this.report, locating: locating ?? this.locating, submitting: submitting ?? this.submitting);

  @override
  List<Object?> get props => [report, locating, submitting];
}

// -------------------------------------------------------------
// بلاغ الطفل المفقود من النموذج لشاشة المشاركة: نفس الـ Cubit للشاشتين
// البلاغ بيروح للسيرفر بس لما يوافق على المشاركة ("نعم , مشاركة البلاغ") — "لا , شكرا" بتلغيه
// -------------------------------------------------------------
class LostChildReportCubit extends Cubit<LostChildFormState> {
  final LostChildRepository _repository;

  LostChildReportCubit(this._repository) : super(const LostChildFormState());

  void setAge(int years) => emit(state.copyWith(report: state.report.copyWith(age: years)));

  void setDescription(String text) => emit(state.copyWith(report: state.report.copyWith(description: text)));

  void setLocating(bool locating) => emit(state.copyWith(locating: locating));

  void setLocation(GeoPoint point) => emit(state.copyWith(report: state.report.copyWith(location: point), locating: false));

  void setPhoto(String path) => emit(state.copyWith(report: state.report.copyWith(photoPath: path)));

  void removePhoto() => emit(state.copyWith(report: state.report.copyWith(removePhoto: true)));

  /// ApiException لو ما وصل
  Future<void> submit({required bool shareWithNearby}) async {
    if (state.submitting) return;
    emit(state.copyWith(submitting: true));
    try {
      await _repository.submit(state.report, shareWithNearby: shareWithNearby);
    } finally {
      if (!isClosed) emit(state.copyWith(submitting: false));
    }
  }
}
