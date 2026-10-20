import '../../domain/entities/supervisor_contact.dart';
import '../../domain/repositories/supervisor_repository.dart';
import '../sources/help_api.dart';
import '../sources/help_local_source.dart';

// -------------------------------------------------------------
// المشرف: من السيرفر، وكل رد ناجح بينحفظ على الجهاز
// -------------------------------------------------------------
class SupervisorRepositoryImpl implements SupervisorRepository {
  final HelpApi _api;
  final HelpLocalSource _local;

  SupervisorRepositoryImpl({HelpApi? api, HelpLocalSource? local}) : _api = api ?? HelpApi.server(), _local = local ?? HelpLocalSource();

  @override
  Future<SupervisorContact?> cached() => _local.supervisor();

  @override
  Future<SupervisorContact?> fetch() async {
    final contact = await _api.mySupervisor();
    await _local.saveSupervisor(contact);
    return contact;
  }
}
