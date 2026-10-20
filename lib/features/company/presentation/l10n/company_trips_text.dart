import '../../../../core/l10n/tx.dart';

/// نصوص تبويب "الرحلات" (Figma 467:4774 / 560:2964 / 563:3629)
abstract final class CompanyTripsText {
  static const title = Tx('الرحلات', 'Trips');
  static const search = Tx('ابحث عن الرحلة', 'Search for a trip');
  static const all = Tx('الكل', 'All');
  static const upcoming = Tx('القادمة', 'Upcoming');
  static const departed = Tx('الراحلة', 'Departed');
  static const allTrips = Tx('جميع الرحلات', 'All trips');
  static const statusUpcoming = Tx('قادمة', 'Upcoming');
  static const statusDeparted = Tx('راحلة', 'Departed');
  // Figma: "عرض التفاصيل الرحلة" — مصلّحة
  static const details = Tx('عرض تفاصيل الرحلة', 'View trip details');
  static const createTrip = Tx('+ إنشاء رحلة جديدة', '+ Create a new trip');

  // تفاصيل الرحلة (738:4590)
  static const detailsTitle = Tx('تفاصيل الرحلة', 'Trip Details');
  static const groupsStat = Tx('مجموعات', 'Groups');
  static const pilgrimsStat = Tx('معتمر', 'Pilgrims');
  static const supervisorsStat = Tx('المشرفين', 'Supervisors');
  static const distribution = Tx('توزيع المجموعة', 'Group distribution');

  // مش بـ Figma: القائمة فاضية
  static const empty = Tx('لا توجد رحلات بعد', 'No trips yet');
  static const noResults = Tx('لا توجد نتائج', 'No results');
}
