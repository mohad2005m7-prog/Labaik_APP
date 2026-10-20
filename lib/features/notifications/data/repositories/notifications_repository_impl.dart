import '../../../group/data/sources/group_realtime.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../models/app_notification_json.dart';
import '../sources/notifications_api.dart';

// -------------------------------------------------------------
// إشعارات المعتمر من السيرفر: GET /notifications و POST /notifications/read-all
// والجديد لحظياً من "NotificationReceived" (/hubs/events)
// -------------------------------------------------------------
class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl({NotificationsApi? api}) : _api = api ?? NotificationsApi.server();

  final NotificationsApi _api;

  @override
  Future<List<AppNotification>> list() async => [for (final json in await _api.list()) ?AppNotificationJson.fromJson(json)];

  @override
  Future<void> markAllRead() => _api.readAll();

  @override
  Stream<void> changes() => GroupRealtime.events.on('NotificationReceived').map((_) {});
}
