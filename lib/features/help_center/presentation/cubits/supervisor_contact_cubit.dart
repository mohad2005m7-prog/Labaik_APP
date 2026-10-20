import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/supervisor_contact.dart';
import '../../domain/repositories/supervisor_repository.dart';

enum SupervisorStatus { loading, ready, notLinked, failed }

class SupervisorContactState extends Equatable {
  final SupervisorStatus status;
  final SupervisorContact? contact;

  /// آخر خطأ من السيرفر (حتى لو في نسخة محفوظة معروضة)
  final Object? error;

  const SupervisorContactState({this.status = SupervisorStatus.loading, this.contact, this.error});

  @override
  List<Object?> get props => [status, contact, error];
}

// -------------------------------------------------------------
// مشرف المعتمر بشاشة التواصل السريع: النسخة المحفوظة فوراً (للاتصال بدون إنترنت) وبعدين من السيرفر
// -------------------------------------------------------------
class SupervisorContactCubit extends Cubit<SupervisorContactState> {
  final SupervisorRepository _repository;

  SupervisorContactCubit(this._repository) : super(const SupervisorContactState());

  Future<void> load() async {
    final cached = await _repository.cached();
    if (isClosed) return;
    if (cached != null) emit(SupervisorContactState(status: SupervisorStatus.ready, contact: cached));
    try {
      final fresh = await _repository.fetch();
      if (isClosed) return;
      emit(fresh == null ? const SupervisorContactState(status: SupervisorStatus.notLinked) : SupervisorContactState(status: SupervisorStatus.ready, contact: fresh));
    } catch (error) {
      if (isClosed) return;
      emit(SupervisorContactState(status: cached == null ? SupervisorStatus.failed : SupervisorStatus.ready, contact: cached, error: error));
    }
  }
}
