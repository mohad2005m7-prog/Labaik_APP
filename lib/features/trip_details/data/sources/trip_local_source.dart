import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/data/account_registry.dart';
import '../../domain/entities/trip.dart';
import '../models/trip_json.dart';

// -------------------------------------------------------------
// رحلة المعتمر على الجهاز — كل حساب لحاله (بإيميله): trip:<email>
// ومعها رقم رحلته بالسيرفر (journey_id:<email>) وإذا في تعديل لسا ما وصل للسيرفر (journey_pending:<email>)
// -------------------------------------------------------------
class TripLocalSource {
  Future<String> _key(String prefix) async => '$prefix:${await AccountRegistry.currentEmail() ?? ''}';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<Trip> load() async {
    final raw = (await _prefs).getString(await _key('trip'));
    if (raw == null) return Trip.empty;
    try {
      return TripJson.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return Trip.empty;
    }
  }

  Future<void> save(Trip trip) async => (await _prefs).setString(await _key('trip'), jsonEncode(trip.toJson()));

  Future<String?> journeyId() async => (await _prefs).getString(await _key('journey_id'));

  Future<void> saveJourneyId(String id) async => (await _prefs).setString(await _key('journey_id'), id);

  Future<bool> pendingSync() async => (await _prefs).getBool(await _key('journey_pending')) ?? false;

  Future<void> setPendingSync(bool pending) async => (await _prefs).setBool(await _key('journey_pending'), pending);
}
