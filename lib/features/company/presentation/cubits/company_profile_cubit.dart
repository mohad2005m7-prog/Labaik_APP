import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/company_profile.dart';
import '../../domain/repositories/company_repository.dart';

class CompanyProfileState extends Equatable {
  final CompanyProfile? profile;
  final bool failed;

  const CompanyProfileState({this.profile, this.failed = false});

  @override
  List<Object?> get props => [profile, failed];
}

// -------------------------------------------------------------
// بيانات الشركة للملف الشخصي (GET /company/me) — وبتتحدّث بعد الحفظ من شاشات التعديل
// -------------------------------------------------------------
class CompanyProfileCubit extends Cubit<CompanyProfileState> {
  CompanyProfileCubit(this._repository) : super(const CompanyProfileState());

  final CompanyRepository _repository;

  Future<void> load() async {
    try {
      final profile = await _repository.profile();
      if (!isClosed) emit(CompanyProfileState(profile: profile));
    } catch (_) {
      if (!isClosed) emit(CompanyProfileState(profile: state.profile, failed: state.profile == null));
    }
  }

  void set(CompanyProfile profile) => emit(CompanyProfileState(profile: profile));
}
