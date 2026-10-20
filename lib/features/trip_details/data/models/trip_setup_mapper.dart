import '../../../auth/data/models/stay_type.dart';
import '../../../auth/data/models/trip_setup_data.dart';
import '../../domain/entities/trip.dart';

// -------------------------------------------------------------
// اللي دخّله المعتمر بشاشات إعداد الرحلة → رحلته المحفوظة
// ("لم أحدد مكان إقامتي بعد" بالإعداد لكل المدن مع بعض)
// -------------------------------------------------------------
extension TripSetupMapper on TripSetupData {
  Trip toTrip() => Trip(
        type: tripType,
        arrivalMethod: arrivalMethod,
        arrivalPlace: arrivalPlace,
        routeCities: [...routeCities],
        departureDate: departureDate,
        departureMinute: departureMinute,
        departureNotDecided: departureNotDecided,
        stayTypes: stayNotDecided ? const {} : {for (final e in stayTypes.entries) if (e.value != null) e.key: e.value as StayType},
        stayPlaces: stayNotDecided ? const {} : {for (final e in stayPlaces.entries) if (e.value != null && e.value!.isNotEmpty) e.key: e.value!},
        stayUndecided: stayNotDecided ? [...stayCities] : const [],
      );
}
