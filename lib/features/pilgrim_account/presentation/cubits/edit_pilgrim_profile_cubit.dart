import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/tx.dart';
import '../../domain/entities/pilgrim_profile.dart';
import '../../domain/repositories/pilgrim_account_repository.dart';
import '../l10n/edit_pilgrim_profile_text.dart';

enum EditPilgrimStatus { loading, editing, saving, saved }

class EditPilgrimProfileState extends Equatable {
  final PilgrimProfile profile;
  final EditPilgrimStatus status;
  final Tx? error;
  final int errorVersion; // نفس الخطأ مرتين = رسالتين

  const EditPilgrimProfileState({this.profile = PilgrimProfile.empty, this.status = EditPilgrimStatus.loading, this.error, this.errorVersion = 0});

  EditPilgrimProfileState copyWith({PilgrimProfile? profile, EditPilgrimStatus? status, Tx? error, int? errorVersion}) => EditPilgrimProfileState(
        profile: profile ?? this.profile,
        status: status ?? this.status,
        error: error,
        errorVersion: errorVersion ?? this.errorVersion,
      );

  @override
  List<Object?> get props => [profile, status, error, errorVersion];
}

// -------------------------------------------------------------
// تعديل البيانات الشخصية (المعتمر): الاسم مطلوب، والإيميل والهاتف لازم يكونوا صح لو انكتبوا
// الصورة بتنحفظ أول ما يختارها (أو يحذفها) حتى لو رجع بدون "حفظ التغييرات"
// والجنس والحقول بيتغيروا بالحالة لحد "حفظ التغييرات"
// -------------------------------------------------------------
class EditPilgrimProfileCubit extends Cubit<EditPilgrimProfileState> {
  EditPilgrimProfileCubit(this._repository) : super(const EditPilgrimProfileState());

  final PilgrimAccountRepository _repository;

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phone = RegExp(r'^\+?[0-9 \-]{7,18}$');

  Future<void> load() async {
    final profile = await _repository.loadProfile();
    if (!isClosed) emit(state.copyWith(profile: profile, status: EditPilgrimStatus.editing));
  }

  Future<void> setPhoto(String sourcePath) async {
    final stored = await _repository.storePhoto(sourcePath);
    await _repository.savePhoto(stored);
    if (!isClosed) emit(state.copyWith(profile: state.profile.copyWith(photo: stored)));
  }

  Future<void> removePhoto() async {
    await _repository.savePhoto(null);
    if (!isClosed) emit(state.copyWith(profile: state.profile.copyWith(clearPhoto: true)));
  }

  void setGender(PilgrimGender gender) => emit(state.copyWith(profile: state.profile.copyWith(gender: gender)));

  Future<void> save({required String fullName, required String phone, required String email}) async {
    final name = fullName.trim(), mail = email.trim(), tel = phone.trim();
    final error = name.length < 3
        ? EditPilgrimProfileText.errorName
        : mail.isNotEmpty && !_email.hasMatch(mail)
            ? EditPilgrimProfileText.errorEmail
            : tel.isNotEmpty && !_phone.hasMatch(tel)
                ? EditPilgrimProfileText.errorPhone
                : null;
    if (error != null) {
      emit(state.copyWith(error: error, errorVersion: state.errorVersion + 1));
      return;
    }
    emit(state.copyWith(status: EditPilgrimStatus.saving));
    final profile = state.profile.copyWith(fullName: name, email: mail, phone: tel);
    await _repository.saveProfile(profile);
    if (!isClosed) emit(state.copyWith(profile: profile, status: EditPilgrimStatus.saved));
  }
}
