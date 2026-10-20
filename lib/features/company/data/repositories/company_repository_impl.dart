import '../../../../core/network/api_exception.dart';
import '../../../auth/data/auth_session.dart';
import '../../domain/entities/company_group.dart';
import '../../domain/entities/company_member.dart';
import '../../domain/entities/company_notification.dart';
import '../../domain/entities/company_overview.dart';
import '../../domain/entities/company_profile.dart';
import '../../domain/entities/company_trip.dart';
import '../../domain/repositories/company_repository.dart';
import '../models/company_json.dart';
import '../sources/company_api.dart';

// -------------------------------------------------------------
// واجهة الشركة من سيرفر لبيك (/company):
// الرئيسية = /company/me (اسم الشركة) + /company/home (الأرقام)
// الرحلات = /company/trips (الوجهات بالقائمة — وسيرفر أقدم: من تفاصيل كل رحلة)
// المجموعات = /company/groups بطلب واحد (وسيرفر أقدم بلاه: مجموعات كل رحلة)
// -------------------------------------------------------------
class CompanyRepositoryImpl implements CompanyRepository {
  CompanyRepositoryImpl({CompanyApi? api}) : _api = api ?? CompanyApi.server();

  final CompanyApi _api;

  @override
  Future<CompanyOverview> overview() async {
    final name = (await AuthSession.current())?.fullName.trim() ?? '';
    final firstName = name.isEmpty ? '' : name.split(RegExp(r'\s+')).first;
    // كل طلب لحاله: لو فشل واحد بيضل التاني يبين (الاسم بلا أرقام أو العكس)
    final results = await Future.wait([_api.me().then<Object?>((v) => v, onError: (Object e) => e), _api.home().then<Object?>((v) => v, onError: (Object e) => e)]);
    final company = results[0];
    final numbers = results[1];
    if (company is! Map<String, dynamic> && numbers is! Map<String, dynamic>) throw company!;
    final companyName = company is Map<String, dynamic> ? company['name']?.toString().trim() : null;
    final n = numbers is Map<String, dynamic> ? numbers : const <String, dynamic>{};
    return CompanyOverview(
      firstName: firstName,
      companyName: companyName == null || companyName.isEmpty ? null : companyName,
      activeTrips: _int(n['activeTrips']),
      pilgrims: _int(n['pilgrimsCount']),
      supervisors: _int(n['supervisorsCount']),
      groups: _int(n['groupsCount']),
    );
  }

  @override
  Future<CompanyProfile> profile() async => CompanyJson.profile(await _api.me());

  @override
  Future<CompanyProfile> updateProfile(CompanyProfile profile) async => CompanyJson.profile(await _api.updateMe(CompanyJson.profileBody(profile)));

  @override
  Future<List<CompanyTrip>> trips() async {
    final summaries = await _api.trips();
    // الوجهات صارت بالقائمة — لو السيرفر أقدم (ما فيها) بنجيبها من تفاصيل كل رحلة بالتوازي (ولو فشلت وحدة بتنعرض بلا وجهات)
    final destinations = await Future.wait([
      for (final t in summaries)
        t['destinations'] is List ? Future.value(CompanyJson.destinationsOf(t)) : _api.trip(t['id'].toString()).then(CompanyJson.destinationsOf, onError: (_) => const <String>[]),
    ]);
    return [for (final (i, t) in summaries.indexed) CompanyJson.trip(t, destinations: destinations[i])];
  }

  @override
  Future<CompanyTrip> createTrip(TripDraft draft) async => CompanyJson.trip(await _api.createTrip(CompanyJson.tripBody(draft)));

  @override
  Future<List<CompanyNotification>> notifications() async => [for (final j in await _api.notifications()) ?CompanyJson.notification(j)];

  @override
  Future<List<CompanyGroup>> groups() async {
    final results = await Future.wait<Object>([_api.trips(), _api.allGroups().then<Object>((v) => v, onError: (Object e) => e)]);
    final trips = [for (final t in results[0] as List<Map<String, dynamic>>) CompanyJson.trip(t)];
    final all = results[1];
    final today = DateTime.now();
    if (all is List<Map<String, dynamic>>) {
      // نوع الرحلة (حج/عمرة) وانتهاءها من قائمة الرحلات
      final byId = {for (final t in trips) t.id: t};
      return [for (final g in all) CompanyJson.group(g, trip: byId[g['tripId']?.toString()], today: today)];
    }
    if (all is! ApiException || !all.isMissingOnServer) throw all;
    return _groupsPerTrip(trips, today);
  }

  /// سيرفر أقدم بلا /company/groups: مجموعات كل رحلة لحالها
  Future<List<CompanyGroup>> _groupsPerTrip(List<CompanyTrip> trips, DateTime today) async {
    // رحلة وحدة فشلت ما بتوقّف الباقي (مجموعاتها بتغيب لحد التحديث الجاي) — بس لو كلهم فشلوا فهو خطأ (مش "ما في مجموعات")
    Object? failure;
    final perTrip = await Future.wait([
      for (final t in trips)
        _api.tripGroups(t.id).catchError((Object e) {
          failure = e;
          return const <Map<String, dynamic>>[];
        }),
    ]);
    if (failure != null && perTrip.every((g) => g.isEmpty)) throw failure!;
    return [
      for (final (i, list) in perTrip.indexed)
        for (final g in list) CompanyJson.group(g, trip: trips[i], today: today),
    ];
  }

  @override
  Future<CompanyGroup> createGroup({required String tripId, required String name}) async {
    final json = await _api.createGroup(tripId, name.trim());
    return CompanyJson.group(json, trip: await _tripOf(tripId));
  }

  @override
  Future<List<CompanyMember>> members(String groupId) async => [for (final j in await _api.members(groupId)) CompanyJson.member(j)];

  @override
  Future<CompanyMember> member(String groupId, String userId) async => CompanyJson.member(await _api.member(groupId, userId));

  @override
  Future<CompanyGroup> addMember(String groupId, {required String email, String? fullName, String? phone}) async {
    final json = await _api.addMember(groupId, {
      'email': email.trim(),
      if (fullName != null && fullName.trim().isNotEmpty) 'fullName': fullName.trim(),
      if (phone != null && phone.trim().isNotEmpty) 'phoneNumber': phone.trim(),
    });
    return CompanyJson.group(json, trip: await _tripOf(json['tripId']?.toString() ?? ''));
  }

  @override
  Future<String> uploadLogo(String filePath) => _api.uploadFile(filePath);

  @override
  Future<void> removeMember(String groupId, String userId) => _api.removeMember(groupId, userId);

  @override
  Future<List<CompanySupervisor>> supervisors() async => [for (final j in await _api.supervisors()) CompanyJson.supervisor(j)];

  @override
  Future<CompanySupervisor> addSupervisor({required String fullName, required String email, String? phone}) async => CompanyJson.supervisor(await _api.addSupervisor({
        'fullName': fullName.trim(),
        'email': email.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phoneNumber': phone.trim(),
      }));

  @override
  Future<void> removeSupervisor(String userId) => _api.removeSupervisor(userId);

  @override
  Future<void> setSupervisorSuspended(String userId, {required bool suspended}) => _api.setSupervisorSuspended(userId, suspended: suspended);

  @override
  Future<String> supervisorTempPassword(String userId) => _api.supervisorTempPassword(userId);

  @override
  Future<CompanyGroup> assignSupervisor(String groupId, String email) async {
    final json = await _api.assignSupervisor(groupId, email.trim());
    return CompanyJson.group(json, trip: await _tripOf(json['tripId']?.toString() ?? ''));
  }

  /// اسم الرحلة وحالتها للمجموعة (لو فشل الطلب بترجع بلا اسم رحلة)
  Future<CompanyTrip?> _tripOf(String tripId) async {
    if (tripId.isEmpty) return null;
    try {
      return CompanyJson.trip(await _api.trip(tripId));
    } catch (_) {
      return null;
    }
  }

  static int _int(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
}
