import 'package:equatable/equatable.dart';

/// حالة الرحلة بكرتها (الشارة): "قادمة" أو "راحلة"
enum CompanyTripStatus { upcoming, departed }

// -------------------------------------------------------------
// رحلة من رحلات الشركة (كرت "الرحلات"): اسمها، الوجهات، وتاريخها كنص زي ما بيدخّله صاحب الرحلة
// ("20 – 30 نوفمبر 2026" أو "15 ديسمبر 2026")
// -------------------------------------------------------------
class CompanyTrip extends Equatable {
  final String id;
  final String title;
  final String destinations;
  final String dates;
  final CompanyTripStatus status;

  const CompanyTrip({required this.id, required this.title, required this.destinations, required this.dates, required this.status});

  @override
  List<Object?> get props => [id, title, destinations, dates, status];
}
