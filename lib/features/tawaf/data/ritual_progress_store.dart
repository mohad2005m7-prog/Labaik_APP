import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/utils/json_fields.dart';
import '../../../core/utils/token_storage.dart';
import '../../auth/data/account_registry.dart';
import '../../auth/data/token_refresher.dart';

/// حالة الإحرام — السيرفر: 1 NotInIhram، 2 InIhram، 3 Released (تحلّل)
enum IhramState { notInIhram, inIhram, released }

/// آخر مكان وصله المعتمر بالمناسك: الخطوة (tawaf.round …)، الشوط، والإحرام، وإيمتى
class RitualSnapshot {
  final String stepKey;
  final int? tawafRound;
  final int? saeeLap;
  final IhramState? ihram;
  final DateTime updatedAt;

  const RitualSnapshot({required this.stepKey, this.tawafRound, this.saeeLap, this.ihram, required this.updatedAt});

  Map<String, Object?> toJson() => {'stepKey': stepKey, 'round': tawafRound, 'saeeLap': saeeLap, 'ihramState': ihram == null ? null : ihram!.index + 1, 'updatedAtUtc': updatedAt.toUtc().toIso8601String()};

  static RitualSnapshot? fromJson(Object? json, {String key = 'stepKey', String round = 'round', String updated = 'updatedAtUtc'}) {
    if (json is! Map<String, dynamic>) return null;
    final step = json[key]?.toString() ?? '';
    final at = DateTime.tryParse(json[updated]?.toString() ?? '');
    if (step.isEmpty || at == null) return null;
    final ihram = json.optionalInt('ihramState');
    return RitualSnapshot(
      stepKey: step,
      tawafRound: json.optionalInt(round),
      saeeLap: json.optionalInt('saeeLap'),
      ihram: ihram != null && ihram >= 1 && ihram <= 3 ? IhramState.values[ihram - 1] : null,
      updatedAt: at.toLocal(),
    );
  }
}

// -------------------------------------------------------------
// حفظ التقدم بالمناسك أول بأول (الطواف والسعي): كل خطوة/شوط بينحفظ على الجهاز فوراً
// وبينرفع للسيرفر بالخلفية (PUT /rituals/progress — السيرفر بيتجاهل الأقدم من آخر واحد عنده)
// [resumable] = طواف أو سعي ما كمل من أقل من 12 ساعة (من الجهاز، أو من السيرفر لجهاز جديد)
// -------------------------------------------------------------
abstract final class RitualProgressStore {
  static const tawafRound = 'tawaf.round';
  static const saeeRound = 'saee.round';
  static const completed = 'umrah.complete';
  static const resumeWindow = Duration(hours: 12);

  /// للتجارب: بدل السيرفر
  static ApiClient Function({Duration timeout}) client = ({Duration timeout = const Duration(seconds: 15)}) =>
      ApiClient(baseUrl: ApiConfig.baseUrl, accessToken: TokenStorage.getAccessToken, refreshToken: TokenRefresher.refresh, timeout: timeout);

  static Future<String> _key() async => 'ritual_snapshot:${await AccountRegistry.currentEmail() ?? ''}';

  /// [push] false بالتجارب اللي ما بدها سيرفر
  static Future<void> record(String stepKey, {int? tawafRound, int? saeeLap, IhramState? ihram, bool push = true}) async {
    final snapshot = RitualSnapshot(stepKey: stepKey, tawafRound: tawafRound, saeeLap: saeeLap, ihram: ihram, updatedAt: DateTime.now());
    try {
      await (await SharedPreferences.getInstance()).setString(await _key(), jsonEncode(snapshot.toJson()));
    } catch (_) {
      // التخزين مش متاح — بنكمل
    }
    if (push) unawaited(_push(snapshot));
  }

  static Future<void> _push(RitualSnapshot snapshot) async {
    try {
      await client().putJson('/rituals/progress', body: snapshot.toJson());
    } catch (_) {
      // بلا نت — الجهاز فيه آخر حالة
    }
  }

  static Future<RitualSnapshot?> local() async {
    final raw = (await SharedPreferences.getInstance()).getString(await _key());
    if (raw == null) return null;
    try {
      return RitualSnapshot.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  /// الأحدث بين الجهاز والسيرفر — بس لو طواف أو سعي بنص شوط ومن أقل من [resumeWindow]
  static Future<RitualSnapshot?> resumable({bool askServer = true}) async {
    var best = await local();
    if (askServer) {
      try {
        // مهلة قصيرة: ما بنأخّر بداية الطواف لو النت ضعيف
        final server = RitualSnapshot.fromJson(unwrapData(await client(timeout: const Duration(seconds: 4)).getJson('/rituals/progress')), key: 'currentStepKey', round: 'tawafRound', updated: 'clientUpdatedAtUtc');
        if (server != null && (best == null || server.updatedAt.isAfter(best.updatedAt))) best = server;
      } catch (_) {
        // بلا نت
      }
    }
    if (best == null || DateTime.now().difference(best.updatedAt) > resumeWindow) return null;
    final inTawaf = best.stepKey == tawafRound && (best.tawafRound ?? 0) >= 1;
    final inSaee = best.stepKey == saeeRound && (best.saeeLap ?? 0) >= 1;
    return inTawaf || inSaee ? best : null;
  }
}
