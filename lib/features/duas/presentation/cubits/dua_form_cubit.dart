import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/tx.dart';
import '../../domain/entities/personal_dua.dart';
import '../../domain/repositories/duas_repository.dart';
import '../l10n/dua_form_text.dart';

enum DuaFormStatus { editing, saving, saved }

class DuaFormState extends Equatable {
  final DuaFormStatus status;
  final Tx? error;
  final int errorVersion; // نفس الخطأ مرتين = رسالتين

  const DuaFormState({this.status = DuaFormStatus.editing, this.error, this.errorVersion = 0});

  @override
  List<Object?> get props => [status, error, errorVersion];
}

// -------------------------------------------------------------
// إضافة دعاء جديد / تعديل دعاء موجود ([dua]): العنوان والنص مطلوبين
// -------------------------------------------------------------
class DuaFormCubit extends Cubit<DuaFormState> {
  DuaFormCubit(this._repository, {this.dua}) : super(const DuaFormState());

  final DuasRepository _repository;

  /// null = دعاء جديد
  final PersonalDua? dua;

  Future<void> save({required String title, required String text}) async {
    if (state.status != DuaFormStatus.editing) return;
    final t = title.trim(), body = text.trim();
    final error = t.isEmpty ? DuaFormText.errorTitle : (body.isEmpty ? DuaFormText.errorText : null);
    if (error != null) {
      emit(DuaFormState(error: error, errorVersion: state.errorVersion + 1));
      return;
    }
    emit(DuaFormState(status: DuaFormStatus.saving, errorVersion: state.errorVersion));
    final existing = dua;
    existing == null ? await _repository.addDua(title: t, text: body) : await _repository.updateDua(existing, title: t, text: body);
    if (!isClosed) emit(DuaFormState(status: DuaFormStatus.saved, errorVersion: state.errorVersion));
  }
}
