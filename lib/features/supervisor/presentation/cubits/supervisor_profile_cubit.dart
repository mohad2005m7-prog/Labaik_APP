import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/supervisor_profile.dart';
import '../../domain/repositories/supervisor_repository.dart';

// -------------------------------------------------------------
// بيانات المشرف (مشتركة بين الرئيسية والملف الشخصي وتعديله):
// المحفوظ على الجهاز بيطلع فوراً، وبعدها بنعبّي الناقص من حسابه (/auth/me)
// -------------------------------------------------------------
class SupervisorProfileState extends Equatable {
  final SupervisorProfile profile;
  final bool loaded;

  const SupervisorProfileState({this.profile = SupervisorProfile.empty, this.loaded = false});

  @override
  List<Object?> get props => [profile, loaded];
}

class SupervisorProfileCubit extends Cubit<SupervisorProfileState> {
  SupervisorProfileCubit(this._repository) : super(const SupervisorProfileState());

  final SupervisorRepository _repository;

  Future<void> load() async {
    final cached = await _repository.cachedProfile();
    if (isClosed) return;
    emit(SupervisorProfileState(profile: cached, loaded: true));
    final fresh = await _repository.refreshProfile(cached);
    if (!isClosed && fresh != state.profile) emit(SupervisorProfileState(profile: fresh, loaded: true));
  }

  Future<void> save(SupervisorProfile profile) async {
    emit(SupervisorProfileState(profile: profile, loaded: true));
    await _repository.saveProfile(profile);
  }
}
