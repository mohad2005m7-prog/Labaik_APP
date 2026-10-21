// -------------------------------------------------------------
// عناوين سيرفر لبيك (C# ASP.NET Core) — حسب ملف "تحديثات Labaik API لفريق Flutter" (16 أكتوبر 2026)
// الـ REST تحت /api/v1 — والوقت الحقيقي (SignalR) تحت /hubs
// اللي التطبيق لسا بيستناه وما انضاف للسيرفر: docs/backend_pending.md
// -------------------------------------------------------------
abstract final class ApiConfig {
  static const host = 'labaik-api.onrender.com';

  /// أساس طلبات الـ REST
  static const baseUrl = 'https://$host/api/v1';

  /// مهلة الطلب: السيرفر (Render المجاني) بينام بعد 15 دقيقة خمول، وأول طلب بعدها ممكن ياخد حوالي 50 ثانية
  static const timeout = Duration(seconds: 60);

  /// رسائل دردشة المجموعة (MessageReceived) والإشعارات (NotificationReceived)
  static final eventsHub = Uri.parse('wss://$host/hubs/events');

  /// مواقع أفراد المجموعة لحظياً (LocationUpdated / StoppedSharing)
  static final locationHub = Uri.parse('wss://$host/hubs/location');
}
