import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/common_text.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../auth/data/auth_session.dart';
import '../../../auth/presentation/pages/auth_welcome_screen.dart';
import '../../../family/presentation/controllers/family_controller.dart';
import '../../../group/data/sources/group_realtime.dart';
import '../../../group/presentation/controllers/group_controller.dart';
import '../../data/repositories/company_repository_impl.dart';
import '../../domain/entities/company_group.dart';
import '../../domain/entities/company_trip.dart';
import '../../domain/repositories/company_repository.dart';
import '../cubits/company_notifications_cubit.dart';
import '../pages/company_contact_screen.dart';
import '../pages/company_create_trip_screen.dart';
import '../pages/company_data_screen.dart';
import '../pages/company_group_detail_screen.dart';
import '../pages/company_member_page_screen.dart';
import '../pages/company_members_screen.dart';
import '../pages/company_notifications_screen.dart';
import '../pages/company_settings_screen.dart';

// -------------------------------------------------------------
// التنقل بواجهة الشركة (كل الشاشات المدفوعة من هنا)
// -------------------------------------------------------------
abstract final class CompanyController {
  static CompanyRepository Function() repository = CompanyRepositoryImpl.new;

  static void comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(CommonText.comingSoon()), duration: const Duration(milliseconds: 1600)));
  }

  static Future<void> openNotifications(BuildContext context) {
    final repo = context.read<CompanyRepository>();
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => CompanyNotificationsCubit(repo)..load(), child: const CompanyNotificationsScreen())),
    );
  }

  /// "إنشاء رحلة" / "+ إنشاء رحلة جديدة" → شاشة إنشاء رحلة
  static void createTrip(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyCreateTripScreen()));

  /// "إنشاء المجموعات"
  static void createGroups(BuildContext context) => comingSoon(context);

  /// "عرض تفاصيل الرحلة"
  static void openTrip(BuildContext context, CompanyTrip trip) => comingSoon(context);

  /// الملف الشخصي → بيانات الشركة
  static void openCompanyData(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyDataScreen()));

  /// الملف الشخصي → معلومات التواصل
  static void openContact(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyContactScreen()));

  /// الملف الشخصي → الإعدادات
  static void openSettings(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanySettingsScreen()));

  /// تفاصيل المجموعة
  static void openGroupDetail(BuildContext context, CompanyGroup group) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyGroupDetailScreen(group: group)));

  /// قائمة أعضاء المجموعة
  static void openMembers(BuildContext context, CompanyGroup group) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyMembersScreen(group: group)));

  /// صفحة عضو
  static void openMemberPage(BuildContext context, {required String memberId, required String name}) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyMemberPageScreen(memberId: memberId, name: name)));

  /// تسجيل الخروج (نفس نمط PilgrimAccountController.logout)
  static Future<void> logout(BuildContext context) async {
    await FamilyController.stopLocationSharing();
    await GroupController.stopLocationSharing();
    await TokenStorage.clearTokens();
    await AuthSession.clear();
    GroupRealtime.reset();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const AuthWelcomeScreen()), (route) => false);
  }
}
