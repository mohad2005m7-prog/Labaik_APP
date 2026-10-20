import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/supervisor_repository.dart';

// -------------------------------------------------------------
// التبويب الحالي بشريط التنقل (0 الرئيسية .. 4 الملف الشخصي)
// بينحفظ على الجهاز، فلما يرجع المشرف للتطبيق بيفتح على آخر تبويب كان فيه
// -------------------------------------------------------------
class SupervisorShellCubit extends Cubit<int> {
  SupervisorShellCubit(this._repository, {int initialTab = 0}) : super(initialTab);

  final SupervisorRepository _repository;

  void select(int tab) {
    if (tab == state) return;
    emit(tab);
    _repository.saveLastTab(tab);
  }
}
