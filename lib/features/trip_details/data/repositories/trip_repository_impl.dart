import 'dart:async';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../models/journey_json.dart';
import '../sources/journey_api.dart';
import '../sources/trip_local_source.dart';

// -------------------------------------------------------------
// الرحلة: على الجهاز أول (لكل حساب — فيها كل اللي دخّله المعتمر) وبتوصل للسيرفر بالخلفية:
//   - أول مرة POST /journeys — وبعدها PUT /journeys/{id} (ولو عنده رحلة بالسيرفر من قبل بنعدّلها هي)
//   - لو ما وصلت (إنترنت، أو الرحلة لسا ناقصة للسيرفر) بتضل "معلّقة" وبنرجع نبعتها مع فتحة الشاشة الجاية
//   - جهاز ما عليه رحلة → بنجيبها من السيرفر (GET /journeys/me)
// -------------------------------------------------------------
class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl({TripLocalSource? local, JourneyApi? api})
      : _local = local ?? TripLocalSource(),
        _api = api ?? JourneyApi.server();

  final TripLocalSource _local;
  final JourneyApi _api;
  Future<void>? _syncing;

  @override
  Future<Trip> load() async {
    final trip = await _local.load();
    if (trip != Trip.empty) unawaited(sync());
    return trip;
  }

  @override
  Future<void> save(Trip trip) async {
    await _local.save(trip);
    await _local.setPendingSync(true);
    unawaited(sync());
  }

  @override
  Future<Trip?> restore() async {
    try {
      final json = await _api.mine();
      if (json == null) return null;
      final id = json['id']?.toString();
      if (id != null) await _local.saveJourneyId(id);
      final trip = JourneyJson.toTrip(json);
      await _local.save(trip);
      return trip;
    } catch (_) {
      return null;
    }
  }

  /// بعت آخر نسخة للسيرفر (لو في تعديل معلّق) — طلب واحد بنفس الوقت
  Future<void> sync() => _syncing ??= _sync().whenComplete(() => _syncing = null);

  Future<void> _sync() async {
    try {
      if (!await _local.pendingSync()) return;
      final body = JourneyJson.toRequest(await _local.load());
      if (body == null) return;
      final id = await _local.journeyId() ?? (await _api.mine())?['id']?.toString();
      if (id == null) {
        await _local.saveJourneyId(await _api.create(body));
      } else {
        try {
          await _api.update(id, body);
          await _local.saveJourneyId(id);
        } on ApiException catch (e) {
          // 409: الرحلة بدأت وما عاد بتتعدّل — ما في شي نبعته
          if (e.statusCode != 409) rethrow;
        }
      }
      await _local.setPendingSync(false);
    } catch (_) {
      // بنرجع نحاول المرة الجاية
    }
  }
}
