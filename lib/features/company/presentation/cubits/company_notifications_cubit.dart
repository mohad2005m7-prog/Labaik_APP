import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/company_notification.dart';
import '../../domain/repositories/company_repository.dart';

class CompanyNotificationsState extends Equatable {
  final bool loading;
  final List<CompanyNotification> items;

  const CompanyNotificationsState({this.loading = true, this.items = const []});

  @override
  List<Object?> get props => [loading, items];
}

// -------------------------------------------------------------
// إشعارات الشركة (من الجرس بالرئيسية) — الجديدة بتنعرض مميّزة هالمرة، وبتتعلّم مقروءة بالسيرفر
// (المرة الجاية بتطلع عادية)
// -------------------------------------------------------------
class CompanyNotificationsCubit extends Cubit<CompanyNotificationsState> {
  CompanyNotificationsCubit(this._repository) : super(const CompanyNotificationsState());

  final CompanyRepository _repository;

  Future<void> load() async {
    try {
      final items = await _repository.notifications();
      if (!isClosed) emit(CompanyNotificationsState(loading: false, items: items));
      if (items.any((n) => !n.isRead)) {
        try {
          await _repository.markNotificationsRead();
        } catch (_) {}
      }
    } catch (_) {
      if (!isClosed) emit(CompanyNotificationsState(loading: false, items: state.items));
    }
  }
}
