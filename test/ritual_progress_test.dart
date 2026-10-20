import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:labaik/core/network/api_client.dart';
import 'package:labaik/features/tawaf/data/ritual_progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final puts = <Map<String, dynamic>>[];
  Map<String, dynamic>? serverProgress;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    puts.clear();
    serverProgress = null;
    RitualProgressStore.client = ({Duration timeout = const Duration(seconds: 15)}) => ApiClient(
          baseUrl: 'https://api.test/api/v1',
          accessToken: () async => 'tok',
          refreshToken: () async => null,
          client: MockClient((r) async {
            if (r.method == 'PUT') puts.add(jsonDecode(r.body) as Map<String, dynamic>);
            return http.Response(jsonEncode(serverProgress ?? {'pilgrimageType': 1, 'completedSteps': []}), 200, headers: {'content-type': 'application/json'});
          }),
        );
  });

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

  test('each tawaf round is saved on the device and sent as a snapshot (round, ihram 2, UTC time)', () async {
    await RitualProgressStore.record(RitualProgressStore.tawafRound, tawafRound: 4, ihram: IhramState.inIhram);
    await settle();
    expect(puts.single, containsPair('stepKey', 'tawaf.round'));
    expect(puts.single, containsPair('round', 4));
    expect(puts.single, containsPair('ihramState', 2));
    expect(puts.single['updatedAtUtc'], endsWith('Z'));
    final pending = await RitualProgressStore.resumable(askServer: false);
    expect((pending?.stepKey, pending?.tawafRound), ('tawaf.round', 4));
  });

  test('nothing to resume after a finished umrah, between rounds or after 12 hours', () async {
    await RitualProgressStore.record('tawaf.done', push: false);
    expect(await RitualProgressStore.resumable(askServer: false), isNull);
    await RitualProgressStore.record(RitualProgressStore.completed, ihram: IhramState.released, push: false);
    expect(await RitualProgressStore.resumable(askServer: false), isNull);
    final old = DateTime.now().subtract(const Duration(hours: 13)).toUtc().toIso8601String();
    SharedPreferences.setMockInitialValues({'ritual_snapshot:': jsonEncode({'stepKey': 'saee.round', 'saeeLap': 3, 'updatedAtUtc': old})});
    expect(await RitualProgressStore.resumable(askServer: false), isNull);
  });

  test('a newer snapshot on the server (another device) wins', () async {
    await RitualProgressStore.record(RitualProgressStore.tawafRound, tawafRound: 2, push: false);
    serverProgress = {
      'pilgrimageType': 1,
      'completedSteps': [],
      'currentStepKey': 'saee.round',
      'saeeLap': 5,
      'ihramState': 2,
      'clientUpdatedAtUtc': DateTime.now().add(const Duration(minutes: 1)).toUtc().toIso8601String(),
    };
    final pending = await RitualProgressStore.resumable();
    expect((pending?.stepKey, pending?.saeeLap, pending?.ihram), ('saee.round', 5, IhramState.inIhram));
  });
}
