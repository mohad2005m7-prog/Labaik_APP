import '../../../../core/l10n/tx.dart';

/// نصوص "أفراد عائلتي على الخريطة" (111:6522) — بنفس كتابة Figma
abstract final class FamilyMapText {
  static const title = Tx('أفراد عائلتي على الخريطة', 'My family on the map');
  static const description = Tx('ابقَ قريبًا ممن تحب، وتابع مواقع أفراد عائلتك بسهولة.', 'Stay close to your loved ones and follow your family easily.');

  static const online = Tx('متصلون بالانترنت', 'Online');
  static const offline = Tx('غير متصلون بالانترنت', 'Offline');
  static const meetingPoint = Tx('نقطة التجمع', 'Meeting point');
  static const you = Tx('موقعك أنت', 'You');

  /// اسمي على الخريطة
  static const me = Tx('أنت', 'You');

  /// "8  أفراد يشاركون مواقعهم" (العدد حسب قواعد العربي)
  static String sharing(int count) {
    if (!AppLanguage.isArabic) return count == 1 ? '1 member shares their location' : '$count members share their locations';
    if (count == 0) return 'لا يوجد أفراد يشاركون مواقعهم';
    if (count == 1) return 'فرد واحد يشارك موقعه';
    if (count == 2) return 'فردان يشاركان مواقعهما';
    if (count <= 10) return '$count  أفراد يشاركون مواقعهم';
    return '$count فردًا يشاركون مواقعهم';
  }
}
