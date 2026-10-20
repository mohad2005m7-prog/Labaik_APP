import '../entities/app_notification.dart';

// -------------------------------------------------------------
// إشعارات المعتمر (من الجرس بالرئيسية)
// -------------------------------------------------------------
abstract class NotificationsRepository {
  /// من الأحدث للأقدم
  Future<List<AppNotification>> list();

  /// فتح الشاشة: كلها صارت مقروءة
  Future<void> markAllRead();

  /// إشعار جديد وصل لحظياً
  Stream<void> changes();
}
