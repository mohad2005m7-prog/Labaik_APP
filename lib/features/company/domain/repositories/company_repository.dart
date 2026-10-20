import '../entities/company_group.dart';
import '../entities/company_notification.dart';
import '../entities/company_overview.dart';
import '../entities/company_trip.dart';

// -------------------------------------------------------------
// بيانات واجهة الشركة — الشاشات والـ Cubits بتتعامل مع هالعقد بس
// -------------------------------------------------------------
abstract class CompanyRepository {
  Future<CompanyOverview> overview();

  /// كل رحلات الشركة (الفلترة "القادمة" / "الراحلة" والبحث بالشاشة)
  Future<List<CompanyTrip>> trips();

  /// من الأحدث للأقدم
  Future<List<CompanyNotification>> notifications();

  /// مجموعات الشركة
  Future<List<CompanyGroup>> groups();
}
