import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_language.dart';
import '../../domain/repositories/supervisor_repository.dart';

// -------------------------------------------------------------
// الإعدادات: مفتاح الإشعارات (محفوظ) ولغة التطبيق (عربي / English — بتتغير بكل التطبيق فوراً)
// -------------------------------------------------------------
class SupervisorSettingsState extends Equatable {
  final bool notifications;
  final String language;

  const SupervisorSettingsState({this.notifications = true, this.language = 'ar'});

  @override
  List<Object?> get props => [notifications, language];
}

class SupervisorSettingsCubit extends Cubit<SupervisorSettingsState> {
  SupervisorSettingsCubit(this._repository) : super(SupervisorSettingsState(language: AppLanguage.code));

  final SupervisorRepository _repository;

  Future<void> load() async {
    final enabled = await _repository.notificationsEnabled();
    if (!isClosed) emit(SupervisorSettingsState(notifications: enabled, language: AppLanguage.code));
  }

  void toggleNotifications() {
    final enabled = !state.notifications;
    emit(SupervisorSettingsState(notifications: enabled, language: state.language));
    _repository.setNotificationsEnabled(enabled);
  }

  Future<void> setLanguage(String code) async {
    if (code == AppLanguage.code) return;
    emit(SupervisorSettingsState(notifications: state.notifications, language: code));
    await AppLanguage.change(code);
  }
}
