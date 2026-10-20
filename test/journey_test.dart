import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:labaik/features/auth/data/account_registry.dart';
import 'package:labaik/features/auth/data/models/arrival_method_enum.dart';
import 'package:labaik/features/auth/data/models/stay_type.dart';
import 'package:labaik/features/auth/data/models/trip_type.dart';
import 'package:labaik/features/trip_details/data/models/journey_json.dart';
import 'package:labaik/features/trip_details/data/repositories/trip_repository_impl.dart';
import 'package:labaik/features/trip_details/data/sources/journey_api.dart';
import 'package:labaik/features/trip_details/domain/entities/trip.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'group_backend_test.dart' show FakeServer;

// -------------------------------------------------------------
// الرحلة ⇄ /journeys: الأرقام بدل الأسماء، موعد الانطلاق وقت وصول لكل الإقامات (قرار صاحب المشروع)،
// الرحلة الناقصة ما بتنبعت، أول مرة POST وبعدها PUT، والجهاز الفاضي بيجيبها من السيرفر
// -------------------------------------------------------------
final _trip = Trip(
  type: TripType.umrah,
  arrivalMethod: ArrivalMethod.airplane,
  arrivalPlace: 'JED',
  routeCities: const ['المدينة المنورة', 'مكة المكرمة'],
  departureDate: DateTime(2026, 11, 1),
  departureMinute: 10 * 60 + 30,
  stayTypes: const {'المدينة المنورة': StayType.hotel, 'مكة المكرمة': StayType.other},
  stayPlaces: const {'المدينة المنورة': 'فندق الأنصار', 'مكة المكرمة': 'بيت أقاربي'},
  firstTime: true,
  companions: const {TravelCompanion.family},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('trip → journey request (enums as numbers, departure = every stay arrival)', () {
    final body = JourneyJson.toRequest(_trip)!;
    final arrivalAt = DateTime(2026, 11, 1, 10, 30).toUtc().toIso8601String();
    expect(body, {
      'pilgrimageType': 1,
      'isFirstTime': true,
      'travelParty': 2,
      'arrival': {'mode': 1, 'entryPoint': 'JED'},
      'stays': [
        {'cityName': 'المدينة المنورة', 'accommodationType': 1, 'placeName': 'فندق الأنصار', 'arrivalAtUtc': arrivalAt},
        {'cityName': 'مكة المكرمة', 'accommodationType': 2, 'placeName': 'بيت أقاربي', 'arrivalAtUtc': arrivalAt},
      ],
    });
    // الإقامة اللي لسا ما تحددت ما بتنبعت — ولو ما في ولا وحدة (أو الموعد أو مكان الوصول ناقص) الرحلة بتضل على الجهاز
    expect((JourneyJson.toRequest(_trip.copyWith(stayPlaces: const {'مكة المكرمة': 'بيت أقاربي'}))!['stays'] as List).single, containsPair('cityName', 'مكة المكرمة'));
    expect(JourneyJson.toRequest(_trip.copyWith(stayPlaces: const {})), isNull);
    expect(JourneyJson.toRequest(_trip.copyWith(departureNotDecided: true, departureDate: () => null)), isNull);
    expect(JourneyJson.toRequest(_trip.copyWith(arrivalPlace: () => null)), isNull);
  });

  test('journey from the server → trip (new device)', () {
    final trip = JourneyJson.toTrip({
      'id': 'j1',
      'pilgrimageType': 2,
      'isFirstTime': false,
      'travelParty': 3,
      'status': 2,
      'arrivalPlan': {'mode': 2, 'entryPoint': 'منفذ الحديثة'},
      'stays': [
        {'cityName': 'مكة المكرمة', 'accommodationType': 1, 'placeName': 'فندق مكة', 'arrivalAtUtc': DateTime(2026, 11, 1, 8).toUtc().toIso8601String()},
      ],
    });
    expect(trip.type, TripType.hajj);
    expect(trip.arrivalMethod, ArrivalMethod.bus);
    expect(trip.arrivalPlace, 'منفذ الحديثة');
    expect(trip.routeCities, ['مكة المكرمة']);
    expect(trip.stayTypes['مكة المكرمة'], StayType.hotel);
    expect(trip.stayPlaces['مكة المكرمة'], 'فندق مكة');
    expect(trip.departureDate, DateTime(2026, 11, 1));
    expect(trip.departureMinute, 8 * 60);
    expect(trip.companions, {TravelCompanion.group});
    expect(trip.firstTime, isFalse);
  });

  test('save: POST the first time, PUT after (no pilgrimageType), and restore on an empty device', () async {
    await AccountRegistry.signedIn('p@example.com');
    final server = FakeServer({
      'GET /journeys/me': (_) => http.Response('{"title":"The journey was not found.","status":404}', 404),
      'POST /journeys': (_) => http.Response(jsonEncode({'id': 'j1'}), 201, headers: {'content-type': 'application/json'}),
      'PUT /journeys/j1': (r) => jsonDecode(r.body),
    });
    final repo = TripRepositoryImpl(api: JourneyApi(server.client()));

    await repo.save(_trip);
    await repo.sync();
    expect(server.requests.map((r) => '${r.method} ${r.url.path}'), ['GET /api/v1/journeys/me', 'POST /api/v1/journeys']);
    expect(await repo.load(), _trip);

    await repo.save(_trip.copyWith(firstTime: false));
    await repo.sync();
    final put = server.requests.last;
    expect('${put.method} ${put.url.path}', 'PUT /api/v1/journeys/j1');
    expect((jsonDecode(put.body) as Map).containsKey('pilgrimageType'), isFalse);
    expect((jsonDecode(put.body) as Map)['isFirstTime'], isFalse);

    // جهاز جديد (ما عليه رحلة): بتيجي من السيرفر
    SharedPreferences.setMockInitialValues({});
    await AccountRegistry.signedIn('p@example.com');
    final restored = await TripRepositoryImpl(
      api: JourneyApi(FakeServer({
        'GET /journeys/me': (_) => {
              'id': 'j1',
              'pilgrimageType': 1,
              'isFirstTime': true,
              'travelParty': 1,
              'status': 2,
              'arrivalPlan': {'mode': 1, 'entryPoint': 'JED'},
              'stays': [
                {'cityName': 'مكة المكرمة', 'accommodationType': 1, 'placeName': 'فندق مكة', 'arrivalAtUtc': '2026-11-01T07:30:00Z'},
              ],
            },
      }).client()),
    ).restore();
    expect(restored?.arrivalPlace, 'JED');
    expect(restored?.stayPlaces, {'مكة المكرمة': 'فندق مكة'});
  });
}
