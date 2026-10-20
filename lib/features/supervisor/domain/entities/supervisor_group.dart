import 'package:equatable/equatable.dart';

// -------------------------------------------------------------
// مجموعة بيشرف عليها المشرف (ملخص الرئيسية + كرت "الرحلة القادمة")
// الأرقام محسوبة من أعضاء المجموعة نفسهم (حتى تطابق قائمة الأعضاء)
// -------------------------------------------------------------
class SupervisorGroup extends Equatable {
  final String id;
  final String name;
  final int totalPilgrims;
  final int presentCount;
  final int absentCount;

  /// "الرحلة القادمة": العنوان والموعد والمكان
  final String nextTripTitle;
  final String nextTripDetails;

  const SupervisorGroup({
    required this.id,
    required this.name,
    required this.totalPilgrims,
    required this.presentCount,
    required this.absentCount,
    required this.nextTripTitle,
    required this.nextTripDetails,
  });

  @override
  List<Object?> get props => [id, name, totalPilgrims, presentCount, absentCount, nextTripTitle, nextTripDetails];
}
