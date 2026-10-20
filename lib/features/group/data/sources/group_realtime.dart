import '../../../../core/network/api_config.dart';
import '../../../../core/network/signalr_hub.dart';
import '../../../auth/data/token_refresher.dart';

// -------------------------------------------------------------
// الاتصال اللحظي (SignalR) — اتصال واحد لكل hub بيتشارك بين كل الشاشات:
//   events   (/hubs/events)   → "MessageReceived" (رسائل المجموعة) و "NotificationReceived" (إشعاراتي)
//   location (/hubs/location) → "LocationUpdated" و "StoppedSharing"
// السيرفر بيشترك بمجموعاتي لحظة الاتصال بس — فلما مجموعتي تتغيّر (الشركة ضافتني أو نقلتني) بنعيد الاتصال
// التوكن بينطلب مع كل اتصال (مجدَّد لو انتهى) — الاختبارات بتبدّل الـ hubs
// -------------------------------------------------------------
abstract final class GroupRealtime {
  static SignalRHub events = SignalRHub(uri: ApiConfig.eventsHub, accessToken: TokenRefresher.validAccessToken);
  static SignalRHub location = SignalRHub(uri: ApiConfig.locationHub, accessToken: TokenRefresher.validAccessToken);

  static bool _known = false;
  static String? _groupId;

  /// آخر مجموعة رجعت من /home
  static Future<void> groupSeen(String? groupId) async {
    final changed = _known && groupId != _groupId;
    _known = true;
    _groupId = groupId;
    if (changed) {
      await events.restart();
      await location.restart();
    }
  }

  /// تسجيل الخروج: الحساب الجاي بيبدأ من جديد
  static void reset() {
    _known = false;
    _groupId = null;
  }
}
