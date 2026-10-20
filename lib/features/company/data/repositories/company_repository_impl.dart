import '../../../auth/data/auth_session.dart';
import '../../domain/entities/company_group.dart';
import '../../domain/entities/company_notification.dart';
import '../../domain/entities/company_overview.dart';
import '../../domain/entities/company_trip.dart';
import '../../domain/repositories/company_repository.dart';

// -------------------------------------------------------------
// واجهة الشركة: سيرفر لبيك لسا ما فيه حساب شركة ولا رحلاتها ولا مجموعاتها ولا إشعاراتها (docs/backend_pending.md)
// فالموجود بس: اسم صاحب الحساب (من رد الدخول) — والباقي فاضي/0 لحد ما ينضافوا (ما في بيانات تجريبية)
// -------------------------------------------------------------
class CompanyRepositoryImpl implements CompanyRepository {
  @override
  Future<CompanyOverview> overview() async {
    final name = (await AuthSession.current())?.fullName.trim() ?? '';
    return CompanyOverview(firstName: name.isEmpty ? '' : name.split(RegExp(r'\s+')).first);
  }

  @override
  Future<List<CompanyTrip>> trips() async => const [];

  @override
  Future<List<CompanyNotification>> notifications() async => const [];

  @override
  Future<List<CompanyGroup>> groups() async => const [];
}
