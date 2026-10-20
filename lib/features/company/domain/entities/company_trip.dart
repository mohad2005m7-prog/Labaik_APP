import 'package:equatable/equatable.dart';

/// حالة الرحلة بكرتها (الشارة): "قادمة" أو "راحلة" — السيرفر: 1 Upcoming، 2 Departed (من يوم الذهاب)
enum CompanyTripStatus { upcoming, departed }

/// نوع الرحلة — السيرفر: 1 Umrah، 2 Hajj
enum PilgrimageKind { umrah, hajj }

// -------------------------------------------------------------
// رحلة من رحلات الشركة (كرت "الرحلات"): اسمها، الوجهات، والتاريخ ("20 – 30 نوفمبر 2026" أو "15 ديسمبر 2026")
// [returnDate] null = بلا تاريخ عودة — [ended] = رجعت (بتنعرض مجموعاتها "منتهية")
// -------------------------------------------------------------
class CompanyTrip extends Equatable {
  final String id;
  final String title;
  final String destinations;
  final String dates;
  final CompanyTripStatus status;
  final DateTime? departureDate;
  final DateTime? returnDate;

  const CompanyTrip({required this.id, required this.title, required this.destinations, required this.dates, required this.status, this.departureDate, this.returnDate});

  bool endedOn(DateTime today) {
    final r = returnDate;
    return r != null && r.isBefore(DateTime(today.year, today.month, today.day));
  }

  @override
  List<Object?> get props => [id, title, destinations, dates, status, departureDate, returnDate];
}

// -------------------------------------------------------------
// بيانات "إنشاء رحلة جديدة" (CreateTripCommand)
// -------------------------------------------------------------
class TripDraft extends Equatable {
  final PilgrimageKind kind;
  final String name;
  final List<String> destinations;
  final DateTime departureDate;
  final DateTime? returnDate;
  final String departurePlace;
  final int expectedPilgrims;
  final String? notes;

  const TripDraft({
    required this.kind,
    required this.name,
    required this.destinations,
    required this.departureDate,
    required this.departurePlace,
    required this.expectedPilgrims,
    this.returnDate,
    this.notes,
  });

  @override
  List<Object?> get props => [kind, name, destinations, departureDate, returnDate, departurePlace, expectedPilgrims, notes];
}
