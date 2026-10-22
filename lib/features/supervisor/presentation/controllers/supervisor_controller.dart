import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/common_text.dart';
import '../../../../core/l10n/tx.dart';
import '../../../../core/widgets/busy_overlay.dart';
import '../../../auth/presentation/pages/auth_welcome_screen.dart';
import '../../../auth/presentation/pages/create_new_password_screen.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../chats/presentation/controllers/chats_controller.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/supervisor_group.dart';
import '../../domain/entities/supervisor_inbox.dart';
import '../../domain/repositories/supervisor_repository.dart';
import '../cubits/supervisor_content_cubits.dart';
import '../pages/announcement_details_screen.dart';
import '../pages/edit_supervisor_profile_screen.dart';
import '../pages/group_details_screen.dart';
import '../pages/group_members_screen.dart';
import '../pages/member_details_screen.dart';
import '../pages/supervisor_notifications_screen.dart';
import '../pages/supervisor_settings_screen.dart';
import '../pages/trip_program_screen.dart';
import '../supervisor_scope.dart';
import '../widgets/photo_viewer.dart';
import '../widgets/supervisor_route.dart';

// -------------------------------------------------------------
// كل التنقل بين شاشات المشرف (نفس فكرة FieldModeController)
// كل شاشة فرعية بتاخد نفس الـ Cubits المشتركة (SupervisorScope.capture) + بياناتها بالـ constructor
// الشاشات اللي ما إلها تصميم لسا (المحادثة، تفاصيل نشاط البرنامج، الشروط، مركز المساعدة) → "قريباً"
// -------------------------------------------------------------
class SupervisorController {
  static Future<T?> _push<T>(BuildContext context, Widget screen) {
    final scoped = SupervisorScope.capture(context);
    return Navigator.of(context).push<T>(SupervisorRoute(builder: (_) => scoped(screen)));
  }

  static void showMessage(BuildContext context, Tx text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text()), duration: const Duration(milliseconds: 1600)));
  }

  static void comingSoon(BuildContext context) => showMessage(context, CommonText.comingSoon);

  /// الجرس → الإشعارات (أحدث قائمة، وكلها بتصير مقروءة)
  static void openNotifications(BuildContext context) {
    context.read<SupervisorNotificationsCubit>().opened();
    _push(context, const SupervisorNotificationsScreen());
  }

  static void openGroup(BuildContext context, SupervisorGroup group) => _push(context, GroupDetailsScreen(group: group));

  static void openMembers(BuildContext context, SupervisorGroup group) => _push(context, GroupMembersScreen(group: group));

  static void openProgram(BuildContext context, SupervisorGroup group) => _push(context, TripProgramScreen(group: group));

  /// صفحة العضو — بنجيب بطاقته الكاملة (الملاحظات الصحية) من السيرفر لو عرفنا مجموعته
  static Future<void> openMember(BuildContext context, GroupMember member, {String? groupId}) async {
    final repository = context.read<SupervisorRepository>();
    final m = groupId == null ? member : await BusyOverlay.run(context, () => repository.getMember(groupId, member));
    if (m != null && context.mounted) _push(context, MemberDetailsScreen(member: m));
  }

  /// "تواصل" بصفحة المعتمر → محادثتنا الفردية (POST /chats/direct — السيرفر بيعملها أول مرة)
  static Future<void> messageMember(BuildContext context, GroupMember member) => ChatsController.openDirect(context, userId: member.id, name: member.name, photoUrl: member.photo);

  /// صف بقائمة الدردشات → المحادثة (مجموعة أو فردية)
  static Future<void> openChat(BuildContext context, ChatThread thread) async {
    await ChatsController.openRoom(context, id: thread.id, title: thread.name, isGroup: thread.isGroup, photoUrl: thread.photoUrl);
    if (context.mounted) context.read<SupervisorChatsCubit>().load();
  }

  static void openAnnouncement(BuildContext context, Announcement announcement) => _push(context, AnnouncementDetailsScreen(announcement: announcement));

  static void openSettings(BuildContext context) => _push(context, const SupervisorSettingsScreen());

  static void openEditProfile(BuildContext context) => _push(context, const EditSupervisorProfileScreen());

  /// تكبير صورة (عضو أو المشرف نفسه) — زي انستغرام
  static void viewPhoto(BuildContext context, {required String photo, required Object heroTag, String? title, bool avatar = true}) {
    SupPhotoViewer.open(context, photo: photo, heroTag: heroTag, title: title, avatar: avatar);
  }

  /// "تغيير كلمة المرور" → نفس مسار نسيت كلمة المرور (رمز على الإيميل ثم كلمة مرور جديدة)
  static void changePassword(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateNewPasswordScreen.change()));

  /// "تسجيل الخروج": حذف التوكن وبيانات المشرف المحفوظة والرجوع لشاشة الدخول/إنشاء الحساب
  static Future<void> logout(BuildContext context) async {
    await AuthController.endSession();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthWelcomeScreen()),
      (route) => false,
    );
  }
}
