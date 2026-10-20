import 'package:equatable/equatable.dart';

// -------------------------------------------------------------
// رئيسية الشركة: اسم الشركة للترحيب ("السلام عليكم، شركة النور") والأرقام
// (الرحلات النشطة، الحجاج والمعتمرين، المشرفين، المجموعات)
// [firstName] = اسم صاحب الحساب — بيُستعمل بس لو اسم الشركة مش واصل
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

  /// الاسم اللي بيطلع بالترحيب: اسم الشركة، وإلا اسم صاحب الحساب
  String get greetingName {
    final company = companyName?.trim() ?? '';
    return company.isNotEmpty ? company : firstName;
  }

  @override
  List<Object?> get props => [firstName, companyName, activeTrips, pilgrims, supervisors, groups];
}
