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
import '../cubits/company_groups_cubit.dart';
import '../cubits/company_home_cubit.dart';
import '../cubits/company_notifications_cubit.dart';
import '../cubits/company_trips_cubit.dart';
import '../l10n/company_forms_text.dart';
import '../widgets/company_form_sheet.dart';
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
typedef CompanySupervisorLike = ({String name, String email});

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

  static void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(milliseconds: 2400)));
  }

  /// بعد أي تعديل (رحلة/مجموعة/عضو/مشرف): الأرقام بالرئيسية والقوائم بتتحدّث من السيرفر
  static void refreshAll(BuildContext context) {
    context.read<CompanyHomeCubit>().load();
    context.read<CompanyTripsCubit>().load();
    context.read<CompanyGroupsCubit>().load();
  }

  /// "إنشاء رحلة" / "+ إنشاء رحلة جديدة" → شاشة إنشاء رحلة (POST /company/trips)
  static Future<void> createTrip(BuildContext context) async {
    final repo = context.read<CompanyRepository>();
    final created = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => CompanyCreateTripScreen(repository: repo)));
    if (created == true && context.mounted) refreshAll(context);
  }

  /// "إنشاء المجموعات" / "إنشاء مجموعة": نختار الرحلة ونكتب الاسم (POST /company/trips/{id}/groups)
  /// بعدها بيطلع رمز المجموعة اللي بيدخله المعتمر حتى ينضم
  static Future<void> createGroups(BuildContext context) async {
    final repo = context.read<CompanyRepository>();
    var trips = context.read<CompanyTripsCubit>().state.trips;
    if (trips.isEmpty) {
      try {
        trips = await repo.trips();
      } catch (_) {}
    }
    if (!context.mounted) return;
    if (trips.isEmpty) return showMessage(context, CompanyFormsText.needTripFirst());
    final choice = CompanySheetChoice(label: CompanyFormsText.trip(), labels: [for (final t in trips) t.title]);
    final name = CompanySheetField(label: CompanyFormsText.groupName(), hint: CompanyFormsText.groupNameHint());
    CompanyGroup? group;
    final done = await CompanyFormSheet.show(
      context,
      CompanyFormSheet(
        title: CompanyFormsText.createGroupTitle(),
        subtitle: CompanyFormsText.createGroupSubtitle(),
        choice: choice,
        fields: [name],
        submitLabel: CompanyFormsText.create(),
        onSubmit: () async => group = await repo.createGroup(tripId: trips[choice.index].id, name: name.value),
      ),
    );
    if (!done || !context.mounted) return;
    refreshAll(context);
    showMessage(context, CompanyFormsText.groupCreated(group?.joinCode ?? ''));
  }

  /// "عرض تفاصيل الرحلة"
  static void openTrip(BuildContext context, CompanyTrip trip) => comingSoon(context);

  /// الملف الشخصي → بيانات الشركة
  static void openCompanyData(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyDataScreen()));

  /// الملف الشخصي → معلومات التواصل
  static void openContact(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyContactScreen()));

  /// الملف الشخصي → الإعدادات
  static void openSettings(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanySettingsScreen()));

  /// تفاصيل المجموعة (رمز الانضمام، المشرف، الأعضاء) — لما يرجع بنحدّث الأرقام والقوائم
  static Future<void> openGroupDetail(BuildContext context, CompanyGroup group) async {
    final repo = context.read<CompanyRepository>();
    final changed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => CompanyGroupDetailScreen(group: group, repository: repo)));
    if (changed == true && context.mounted) refreshAll(context);
  }

  /// قائمة أعضاء المجموعة — بترجع true لو انضاف عضو
  static Future<bool> openMembers(BuildContext context, CompanyRepository repo, CompanyGroup group) async =>
      await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => CompanyMembersScreen(group: group, repository: repo))) ?? false;

  /// صفحة عضو
  static void openMemberPage(BuildContext context, CompanyRepository repo, {required String groupId, required String memberId, required String name}) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CompanyMemberPageScreen(repository: repo, groupId: groupId, memberId: memberId, name: name)),
      );

  /// مشرف المجموعة: نختار من مشرفي الشركة (PUT /company/groups/{id}/supervisor)
  /// أو "إضافة مشرف جديد" (POST /company/supervisors — بتوصله كلمة مؤقتة) وبعدها بيتعيّن مباشرة
  static Future<CompanyGroup?> assignSupervisor(BuildContext context, CompanyRepository repo, CompanyGroup group) async {
    List<CompanySupervisorLike> roster;
    try {
      roster = [for (final s in await repo.supervisors()) (name: s.name, email: s.email)];
    } catch (e) {
      if (context.mounted) showMessage(context, CompanyFormsText.loadFailed());
      return null;
    }
    if (!context.mounted) return null;
    // الشركة لسا ما عندها مشرفين: مباشرة لنموذج الإضافة
    if (roster.isEmpty) return _addAndAssign(context, repo, group);
    final current = roster.indexWhere((s) => s.name == group.supervisorName);
    // آخر خيار "+ إضافة مشرف جديد" بيفتح نموذج الإضافة
    final choice = CompanySheetChoice(
      label: CompanyFormsText.supervisor(),
      labels: [for (final s in roster) '${s.name} (${s.email})', '+ ${CompanyFormsText.newSupervisor()}'],
      index: current < 0 ? 0 : current,
    );
    CompanyGroup? updated;
    var wantsNew = false;
    final done = await CompanyFormSheet.show(
      context,
      CompanyFormSheet(
        title: CompanyFormsText.assignTitle(),
        subtitle: CompanyFormsText.assignSubtitle(),
        choice: choice,
        fields: const [],
        submitLabel: CompanyFormsText.assign(),
        notFoundMessage: CompanyFormsText.supervisorNotOnRoster(),
        onSubmit: () async {
          if (choice.index >= roster.length) {
            wantsNew = true;
            return;
          }
          updated = await repo.assignSupervisor(group.id, roster[choice.index].email);
        },
      ),
    );
    if (!context.mounted || !done) return null;
    if (wantsNew) return _addAndAssign(context, repo, group);
    showMessage(context, CompanyFormsText.assigned());
    return updated;
  }

  static Future<CompanyGroup?> _addAndAssign(BuildContext context, CompanyRepository repo, CompanyGroup group) async {
    final name = CompanySheetField(label: CompanyFormsText.fullNameRequired(), hint: CompanyFormsText.fullNameHint());
    final email = CompanySheetField(label: CompanyFormsText.email(), hint: CompanyFormsText.emailHint(), keyboard: TextInputType.emailAddress);
    final phone = CompanySheetField(label: CompanyFormsText.phone(), hint: CompanyFormsText.phoneHint(), keyboard: TextInputType.phone, required: false);
    CompanyGroup? updated;
    final done = await CompanyFormSheet.show(
      context,
      CompanyFormSheet(
        title: CompanyFormsText.newSupervisor(),
        subtitle: CompanyFormsText.newSupervisorSubtitle(),
        fields: [name, email, phone],
        submitLabel: CompanyFormsText.add(),
        conflictMessage: CompanyFormsText.supervisorExists(),
        onSubmit: () async {
          final supervisor = await repo.addSupervisor(fullName: name.value, email: email.value, phone: phone.value);
          updated = await repo.assignSupervisor(group.id, supervisor.email);
        },
      ),
    );
    if (!context.mounted || !done) return null;
    showMessage(context, CompanyFormsText.assigned());
    return updated;
  }

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
