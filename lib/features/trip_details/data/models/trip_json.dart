import '../../../auth/data/models/arrival_method_enum.dart';
import '../../../auth/data/models/stay_type.dart';
import '../../../auth/data/models/trip_type.dart';
import '../../domain/entities/trip.dart';

// -------------------------------------------------------------
// الرحلة ⇄ JSON (للحفظ على الجهاز) — القيم المعدودة بأسمائها
// -------------------------------------------------------------
extension TripJson on Trip {
  Map<String, dynamic> toJson() => {
        'type': type?.name,
        'arrivalMethod': arrivalMethod?.name,
        'arrivalPlace': arrivalPlace,
        'routeCities': routeCities,
        'departureDate': departureDate?.toIso8601String(),
        'departureMinute': departureMinute,
        'departureNotDecided': departureNotDecided,
        'stayTypes': {for (final e in stayTypes.entries) e.key: e.value.name},
        'stayPlaces': stayPlaces,
        'stayUndecided': stayUndecided,
        'travelerName': travelerName,
        'firstTime': firstTime,
        'companions': [for (final c in companions) c.name],
      };

  static Trip fromJson(Map<String, dynamic> json) {
    T? named<T extends Enum>(List<T> values, Object? name) => values.where((v) => v.name == name).firstOrNull;
    List<String> strings(Object? list) => [for (final v in list as List? ?? []) '$v'];
    final stayTypes = <String, StayType>{};
    (json['stayTypes'] as Map? ?? {}).forEach((city, name) {
      final type = named(StayType.values, name);
      if (type != null) stayTypes['$city'] = type;
    });
    final trip = Trip(
      type: named(TripType.values, json['type']),
      arrivalMethod: named(ArrivalMethod.values, json['arrivalMethod']),
      arrivalPlace: json['arrivalPlace'] as String?,
      routeCities: strings(json['routeCities']),
      departureDate: DateTime.tryParse(json['departureDate'] as String? ?? ''),
      departureMinute: json['departureMinute'] as int?,
      departureNotDecided: json['departureNotDecided'] as bool? ?? false,
      stayTypes: stayTypes,
      stayPlaces: {for (final e in (json['stayPlaces'] as Map? ?? {}).entries) '${e.key}': '${e.value}'},
      stayUndecided: strings(json['stayUndecided']),
      travelerName: json['travelerName'] as String?,
      firstTime: json['firstTime'] as bool?,
      companions: {for (final name in strings(json['companions'])) ?named(TravelCompanion.values, name)},
    );
    // نسخة أقدم: "لم أحدد مكان إقامتي بعد" كان لكل المدن مع بعض
    return json['stayNotDecided'] == true && trip.stayUndecided.isEmpty ? trip.copyWith(stayUndecided: trip.stayCities) : trip;
  }
}
