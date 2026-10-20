import 'package:url_launcher/url_launcher.dart';

import 'geo_utils.dart';

// -------------------------------------------------------------
// فتح تطبيقات الجهاز: الاتصال (شاشة الاتصال والرقم جاهز — المستخدم بيضغط اتصال) وفتح موقع على الخريطة
// -------------------------------------------------------------
abstract final class AppLauncher {
  /// false لو الجهاز ما فيه تطبيق اتصال
  static Future<bool> call(String phone) async {
    final number = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (number.isEmpty) return false;
    try {
      return await launchUrl(Uri(scheme: 'tel', path: number));
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openMap(GeoPoint point) async {
    final url = Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': '${point.latitude},${point.longitude}'});
    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
