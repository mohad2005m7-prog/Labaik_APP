import '../../../../core/utils/json_fields.dart';

// -------------------------------------------------------------
// خدمات شركة المعتمر المفعّلة (enabledServices من GET /home) — الشركة أو الأدمن بيقفلوا خدمة
// فبنخبّر المعتمر "غير مفعّلة لشركتك" بدل ما تفتح شاشة وتفشل (السيرفر بيرجّع 403 Company.ServiceDisabled)
// null من السيرفر (معتمر بلا شركة أو سيرفر أقدم) = كله مفعّل
// -------------------------------------------------------------
class CompanyServices {
  final bool gpsTracking;
  final bool duaAndRituals;
  final bool instantNotifications;
  final bool chatWithGuides;

  const CompanyServices({this.gpsTracking = true, this.duaAndRituals = true, this.instantNotifications = true, this.chatWithGuides = true});

  static const all = CompanyServices();

  /// آخر قيمة وصلت من /home (بتتحدّث كل ما انطلب /home)
  static CompanyServices current = all;

  static CompanyServices fromHome(Object? home) {
    final json = home is Map<String, dynamic> ? home.field('enabledServices') : null;
    if (json is! Map<String, dynamic>) return all;
    bool flag(String name) => json.field(name) != false;
    return CompanyServices(gpsTracking: flag('gpsTracking'), duaAndRituals: flag('duaAndRituals'), instantNotifications: flag('instantNotifications'), chatWithGuides: flag('chatWithGuides'));
  }
}
