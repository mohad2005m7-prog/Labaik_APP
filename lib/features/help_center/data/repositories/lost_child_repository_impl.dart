import '../../domain/entities/lost_child_report.dart';
import '../../domain/repositories/lost_child_repository.dart';
import '../sources/help_api.dart';

// -------------------------------------------------------------
// البلاغ بيروح للسيرفر مباشرة (ما بينحفظ على الجهاز — بلاغ ما وصل لازم المستخدم يعرف ويعيد)
// -------------------------------------------------------------
class LostChildRepositoryImpl implements LostChildRepository {
  final HelpApi _api;

  LostChildRepositoryImpl({HelpApi? api}) : _api = api ?? HelpApi.server();

  @override
  Future<void> submit(LostChildReport report, {required bool shareWithNearby}) => _api.submitLostChild(report, shareWithNearby: shareWithNearby);
}
