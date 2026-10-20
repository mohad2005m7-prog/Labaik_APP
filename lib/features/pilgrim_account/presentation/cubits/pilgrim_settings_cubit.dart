import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_language.dart';
import '../../domain/repositories/pilgrim_account_repository.dart';

// -------------------------------------------------------------
// إعدادات المعتمر: الإشعارات (محفوظة لحسابه) ولغة التطبيق
// -------------------------------------------------------------
class PilgrimSettingsState extends Equatable {
  final bool notifications;
  final String language;

  const PilgrimSettingsState({this.notifications = true, this.language = 'ar'});

  @override
  List<Object?> get props => [notifications, language];
}

class PilgrimSettingsCubit extends Cubit<PilgrimSettingsState> {
  PilgrimSettingsCubit(this._repository) : super(PilgrimSettingsState(language: AppLanguage.code));

  final PilgrimAccountRepository _repository;

  Future<void> load() async {
    final enabled = await _repository.notificationsEnabled();
    if (!isClosed) emit(PilgrimSettingsState(notifications: enabled, language: AppLanguage.code));
  }

  void toggleNotifications() {
    final enabled = !state.notifications;
    emit(PilgrimSettingsState(notifications: enabled, language: state.language));
    _repository.setNotificationsEnabled(enabled);
  }

  Future<void> setLanguage(String code) async {
    if (code == AppLanguage.code) return;
    emit(PilgrimSettingsState(notifications: state.notifications, language: code));
    await AppLanguage.change(code);
  }
}
