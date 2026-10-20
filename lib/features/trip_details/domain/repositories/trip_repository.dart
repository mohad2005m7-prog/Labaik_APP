import '../entities/trip.dart';

/// رحلة الحساب الحالي: محفوظة على الجهاز وبتوصل للسيرفر (/journeys) بالخلفية
abstract interface class TripRepository {
  Future<Trip> load();

  Future<void> save(Trip trip);

  /// الجهاز ما عليه رحلة: رحلته من السيرفر (null = ما عنده، أو ما زبط الطلب)
  Future<Trip?> restore();
}
