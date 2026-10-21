import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/api_error_text.dart';
import '../../../../core/l10n/common_text.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../auth/data/auth_session.dart';
import '../../../auth/data/token_refresher.dart';
import '../../../auth/presentation/pages/auth_welcome_screen.dart';
import '../../../auth/presentation/pages/create_new_password_screen.dart';
import '../../../chats/presentation/controllers/chats_controller.dart';
import '../../../family/presentation/controllers/family_controller.dart';
import '../../../group/data/sources/group_realtime.dart';
import '../../../group/presentation/controllers/group_controller.dart';
import '../../../supervisor/domain/entities/group_member.dart';
import '../../../supervisor/presentation/pages/member_details_screen.dart';
import '../../../terms/presentation/controllers/terms_controller.dart';
import '../../data/repositories/company_repository_impl.dart';
import '../../domain/entities/company_group.dart';
import '../../domain/entities/company_member.dart';
import '../../domain/entities/company_notification.dart';
import '../../domain/entities/company_profile.dart';
import '../../domain/entities/company_trip.dart';
import '../../domain/repositories/company_repository.dart';
import '../cubits/company_groups_cubit.dart';
import '../cubits/company_home_cubit.dart';
import '../cubits/company_notifications_cubit.dart';
import '../cubits/company_profile_cubit.dart';
import '../cubits/company_trips_cubit.dart';
import '../l10n/company_forms_text.dart';
import '../pages/company_add_supervisor_screen.dart';
import '../pages/company_contact_screen.dart';
import '../pages/company_create_group_screen.dart';
import '../pages/company_create_trip_screen.dart';
import '../pages/company_data_screen.dart';
import '../pages/company_group_detail_screen.dart';
import '../pages/company_help_screen.dart';
import '../pages/company_members_screen.dart';
import '../pages/company_notifications_screen.dart';
import '../pages/company_pilgrims_screen.dart';
import '../pages/company_settings_screen.dart';
import '../pages/company_supervisor_screen.dart';
import '../pages/company_supervisors_screen.dart';
import '../pages/company_trip_details_screen.dart';
import '../widgets/company_tab_bar.dart';

// -------------------------------------------------------------
// التنقل بواجهة الشركة (كل الشاشات المدفوعة من هنا) — والتحديث بعد أي تعديل
// -------------------------------------------------------------
abstract final class CompanyController {
  static CompanyRepository Function() repository = CompanyRepositoryImpl.new;

  static void comingSoon(BuildContext context) => showMessage(context, CommonText.comingSoon());

  static void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(milliseconds: 2400)));
  }

  /// رسالة خطأ السيرفر (انقطاع، صلاحية، ...)
  static void showError(BuildContext context, Object error) => showMessage(context, ApiErrorText.of(error)());

  /// بعد أي تعديل: الأرقام بالرئيسية والقوائم والملف الشخصي بتتحدّث من السيرفر
  static void refreshAll(BuildContext context) {
    context.read<CompanyHomeCubit>().load();
    context.read<CompanyTripsCubit>().load();
    context.read<CompanyGroupsCubit>().load();
    context.read<CompanyProfileCubit>().load();
  }

  /// كروت الرئيسية: "الرحلات النشطة" → تبويب الرحلات (الكل)، "المجموعات" → تبويب المجموعات
  static void openTab(BuildContext context, CompanyTab tab) {
    if (tab == CompanyTab.trips) context.read<CompanyTripsCubit>().select(CompanyTripsFilter.all);
    context.read<CompanyTabSwitch>().select(tab);
  }

  static Future<void> openNotifications(BuildContext context) {
    final repo = context.read<CompanyRepository>();
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RepositoryProvider.value(
          value: repo,
          child: BlocProvider(create: (_) => CompanyNotificationsCubit(repo)..load(), child: const CompanyNotificationsScreen()),
        ),
      ),
    );
  }

  /// الضغط على إشعار → موضوعه: المجموعة (3، 5، 13، 14) أو المشرف (4، 16، 17)
  static Future<void> openNotification(BuildContext context, CompanyNotification n) async {
    final repo = context.read<CompanyRepository>();
    final groupId = n.groupId;
    if (groupId != null && groupId.isNotEmpty) {
      try {
        final group = (await repo.groups()).where((g) => g.id == groupId).firstOrNull;
        if (!context.mounted) return;
        if (group == null) return showMessage(context, CompanyFormsText.groupGone());
        await openGroupFrom(context, repo, group);
      } catch (e) {
        if (context.mounted) showError(context, e);
      }
      return;
    }
    if (n.type == 4 || n.type == 16 || n.type == 17) await openSupervisor(context, repo, userId: n.referenceId, name: n.body);
  }

  // ───────── الرحلات ─────────

  /// "إنشاء رحلة" / "+ إنشاء رحلة جديدة" → شاشة إنشاء رحلة (POST /company/trips)
  static Future<void> createTrip(BuildContext context) async {
    final repo = context.read<CompanyRepository>();
    final created = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => CompanyCreateTripScreen(repository: repo)));
    if (created == true && context.mounted) refreshAll(context);
  }

  /// "عرض تفاصيل الرحلة" → تفاصيل الرحلة ومجموعاتها
  static Future<void> openTrip(BuildContext context, CompanyTrip trip) async {
    final repo = context.read<CompanyRepository>();
    final changed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => CompanyTripDetailsScreen(trip: trip, repository: repo)));
    if (changed == true && context.mounted) refreshAll(context);
  }

  // ───────── المجموعات ─────────

  /// "إنشاء المجموعات" / "إنشاء مجموعة" → صفحة "إنشاء مجموعة جديدة" (الرحلة والاسم والمشرف) ← رمز الانضمام
  static Future<void> createGroups(BuildContext context, {CompanyTrip? trip}) async {
    final repo = context.read<CompanyRepository>();
    List<CompanyTrip> trips;
    List<CompanySupervisor> roster;
    try {
      final cached = context.read<CompanyTripsCubit>().state.trips;
      final results = await Future.wait<Object>([if (cached.isEmpty) repo.trips() else Future.value(cached), repo.supervisors().catchError((_) => const <CompanySupervisor>[])]);
      trips = results[0] as List<CompanyTrip>;
      roster = results[1] as List<CompanySupervisor>;
    } catch (e) {
      if (context.mounted) showError(context, e);
      return;
    }
    if (!context.mounted) return;
    if (trips.isEmpty) return showMessage(context, CompanyFormsText.needTripFirst());
    final created = await Navigator.push<CompanyGroup>(
      context,
      MaterialPageRoute(builder: (_) => CompanyCreateGroupScreen(repository: repo, trips: trip == null ? trips : [trip], supervisors: roster)),
    );
    if (created != null && context.mounted) refreshAll(context);
  }

  /// تفاصيل المجموعة — لما يرجع وفي تغيير بنحدّث الأرقام والقوائم
  static Future<bool> openGroupDetail(BuildContext context, CompanyGroup group, {bool refresh = true}) async {
    final repo = context.read<CompanyRepository>();
    final trips = context.read<CompanyTripsCubit>().state.trips;
    final trip = trips.where((t) => t.id == group.tripId).firstOrNull;
    final changed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => CompanyGroupDetailScreen(group: group, repository: repo, trip: trip))) ?? false;
    if (changed && refresh && context.mounted) refreshAll(context);
    return changed;
  }

  /// تفاصيل مجموعة من أي شاشة (صفحة المشرف مثلاً) — بنجيب رحلتها حتى يطلع تاريخها
  static Future<bool> openGroupFrom(BuildContext context, CompanyRepository repo, CompanyGroup group) async {
    CompanyTrip? trip;
    try {
      trip = (await repo.trips()).where((t) => t.id == group.tripId).firstOrNull;
    } catch (_) {
      // بلا تاريخ الرحلة
    }
    if (!context.mounted) return false;
    return await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => CompanyGroupDetailScreen(group: group, repository: repo, trip: trip))) ?? false;
  }

  /// "حجاج / معتمرين" → كل الحجاج والمعتمرين بمجموعات الشركة ([trip] = رحلة وحدة بس)
  static Future<bool> openPilgrims(BuildContext context, CompanyRepository repo, {CompanyTrip? trip}) async =>
      await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => CompanyPilgrimsScreen(repository: repo, trip: trip))) ?? false;

  /// صفحة مشرف (من اسمه بكرت المجموعة أو من قائمة الأعضاء) — بترجع true لو تغيّر (إيقاف أو حذف)
  static Future<bool> openSupervisor(BuildContext context, CompanyRepository repo, {String? userId, String? name}) async {
    CompanySupervisor? found;
    try {
      final roster = await repo.supervisors();
      found = roster.where((s) => s.userId == userId).firstOrNull ?? roster.where((s) => name != null && s.name == name).firstOrNull;
    } catch (e) {
      if (context.mounted) showError(context, e);
      return false;
    }
    if (!context.mounted) return false;
    if (found == null) {
      showMessage(context, CompanyFormsText.supervisorNotFound());
      return false;
    }
    final supervisor = found;
    return await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => CompanySupervisorScreen(supervisor: supervisor, repository: repo))) ?? false;
  }

  /// أعضاء المجموعة — بترجع عدد المعتمرين الجديد لو تغيّر (إضافة أو حذف)، وإلا null
  static Future<int?> openMembers(BuildContext context, CompanyRepository repo, CompanyGroup group) =>
      Navigator.push<int>(context, MaterialPageRoute(builder: (_) => CompanyMembersScreen(group: group, repository: repo)));

  /// صفحة العضو — نفس صفحة "صفحة احد الاعضاء" عند المشرف (Figma واحد)
  static Future<void> openMemberPage(BuildContext context, CompanyRepository repo, {required String groupId, required CompanyMember member}) async {
    var m = member;
    try {
      m = await repo.member(groupId, member.userId);
    } catch (_) {
      // بنعرض اللي عنا من القائمة
    }
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MemberDetailsScreen(
          member: GroupMember(id: m.userId, name: m.name, photo: m.photoUrl, present: m.present, number: m.number, email: m.email, nationality: m.nationality, health: m.healthNotes, notes: m.notes),
          // الشركة ما إلها دردشة فردية (السيرفر: بين المعتمر ومشرفه بس) → إيميل المعتمر
          onContact: (ctx) => _emailMember(ctx, m.email),
        ),
      ),
    );
  }

  static Future<void> _emailMember(BuildContext context, String? email) async {
    if (email == null || email.trim().isEmpty) return showMessage(context, CompanyFormsText.noEmail());
    final opened = await launchUrl(Uri(scheme: 'mailto', path: email.trim()));
    if (!opened && context.mounted) showMessage(context, email.trim());
  }

  /// "رؤية الدردشة" بتفاصيل المجموعة → دردشة المجموعة (قراءة بس)
  static Future<void> openGroupChat(BuildContext context, CompanyGroup group) => ChatsController.openCompanyGroupChat(context, groupId: group.id, title: group.name);

  // ───────── المشرفين ─────────

  /// "إدارة المشرفين"
  static void openSupervisors(BuildContext context) {
    final repo = context.read<CompanyRepository>();
    Navigator.push(context, MaterialPageRoute(builder: (_) => CompanySupervisorsScreen(repository: repo))).then((_) {
      if (context.mounted) refreshAll(context);
    });
  }

  /// "إضافة مشرف جديد" (POST /company/supervisors — بتوصله كلمة مؤقتة بالإيميل) — بترجع المشرف لو انضاف
  static Future<CompanySupervisor?> openAddSupervisor(BuildContext context, CompanyRepository repo) =>
      Navigator.push<CompanySupervisor>(context, MaterialPageRoute(builder: (_) => CompanyAddSupervisorScreen(repository: repo)));

  // ───────── الملف الشخصي ─────────

  /// "بيانات الشركة" (القلم) → تعديل بيانات الشركة
  static Future<void> openCompanyData(BuildContext context) => _editProfile(context, (repo, p) => CompanyDataScreen(repository: repo, profile: p));

  /// "معلومات التواصل"
  static Future<void> openContact(BuildContext context) => _editProfile(context, (repo, p) => CompanyContactScreen(repository: repo, profile: p));

  static Future<void> _editProfile(BuildContext context, Widget Function(CompanyRepository, CompanyProfile) screen) async {
    final repo = context.read<CompanyRepository>();
    final cubit = context.read<CompanyProfileCubit>();
    var profile = cubit.state.profile;
    if (profile == null) {
      try {
        profile = await repo.profile();
      } catch (e) {
        if (context.mounted) showError(context, e);
        return;
      }
    }
    if (!context.mounted) return;
    final saved = await Navigator.push<CompanyProfile>(context, MaterialPageRoute(builder: (_) => screen(repo, profile!)));
    if (saved != null && context.mounted) {
      cubit.set(saved);
      context.read<CompanyHomeCubit>().load();
    }
  }

  /// "المساعدة والدعم"
  static void openHelp(BuildContext context) {
    final profile = context.read<CompanyProfileCubit>().state.profile;
    Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyHelpScreen(companyName: profile?.name ?? '', supportEmail: profile?.supportEmail)));
  }

  /// الترس → الإعدادات
  static void openSettings(BuildContext context) {
    final profile = context.read<CompanyProfileCubit>();
    final home = context.read<CompanyHomeCubit>();
    final repo = context.read<CompanyRepository>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [BlocProvider.value(value: profile), BlocProvider.value(value: home)],
          child: RepositoryProvider.value(value: repo, child: const CompanySettingsScreen()),
        ),
      ),
    );
  }

  static void changePassword(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateNewPasswordScreen.change()));

  static void openTerms(BuildContext context) => TermsController.open(context);

  /// تسجيل الخروج (نفس نمط PilgrimAccountController.logout)
  static Future<void> logout(BuildContext context) async {
    await FamilyController.stopLocationSharing();
    await GroupController.stopLocationSharing();
    await TokenRefresher.revoke();
    await TokenStorage.clearTokens();
    await AuthSession.clear();
    GroupRealtime.reset();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const AuthWelcomeScreen()), (route) => false);
  }
}
