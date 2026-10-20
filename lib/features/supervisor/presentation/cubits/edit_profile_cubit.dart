import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/tx.dart';
import '../../domain/entities/supervisor_profile.dart';
import '../../domain/repositories/supervisor_repository.dart';
import '../l10n/edit_profile_text.dart';
import 'supervisor_profile_cubit.dart';

// -------------------------------------------------------------
// شاشة "تعديل الملف الشخصي": الصورة اللي اختارها (كاميرا/معرض) والتحقق من الحقول قبل الحفظ
// الاسم مطلوب، والإيميل والهاتف لازم يكونوا صحاح (الهاتف اختياري)
// -------------------------------------------------------------
enum EditProfileStatus { editing, saving, saved }

class EditProfileState extends Equatable {
  final String? photo;
  final EditProfileStatus status;

  /// مفتاح ترجمة رسالة الخطأ (null = ما في خطأ) — [errorVersion] حتى تطلع نفس الرسالة مرتين
  final Tx? error;
  final int errorVersion;

  const EditProfileState({this.photo, this.status = EditProfileStatus.editing, this.error, this.errorVersion = 0});

  EditProfileState copyWith({String? photo, bool clearPhoto = false, EditProfileStatus? status, Tx? error, int? errorVersion}) {
    return EditProfileState(
      photo: clearPhoto ? null : (photo ?? this.photo),
      status: status ?? this.status,
      error: error,
      errorVersion: errorVersion ?? this.errorVersion,
    );
  }

  @override
  List<Object?> get props => [photo, status, error, errorVersion];
}

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this._repository, this._profile) : super(EditProfileState(photo: _profile.state.profile.photo));

  final SupervisorRepository _repository;
  final SupervisorProfileCubit _profile;

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phone = RegExp(r'^\+?[0-9 \-]{7,18}$');

  /// صورة جديدة من الكاميرا أو المعرض — بتنتسخ لمجلد التطبيق
  Future<void> pickPhoto(String path) async {
    final stored = await _repository.storePhoto(path);
    if (!isClosed) emit(state.copyWith(photo: stored));
  }

  void removePhoto() => emit(state.copyWith(clearPhoto: true));

  Future<void> save({required String name, required String email, required String phone}) async {
    Tx? error;
    if (name.trim().isEmpty) {
      error = EditProfileText.errorName;
    } else if (!_email.hasMatch(email.trim())) {
      error = EditProfileText.errorEmail;
    } else if (phone.trim().isNotEmpty && !_phone.hasMatch(phone.trim())) {
      error = EditProfileText.errorPhone;
    }
    if (error != null) {
      emit(state.copyWith(error: error, errorVersion: state.errorVersion + 1));
      return;
    }
    emit(state.copyWith(status: EditProfileStatus.saving));
    final profile = SupervisorProfile(fullName: name.trim(), email: email.trim(), phone: phone.trim(), photo: state.photo);
    await _profile.save(profile);
    if (!isClosed) emit(state.copyWith(status: EditProfileStatus.saved));
  }
}
