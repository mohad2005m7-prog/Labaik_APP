import 'package:equatable/equatable.dart';

// -------------------------------------------------------------
// برنامج الرحلة: أيام (تبويبات "اليوم (1)"...) وكل يوم إله أنشطة بأوقاتها
// -------------------------------------------------------------

/// نوع مكان النشاط — بيحدد أيقونة الدائرة (فندق / الحرم)
enum ActivityPlace { hotel, haram }

class TripActivity extends Equatable {
  final String time;
  final String title;
  final String place;
  final ActivityPlace kind;

  const TripActivity({required this.time, required this.title, required this.place, required this.kind});

  @override
  List<Object?> get props => [time, title, place, kind];
}

class TripDay extends Equatable {
  final int number;

  /// "10 أكتوبر 2026 اليوم الأول"
  final String dateLabel;
  final List<TripActivity> activities;

  /// تاريخ اليوم (من السيرفر) — null بالبيانات القديمة
  final DateTime? date;

  const TripDay({required this.number, required this.dateLabel, required this.activities, this.date});

  @override
  List<Object?> get props => [number, dateLabel, activities, date];
}
