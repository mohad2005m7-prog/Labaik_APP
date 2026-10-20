import 'package:equatable/equatable.dart';

// -------------------------------------------------------------
// رئيسية الشركة: اسم صاحب الحساب للترحيب، اسم الشركة، والأرقام (الرحلات النشطة، الحجاج والمعتمرين، المشرفين، المجموعات)
// [companyName] null = مش معروف (السيرفر لسا ما فيه بيانات الشركة)
// -------------------------------------------------------------
class CompanyOverview extends Equatable {
  final String firstName;
  final String? companyName;
  final int activeTrips;
  final int pilgrims;
  final int supervisors;
  final int groups;

  const CompanyOverview({this.firstName = '', this.companyName, this.activeTrips = 0, this.pilgrims = 0, this.supervisors = 0, this.groups = 0});

  static const empty = CompanyOverview();

  @override
  List<Object?> get props => [firstName, companyName, activeTrips, pilgrims, supervisors, groups];
}
