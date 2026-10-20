import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/personal_dua.dart';
import '../../domain/repositories/duas_repository.dart';

class MyDuasState extends Equatable {
  final List<PersonalDua> duas;
  final bool loading;

  const MyDuasState({this.duas = const [], this.loading = true});

  @override
  List<Object> get props => [duas, loading];
}

// -------------------------------------------------------------
// "سجل أدعيتي": الأدعية اللي كتبها المعتمر (آخر تعديل أول) — وحذفها
// -------------------------------------------------------------
class MyDuasCubit extends Cubit<MyDuasState> {
  MyDuasCubit(this._repository) : super(const MyDuasState());

  final DuasRepository _repository;

  Future<void> load() async {
    final duas = await _repository.personalDuas();
    if (!isClosed) emit(MyDuasState(duas: duas, loading: false));
  }

  Future<void> delete(PersonalDua dua) async {
    // بيختفي فوراً من القائمة، وبينحذف من الجهاز
    emit(MyDuasState(duas: [for (final d in state.duas) if (d.id != dua.id) d], loading: false));
    await _repository.deleteDua(dua.id);
  }
}
