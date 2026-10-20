import '../../../../core/l10n/tx.dart';

/// نصوص رئيسية الشركة (Figma 455:2885)
abstract final class CompanyHomeText {
  static const greeting = Tx('السلام عليكم', 'Assalamu Alaikum');
  static String greetingName(Object name) => tr('السلام عليكم، $name', 'Assalamu Alaikum, $name');
  static const activeTrips = Tx('الرحلات النشطة', 'Active trips');
  static const pilgrims = Tx('حجاج / معتمرين', 'Pilgrims');
  static const groups = Tx('المجموعات', 'Groups');
  static const supervisors = Tx('المشرفون', 'Supervisors');
  static const activeTripsSection = Tx('الرحلات النشطة', 'Active trips');
  static const showAll = Tx('عرض الكل', 'View all');
  static const createTrip = Tx('إنشاء رحلة', 'Create trip');
  static const createTripHint = Tx('إضافة رحلة جديدة', 'Add a new trip');
  // Figma: بين الكلمتين مسافتين
  static const createGroups = Tx('إنشاء  المجموعات', 'Create groups');
  static const createGroupsHint = Tx('تنظيم الأعضاء والمشرفين', 'Members & supervisors');
}
