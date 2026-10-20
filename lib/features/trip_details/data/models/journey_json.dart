import '../../../../core/utils/json_fields.dart';
import '../../../auth/data/models/arrival_method_enum.dart';
import '../../../auth/data/models/stay_type.dart';
import '../../../auth/data/models/trip_type.dart';
import '../../domain/entities/trip.dart';

// -------------------------------------------------------------
// رحلة المعتمر ⇄ رحلة السيرفر (POST /journeys و PUT /journeys/{id} — الـ enums أرقام):
// { "pilgrimageType" (1 عمرة · 2 حج), "isFirstTime", "travelParty" (1 Solo · 2 Family · 3 Group),
//   "arrival": { "mode" (1 Flight · 2 Bus · 3 PrivateCar), "entryPoint" },
//   "stays": [ { "cityName", "accommodationType" (1 Hotel · 2 Other), "placeName", "arrivalAtUtc" } ] }
// قرار صاحب المشروع: التطبيق بيسأل عن موعد انطلاق واحد — فهو وقت الوصول لكل الإقامات
// السيرفر بيرفض الرحلة بدون وسيلة ومكان وصول وإقامة وحدة على الأقل (باسم المكان) — فلحد ما تكتمل بتضل على الجهاز بس
// -------------------------------------------------------------
abstract final class JourneyJson {
  static const _modes = {ArrivalMethod.airplane: 1, ArrivalMethod.bus: 2, ArrivalMethod.privateCar: 3};

  /// جسم الطلب — null = الرحلة لسا ناقصة للسيرفر
  static Map<String, Object?>? toRequest(Trip trip) {
    final method = trip.arrivalMethod, place = trip.arrivalPlace?.trim(), date = trip.departureDate;
    if (method == null || place == null || place.isEmpty || date == null || trip.departureNotDecided) return null;
    final arrivalAt = DateTime(date.year, date.month, date.day).add(Duration(minutes: trip.departureMinute ?? 0)).toUtc().toIso8601String();
    final stays = [
      for (final city in trip.stayCities)
        if (trip.stayTypes[city] != null && (trip.stayPlaces[city]?.trim() ?? '').isNotEmpty)
          {
            'cityName': city,
            'accommodationType': trip.stayTypes[city] == StayType.hotel ? 1 : 2,
            'placeName': trip.stayPlaces[city]!.trim(),
            'arrivalAtUtc': arrivalAt,
          },
    ];
    if (stays.isEmpty) return null;
    final companions = trip.companions;
    return {
      'pilgrimageType': trip.type == TripType.hajj ? 2 : 1,
      'isFirstTime': trip.firstTime ?? false,
      'travelParty': companions.contains(TravelCompanion.group) ? 3 : (companions.contains(TravelCompanion.family) ? 2 : 1),
      'arrival': {'mode': _modes[method], 'entryPoint': place},
      'stays': stays,
    };
  }

  /// رحلة السيرفر (JourneyDto) → رحلة التطبيق (لما الجهاز ما عليه رحلة — جهاز جديد مثلاً)
  /// الإقامات جاية مرتبة حسب arrivalAtUtc من السيرفر — وموعد الانطلاق = وقت وصول أول إقامة
  static Trip toTrip(Map<String, dynamic> json) {
    final arrival = json.field('arrival') ?? json.field('arrivalPlan');
    final stays = (json.field('stays') as List? ?? const []).whereType<Map<String, dynamic>>().toList();
    final cities = <String>[];
    final types = <String, StayType>{};
    final places = <String, String>{};
    for (final s in stays) {
      final city = s.field('cityName')?.toString().trim() ?? '';
      if (city.isEmpty) continue;
      if (!cities.contains(city)) cities.add(city);
      types[city] = s.optionalInt('accommodationType') == 1 ? StayType.hotel : StayType.other;
      places[city] = s.field('placeName')?.toString() ?? '';
    }
    final start = stays.isEmpty ? null : DateTime.tryParse(stays.first.field('arrivalAtUtc')?.toString() ?? '')?.toLocal();
    final mode = arrival is Map<String, dynamic> ? arrival.optionalInt('mode') : null;
    final party = json.optionalInt('travelParty');
    return Trip(
      type: json.optionalInt('pilgrimageType') == 2 ? TripType.hajj : TripType.umrah,
      arrivalMethod: _modes.entries.where((e) => e.value == mode).firstOrNull?.key,
      arrivalPlace: arrival is Map<String, dynamic> ? arrival.field('entryPoint')?.toString() : null,
      routeCities: cities,
      departureDate: start == null ? null : DateTime(start.year, start.month, start.day),
      departureMinute: start == null ? null : start.hour * 60 + start.minute,
      stayTypes: types,
      stayPlaces: places,
      firstTime: json.field('isFirstTime') == true,
      companions: {
        if (party == 1) TravelCompanion.alone,
        if (party == 2) TravelCompanion.family,
        if (party == 3) TravelCompanion.group,
      },
    );
  }
}
