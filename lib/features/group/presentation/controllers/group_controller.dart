import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/tx.dart';
import '../../../../core/widgets/top_popup.dart';
import '../../../chats/data/repositories/local_chat_repository.dart';
import '../../../chats/presentation/controllers/chats_controller.dart';
import '../../../family/domain/entities/family_member.dart';
import '../../../family/presentation/l10n/family_messages_text.dart';
import '../../../family/presentation/pages/family_map_screen.dart' show FamilyMapFocus;
import '../../../family/presentation/widgets/member_menu.dart';
import '../../../help_center/presentation/controllers/help_center_controller.dart';
import '../../../pilgrim_tabs/presentation/controllers/pilgrim_tabs_controller.dart';
import '../../data/repositories/group_repository_impl.dart';
import '../../domain/entities/group_info.dart';
import '../../domain/repositories/group_repository.dart';
import '../cubits/group_members_cubit.dart';
import '../l10n/group_arrival_text.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/sources/group_api.dart';
import '../../domain/entities/group_preview.dart';
import '../l10n/group_join_text.dart';
import '../pages/group_arrival_screen.dart';
import '../pages/group_confirm_screen.dart';
import '../pages/group_join_screen.dart';
import '../pages/group_joined_screen.dart';
import '../pages/group_destination_screen.dart';
import '../pages/group_map_screen.dart';
import '../pages/group_members_screen.dart';
import '../pages/group_route_screen.dart';
import '../widgets/group_confirmed_popup.dart';
import 'group_location_reporter.dart';

// -------------------------------------------------------------
// التنقل بالمجموعة (بروتوتايب Figma — بيانات السيرفر: مجموعتي وأعضاؤها ومواقعهم):
// تبويب "الأفراد" → مع من تريد التتبع؟ → المجموعة → أفراد مجموعتي (111:5507) — تبويب "الأفراد"
//   ├─ ⋮ أو دبوس فرد على الخريطة → بدء محادثة / عرض الموقع (111:6394)
//   ├─ رؤية المجموعة على الخريطة → أفراد مجموعتي على الخريطة (111:6611)
//   └─ عرض نقطة التجمع (من القائمة أو الخريطة) → وجهتك القادمة (111:6735)
//          └─ ابدأ الطريق → الطريق إلى نقطة التجمع (111:6809) — ملاحة حية من موقعك الفعلي
//                 ├─ وصلت إلى نقطة التجمع → أكّد وصولك (165:5962)
//                 │      ├─ نعم، وصلت → تم التأكيد (163:5858 — بتنزل من فوق وبتثبت بالنص) → العودة إلى مجموعتي
//                 │      └─ العودة إلى الملاحة → الطريق
//                 └─ انا ضائع → مركز المساعدة
// -------------------------------------------------------------
class GroupController {
  static const membersRoute = '/tab/people/group';

  // مصدر البيانات: السيرفر — الاختبارات بتبدّله
  static GroupRepository Function() repository = GroupRepositoryImpl.new;

  static void showMessage(BuildContext context, Tx text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text()), duration: const Duration(milliseconds: 2200)));
  }

  static Future<void> _push(BuildContext context, Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  /// كل شاشات المجموعة بتشارك نفس الأفراد ونفس التحديث
  static Widget _shared(BuildContext context, Widget page) => BlocProvider.value(value: context.read<GroupMembersCubit>(), child: page);

  // ---------------- الدخول ----------------

  /// "المجموعة" بنافذة "مع من تريد التتبع؟"
  static Future<void> openFromChoice(BuildContext context, BuildContext dialog) async {
    Navigator.pop(dialog);
    // الجواب محفوظ من الرئيسية — الانتقال فوري، وبنحدّثه بالخلفية
    final known = _inGroup;
    if (known != null) unawaited(_refreshMembership());
    final inGroup = known ?? await _refreshMembership();
    if (!context.mounted) return;
    if (inGroup) {
      showMembers(context);
    } else {
      _push(context, const GroupJoinScreen());
    }
  }

  // ---------------- الانضمام (واجهات فقط لحد ما يوصل endpoint الانضمام) ----------------

  static bool _busy = false;

  /// "الانضمام إلى المجموعة" بشاشة الرمز / مسح QR → تأكد من مجموعتك (GET /groups/{code})
  static Future<void> findGroup(BuildContext context, String code) async {
    final clean = code.trim().toUpperCase();
    if (clean.isEmpty || _busy) return;
    FocusScope.of(context).unfocus();
    _busy = true;
    try {
      final group = await GroupApi.server().preview(clean);
      if (context.mounted) unawaited(_push(context, GroupConfirmScreen(group: group)));
    } catch (error) {
      if (context.mounted) showMessage(context, _joinError(error));
    } finally {
      _busy = false;
    }
  }

  /// "الانضمام إلى المجموعة" بشاشة التأكيد → تم الانضمام بنجاح ! (POST /groups/{code}/join)
  static Future<void> joinGroup(BuildContext context, GroupPreview group) async {
    if (_busy) return;
    _busy = true;
    try {
      try {
        await GroupApi.server().join(group.code);
      } on ApiException catch (e) {
        // عضو أصلاً = نفس النتيجة
        if (e.statusCode != 409) rethrow;
      }
      _inGroup = true;
      if (context.mounted) unawaited(_push(context, GroupJoinedScreen(group: group)));
    } catch (error) {
      if (context.mounted) showMessage(context, _joinError(error));
    } finally {
      _busy = false;
    }
  }

  static Tx _joinError(Object error) => switch (error) {
        ApiException(statusCode: 404) => GroupJoinText.wrongCode,
        ApiException(statusCode: 403) => GroupJoinText.joinClosed,
        _ => GroupJoinText.connectionError,
      };

  /// تبويب "الأفراد" بأفراد المجموعة (بدل اللي مفتوح — والرئيسية بتضل تحته)
  static void showMembers(BuildContext context) {
    unawaited(resumeLocationSharing());
    PilgrimTabsController.show(context, membersRoute, BlocProvider(create: (_) => GroupMembersCubit(repository())..start(), child: const GroupMembersScreen()));
  }

  // ---------------- مشاركة موقعي ----------------

  /// تلقائي: لو بمجموعة والموقع مسموح، موقعي بيوصل لأعضاء مجموعتي (من الرئيسية وتبويب المجموعة)
  static Future<void> resumeLocationSharing() {
    unawaited(_refreshMembership());
    return GroupLocationReporter.instance.start();
  }

  static bool? _inGroup;

  static Future<bool> _refreshMembership() async {
    try {
      _inGroup = await repository().group() != null;
    } catch (_) {
      _inGroup ??= true;
    }
    return _inGroup!;
  }

  /// تسجيل الخروج
  static Future<void> stopLocationSharing() {
    _inGroup = null;
    return GroupLocationReporter.instance.stop();
  }

  // ---------------- الأفراد ----------------

  /// ⋮ بالكرت أو الضغط على دبوس فرد بالخريطة: بدء محادثة / عرض الموقع
  static Future<void> memberMenu(BuildContext context, FamilyMember member, Rect anchor, {ValueChanged<FamilyMember>? onShowLocation}) async {
    FocusScope.of(context).unfocus();
    final action = await showMemberMenu(context, anchor: anchor, actions: const [MemberAction.chat, MemberAction.location], placement: MenuPlacement.group);
    if (action == null || !context.mounted) return;
    switch (action) {
      case MemberAction.chat:
        await startChat(context, member);
      case MemberAction.location:
        if (member.location == null || !member.sharesLocation) {
          showMessage(context, FamilyMessagesText.noLocation);
        } else if (onShowLocation != null) {
          onShowLocation(member);
        } else {
          await openMap(context, focus: FamilyMapFocus.member(member.userId));
        }
      default:
        break;
    }
  }

  static Future<void> startChat(BuildContext context, FamilyMember member) => ChatsController.openDirect(
        context,
        userId: member.userId,
        name: member.name,
        photoUrl: member.photoUrl,
        // المحادثات الفردية مؤجلة بالسيرفر — مؤقتاً على الجهاز
        repository: LocalChatRepository(),
      );

  /// "رؤية المجموعة على الخريطة"
  static Future<void> openMap(BuildContext context, {FamilyMapFocus? focus}) => _push(context, _shared(context, GroupMapScreen(focus: focus)));

  // ---------------- نقطة التجمع ----------------

  /// "عرض نقطة التجمع" → وجهتك القادمة (أو رسالة لو المشرف لسا ما حددها)
  static void openDestination(BuildContext context) {
    final point = context.read<GroupMembersCubit>().state.group?.meetingPoint;
    if (point == null) {
      showMessage(context, FamilyMessagesText.noMeetingPoint);
      return;
    }
    _push(context, _shared(context, GroupDestinationScreen(point: point)));
  }

  /// "ابدأ الطريق"
  static void startRoute(BuildContext context, GroupMeetingPoint point) => _push(context, _shared(context, GroupRouteScreen(point: point)));

  /// "وصلت إلى نقطة التجمع" → أكّد وصولك
  static void arrived(BuildContext context) => _push(context, _shared(context, const GroupArrivalScreen()));

  /// "انا ضائع" → مركز المساعدة (نفس وضع الميدان)
  static void lost(BuildContext context) => HelpCenterController.open(context);

  /// "نعم، وصلت": الوصول بيوصل للمشرف → تم التأكيد (بتنزل من فوق) → العودة إلى مجموعتي
  static Future<void> confirmArrival(BuildContext context) async {
    try {
      await repository().confirmArrival();
    } catch (error) {
      if (context.mounted) showMessage(context, FamilyMessagesText.forError(error));
      return;
    }
    if (!context.mounted) return;
    // النافذة بتضل لحد ما يضغط "العودة إلى مجموعتي" — ما بنستناها هون (زر "نعم، وصلت" بيرجع لحالته)
    unawaited(showTopPopup<void>(
      context,
      label: GroupArrivalText.confirmed(),
      dismissible: false,
      builder: (popup) => GroupConfirmedPopup(
        onBack: () {
          Navigator.pop(popup);
          backToGroup(context);
        },
      ),
    ));
  }

  /// "العودة إلى الملاحة"
  static void backToNavigation(BuildContext context) => Navigator.pop(context);

  /// "العودة إلى مجموعتي": أفراد مجموعتي (تبويب الأفراد)
  static void backToGroup(BuildContext context) {
    Navigator.popUntil(context, (route) => route.settings.name == membersRoute || route.isFirst);
  }
}
