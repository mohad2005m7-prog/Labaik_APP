import 'package:equatable/equatable.dart';

/// حالة المجموعة (الشارة): "نشطة" أو "منتهية"
enum CompanyGroupStatus { active, ended }

// -------------------------------------------------------------
// مجموعة من مجموعات الشركة: اسمها، رحلتها، عدد الأعضاء، والصورة المصغّرة
// -------------------------------------------------------------
class CompanyGroup extends Equatable {
  final String id;
  final String name;
  final String tripName;
  final int memberCount;
  final CompanyGroupStatus status;
  final String? thumbnail;

  const CompanyGroup({required this.id, required this.name, required this.tripName, required this.memberCount, required this.status, this.thumbnail});

  @override
  List<Object?> get props => [id, name, tripName, memberCount, status, thumbnail];
}
