import '../../domain/entities/personal_dua.dart';
import '../../domain/entities/suggested_dua.dart';
import '../../domain/repositories/duas_repository.dart';
import '../sources/duas_local_source.dart';
import '../sources/suggested_duas_source.dart';

// -------------------------------------------------------------
// الأدعية: الخاصة من الجهاز (لكل حساب) والمقترحة من نصوص Figma
// -------------------------------------------------------------
class DuasRepositoryImpl implements DuasRepository {
  DuasRepositoryImpl({DuasLocalSource? local}) : _local = local ?? DuasLocalSource();

  final DuasLocalSource _local;

  @override
  Future<List<PersonalDua>> personalDuas() async => (await _local.load())..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  @override
  Future<PersonalDua> addDua({required String title, required String text}) async {
    final now = DateTime.now();
    final dua = PersonalDua(id: '${now.microsecondsSinceEpoch}', title: title, text: text, updatedAt: now);
    await _local.save([dua, ...await _local.load()]);
    return dua;
  }

  @override
  Future<PersonalDua> updateDua(PersonalDua dua, {required String title, required String text}) async {
    final updated = PersonalDua(id: dua.id, title: title, text: text, updatedAt: DateTime.now());
    await _local.save([for (final d in await _local.load()) d.id == dua.id ? updated : d]);
    return updated;
  }

  @override
  Future<void> deleteDua(String id) async => _local.save([for (final d in await _local.load()) if (d.id != id) d]);

  @override
  List<SuggestedDua> suggestedDuas() => SuggestedDuasSource.all;
}
