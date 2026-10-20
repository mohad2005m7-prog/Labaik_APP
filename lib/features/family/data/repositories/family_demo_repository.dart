import 'dart:math' as math;

import '../../../../core/utils/geo_utils.dart';
import '../../../auth/data/account_registry.dart';
import '../../../pilgrim_account/data/pilgrim_account_repository_impl.dart';
import '../../domain/entities/family_circle.dart';
import '../../domain/entities/family_member.dart';
import '../../domain/repositories/family_repository.dart';
import '../sources/family_demo_source.dart';
import '../sources/family_local_source.dart';

// -------------------------------------------------------------
// دائرة العائلة بدون سيرفر (مؤقتاً — BackendMode): كل شي على الجهاز
//   إنشاء الدائرة: دائرتك برمز جديد (وأنت لحالك فيها — ما في سيرفر يوصّل حدا تاني)
//   الانضمام بأي رمز → "عائلة أحمد" التجريبية (FamilyDemoSource) — ومشاركة موقعك الفعلي محفوظة بالجهاز
// -------------------------------------------------------------
class FamilyDemoRepository implements FamilyRepository {
  final FamilyLocalSource _local;

  FamilyDemoRepository({FamilyLocalSource? local}) : _local = local ?? FamilyLocalSource(prefix: 'demo_family');

  // لكل حساب لحاله (بإيميله): آخر موقع إلي بعتّه (FamilyLocationReporter — بيتجدد كل ما يشتغل التطبيق) واللي انحذفوا
  static final _myLocation = <String, (GeoPoint, DateTime)>{};
  static final _removed = <String, Set<String>>{};

  static Future<String> _account() async => await AccountRegistry.currentEmail() ?? '';

  // رموز الدوائر بدون حروف بتلتبس (O/0 و I/1)
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  @override
  Future<FamilyCircle?> cachedCircle() => _local.circle();

  @override
  Future<FamilyCircle?> myCircle() => _local.circle();

  @override
  Future<FamilyCircle> createCircle() async {
    final saved = await _local.circle();
    if (saved != null) return saved;
    final random = math.Random.secure();
    final code = String.fromCharCodes([for (var i = 0; i < 6; i++) _alphabet.codeUnitAt(random.nextInt(_alphabet.length))]);
    final first = (await PilgrimAccountRepositoryImpl().savedProfile())?.fullName.trim().split(' ').first;
    final circle = FamilyCircle(id: 'mine-$code', name: first == null || first.isEmpty ? 'عائلتي' : 'عائلة $first', code: code, isOwner: true);
    await _local.saveCircle(circle);
    return circle;
  }

  @override
  Future<FamilyCircleSummary?> findCircle(String code) async {
    final mine = await _local.circle();
    if (mine != null && mine.code == code) return FamilyCircleSummary(id: mine.id, name: mine.name, membersCount: mine.membersCount);
    return FamilyDemoSource.summary;
  }

  @override
  Future<FamilyCircle> joinCircle(String circleId) async {
    _removed.remove(await _account());
    const circle = FamilyDemoSource.circle;
    await _local.saveCircle(circle);
    return circle;
  }

  @override
  Future<List<FamilyMember>> cachedMembers() async => const [];

  @override
  Future<List<FamilyMember>> members() async {
    final circle = await _local.circle();
    if (circle == null) return const [];
    final now = DateTime.now();
    final shares = circle.mySharesLocation == true;
    final account = await _account();
    final mine = shares ? _myLocation[account] : null;
    final removed = _removed[account] ?? const <String>{};
    final me = FamilyMember(
      userId: 'me',
      name: (await PilgrimAccountRepositoryImpl().savedProfile())?.fullName ?? '',
      isMe: true,
      isOnline: true,
      sharesLocation: shares,
      location: mine?.$1,
      locationUpdatedAt: mine?.$2,
    );
    if (circle.id != FamilyDemoSource.circleId) return [me];
    return [me, for (final m in FamilyDemoSource.others(now)) if (!removed.contains(m.userId)) m];
  }

  @override
  Future<void> setLocationSharing(bool enabled) async {
    final circle = await _local.circle();
    if (circle != null) await _local.saveCircle(circle.copyWith(mySharesLocation: enabled));
  }

  @override
  Future<void> sendLocation(GeoPoint point) async {
    _myLocation[await _account()] = (point, DateTime.now());
  }

  @override
  Future<void> removeMember(String userId) async => (_removed[await _account()] ??= {}).add(userId);
}
