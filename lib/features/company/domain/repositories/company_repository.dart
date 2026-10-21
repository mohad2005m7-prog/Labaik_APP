import '../entities/company_group.dart';
import '../entities/company_member.dart';
import '../entities/company_notification.dart';
import '../entities/company_overview.dart';
import '../entities/company_profile.dart';
import '../entities/company_trip.dart';

// -------------------------------------------------------------
// بيانات واجهة الشركة — الشاشات والـ Cubits بتتعامل مع هالعقد بس
// -------------------------------------------------------------
abstract class CompanyRepository {
  Future<CompanyOverview> overview();

  /// بيانات الشركة (GET /company/me)
  Future<CompanyProfile> profile();

  /// حفظ بيانات الشركة (PUT /company/me — استبدال كامل) وبترجع المحفوظ
  Future<CompanyProfile> updateProfile(CompanyProfile profile);

  /// رفع شعار الشركة (صورة من الجهاز) → رابطه — بعدها updateProfile بـ logoUrl
  Future<String> uploadLogo(String filePath);

  /// كل رحلات الشركة (الفلترة "القادمة" / "الراحلة" والبحث بالشاشة)
  Future<List<CompanyTrip>> trips();

  Future<CompanyTrip> createTrip(TripDraft draft);

  /// من الأحدث للأقدم
  Future<List<CompanyNotification>> notifications();

  /// مجموعات الشركة (كل رحلاتها)
  Future<List<CompanyGroup>> groups();

  /// مجموعة جديدة تحت رحلة (بتبدأ بلا مشرف)
  Future<CompanyGroup> createGroup({required String tripId, required String name, String? notes, int? capacity});

  /// تعديل المجموعة: الاسم والملاحظات والسعة (null = بلا)
  Future<CompanyGroup> updateGroup(String groupId, {required String name, String? notes, int? capacity});

  /// حذف مجموعة فاضية (409 Group.HasMembers لو فيها معتمرين)
  Future<void> deleteGroup(String groupId);

  /// كل معتمري الشركة (بلا تكرار) — [search] بالاسم أو الإيميل
  Future<List<CompanyPilgrim>> pilgrims({String? search});

  /// المشرف أول، وبعده المعتمرين بالرقم
  Future<List<CompanyMember>> members(String groupId);

  /// بطاقة العضو (مع الملاحظات الصحية)
  Future<CompanyMember> member(String groupId, String userId);

  /// إضافة معتمر بالإيميل — لو مش مسجّل السيرفر بينشئ حسابه ويبعتله كلمة مؤقتة
  Future<CompanyGroup> addMember(String groupId, {required String email, String? fullName, String? phone});

  /// حذف معتمر من المجموعة
  Future<void> removeMember(String groupId, String userId);

  /// قائمة مشرفي الشركة
  Future<List<CompanySupervisor>> supervisors();

  /// إضافة مشرف لقائمة الشركة (كلمة مؤقتة بالإيميل)
  Future<CompanySupervisor> addSupervisor({required String fullName, required String email, String? phone});

  /// حذف مشرف من قائمة الشركة (409 لو لسا بيشرف على مجموعة)
  Future<void> removeSupervisor(String userId);

  /// إيقاف حساب مشرف (ما بيقدر يدخل) أو تفعيله
  Future<void> setSupervisorSuspended(String userId, {required bool suspended});

  /// كلمة مرور مؤقتة جديدة للمشرف (بتنبعتله بالإيميل وبترجع هون مرة وحدة) — "" لو السيرفر ما رجّعها
  Future<String> supervisorTempPassword(String userId);

  /// تعيين (أو تبديل) مشرف المجموعة — لازم يكون بقائمة الشركة
  Future<CompanyGroup> assignSupervisor(String groupId, String email);
}
