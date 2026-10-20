import '../../../auth/data/models/arrival_method_enum.dart';
import '../../../auth/data/models/trip_type.dart';
import '../../../auth/data/sources/saudi_airports.dart';
import '../../../auth/presentation/l10n/departure_text.dart';
import '../../../auth/presentation/l10n/trip_type_text.dart';
import '../../domain/entities/trip.dart';
import 'trip_details_text.dart';

// -------------------------------------------------------------
// عرض قيم الرحلة: "عمرة" — "25 سبتمبر 2026" — اسم المطار بدون رمزه ومدينته
// -------------------------------------------------------------
abstract final class TripFormat {
  static String type(TripType? type) => switch (type) {
        TripType.umrah => TripTypeText.umrah(),
        TripType.hajj => TripTypeText.hajj(),
        null => TripDetailsText.notSet,
      };

  static String date(DateTime? date) => date == null ? TripDetailsText.notSet : '${date.day} ${DepartureText.months[date.month - 1]()} ${date.year}';

  // عزل نص من اليسار لليمين (LRI … PDI) أو حسب أول حرف فيه (FSI … PDI) — حتى ما يتلخبط ترتيب السطر
  static final _ltr = String.fromCharCode(0x2066), _fsi = String.fromCharCode(0x2068), _pdi = String.fromCharCode(0x2069);

  /// قيمة بلغة غير لغة السطر (مثل اسم مطار عربي بالواجهة الإنجليزية)
  static String isolate(String value) => '$_fsi$value$_pdi';

  /// "10:00 am" (معزول حتى ما ينقلب جوّا السطر العربي)
  static String time(int minute) {
    final hour = minute ~/ 60, h12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$_ltr$h12:${(minute % 60).toString().padLeft(2, '0')} ${hour < 12 ? 'am' : 'pm'}$_pdi';
  }

  /// المطار: "مطار الملك خالد الدولي (RUH) - الرياض" → "مطار الملك خالد الدولي" — المنافذ ونقاط الوصول بأسمائها
  static String place(Trip trip) {
    final place = trip.arrivalPlace;
    if (place == null || place.isEmpty) return TripDetailsText.notSet;
    if (trip.arrivalMethod != ArrivalMethod.airplane) return place;
    final airport = [...SaudiAirports.international, ...SaudiAirports.regional].where((a) => a.code == place).firstOrNull;
    return airportName(airport?.name ?? place);
  }

  static String airportName(String name) => name.split(' (').first;
}
