import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/l10n/tx.dart';
import '../../../../core/network/backend_mode.dart';
import '../../../../core/utils/location_service.dart';
import '../../../chats/data/repositories/local_chat_repository.dart';
import '../../../chats/presentation/controllers/chats_controller.dart';
import '../../../pilgrim_tabs/presentation/controllers/pilgrim_tabs_controller.dart';
import '../../data/repositories/family_demo_repository.dart';
import '../../data/repositories/family_repository_impl.dart';
import '../../domain/entities/family_circle.dart';
import '../../domain/entities/family_member.dart';
import '../../domain/repositories/family_repository.dart';
import '../cubits/family_members_cubit.dart';
import '../cubits/family_setup_cubit.dart';
import '../l10n/family_members_text.dart';
import '../l10n/family_messages_text.dart';
import '../l10n/family_setup_text.dart';
import '../pages/family_found_screen.dart';
import '../pages/family_map_screen.dart';
import '../pages/family_members_screen.dart';
import '../pages/family_setup_screen.dart';
import '../pages/family_share_location_screen.dart';
import 'family_location_reporter.dart';

// -------------------------------------------------------------
// التنقل بدائرة العائلة (بروتوتايب Figma — بيانات السيرفر، ومؤقتاً بيانات تجريبية على الجهاز: BackendMode):
// تبويب "الأفراد" → مع من تريد التتبع؟ (356:3148)
//   ├─ العائلة → (حسب حالتي بالسيرفر)
//   │     ├─ مش بدائرة / أنا لحالي فيها → أنشئ دائرة عائلتك (111:5131) ⇄ انضم إلى دائرة عائلتك (111:5165)
//   │     │      ├─ مشاركة الدعوة → مشاركة رمز الدائرة ورابطها (واتساب، رسائل...) — ولما ينضم أول فرد بتكمل لحالها
//   │     │      └─ QR أو الرمز + متابعة → تم العثور على دائرة عائلتك (111:5199) → انضمام إلى الدائرة
//   │     ├─ بدائرة ولسا ما قررت مشاركة موقعي → مشاركة موقعك مع عائلتك (111:5228)
//   │     └─ غير هيك → أفراد عائلتي (111:5255) — تبويب "الأفراد"
//   │            ├─ ⋮ → بدء محادثة / عرض الموقع / حذف من الدائرة (111:5373)
//   │            ├─ عرض قائمة أفراد العائلة على الخريطة → أفراد عائلتي على الخريطة (111:6522)
//   │            └─ عرض نقطة التجمع → الخريطة على نقطة التجمع (أو "لم تُحدَّد نقطة تجمع بعد")
//   └─ المجموعة → GroupController (أفراد مجموعتي)
// مركز المساعدة "رؤية العائلة" → نفس مسار "العائلة" بدون النافذة
// -------------------------------------------------------------
class FamilyController {
  static const membersRoute = '/tab/people/family';

  // مصدر البيانات: السيرفر — أو مؤقتاً بيانات تجريبية على الجهاز (BackendMode) — الاختبارات بتبدّله
  static FamilyRepository Function() repository = BackendMode.family ? FamilyRepositoryImpl.new : FamilyDemoRepository.new;

  static void showMessage(BuildContext context, Tx text, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text()), action: action, duration: const Duration(milliseconds: 2200)));
  }

  static Future<void> _push(BuildContext context, Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  // ---------------- الدخول ----------------

  /// "العائلة" بنافذة "مع من تريد التتبع؟" (تبويب "الأفراد" — PilgrimTabsController): الزر عليه دوّارة لحد ما نعرف وين نروح
  static Future<void> openFromChoice(BuildContext context, BuildContext dialog) async {
    final target = await _resolve(dialog);
    if (target == null || !dialog.mounted) return;
    Navigator.pop(dialog);
    if (context.mounted) _go(context, target);
  }

  static bool _opening = false;

  /// مركز المساعدة "رؤية العائلة" (Figma بيوصل لـ "لائحة أفراد عائلتي")
  static Future<void> openFamily(BuildContext context) async {
    if (_opening) return;
    _opening = true;
    try {
      final target = await _resolve(context);
      if (target != null && context.mounted) _go(context, target);
    } finally {
      _opening = false;
    }
  }

  /// وين لازم يروح: المحفوظ على الجهاز لو بيكفي، وإلا السيرفر (ولو فشل والمحفوظ موجود بنكمل فيه)
  static Future<FamilyCircle?> _resolveCircle(FamilyRepository repo) async {
    final cached = await repo.cachedCircle();
    if (cached != null && cached.hasOthers && cached.mySharesLocation != null) return cached;
    try {
      return await repo.myCircle();
    } catch (_) {
      if (cached != null) return cached;
      rethrow;
    }
  }

  static Future<_Target?> _resolve(BuildContext context) async {
    final repo = repository();
    try {
      final circle = await _resolveCircle(repo);
      if (circle == null || !circle.hasOthers) return _Target.setup(circle);
      if (circle.mySharesLocation == null) return _Target.share(circle);
      return const _Target.members();
    } catch (error) {
      if (context.mounted) showMessage(context, FamilyMessagesText.forError(error));
      return null;
    }
  }

  static void _go(BuildContext context, _Target target) {
    switch (target.kind) {
      case _Kind.setup:
        openSetup(context, circle: target.circle);
      case _Kind.share:
        _push(context, FamilyShareLocationScreen(circle: target.circle!));
      case _Kind.members:
        showMembers(context);
    }
  }

  // ---------------- الإنشاء والانضمام ----------------

  static Future<void> openSetup(BuildContext context, {FamilyCircle? circle}) => _push(
        context,
        BlocProvider(create: (_) => FamilySetupCubit(repository(), circle: circle)..start(), child: const FamilySetupScreen()),
      );

  /// "مشاركة الدعوة": رمز الدائرة ورابطها لأي تطبيق (واتساب، رسائل...)
  static Future<void> shareInvite(BuildContext context, FamilyCircle circle) async {
    final box = context.findRenderObject() as RenderBox?;
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: FamilySetupText.invite(circle.code, circle.inviteLink),
          sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      if (context.mounted) showMessage(context, FamilyMessagesText.shareFailed);
    }
  }

  /// الرمز المكتوب أو الممسوح → تم العثور على دائرة عائلتك
  static Future<void> findCircle(BuildContext context, String rawCode) async {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) {
      showMessage(context, FamilyMessagesText.enterCode);
      return;
    }
    final cubit = context.read<FamilySetupCubit>();
    if (cubit.state.lookingUp) return;
    FocusScope.of(context).unfocus();
    try {
      final found = await cubit.find(code);
      if (!context.mounted) return;
      if (found == null) {
        showMessage(context, FamilyMessagesText.notFound);
      } else if (found.id == cubit.state.circle?.id) {
        showMessage(context, FamilyMessagesText.ownCircle);
      } else {
        await _push(context, FamilyFoundScreen(circle: found));
      }
    } catch (error) {
      if (context.mounted) showMessage(context, FamilyMessagesText.forError(error));
    }
  }

  /// "انضمام إلى الدائرة" → مشاركة موقعك مع عائلتك (أو القائمة لو قررت قبل)
  static Future<void> join(BuildContext context, FamilyCircleSummary found) async {
    final FamilyCircle circle;
    try {
      circle = await repository().joinCircle(found.id);
    } catch (error) {
      if (context.mounted) showMessage(context, FamilyMessagesText.forError(error));
      return;
    }
    if (context.mounted) continueWith(context, circle);
  }

  /// بعد الانضمام (أو لما ينضم حدا لدائرتي وأنا على شاشة الإنشاء)
  static void continueWith(BuildContext context, FamilyCircle circle) {
    if (circle.mySharesLocation == null) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => FamilyShareLocationScreen(circle: circle)), (route) => route.isFirst);
    } else {
      showMembers(context);
    }
  }

  // ---------------- مشاركة الموقع ----------------

  /// "مشاركة موقعي": صلاحية الموقع → السيرفر → إرسال موقعي الفعلي → أفراد عائلتي
  static Future<void> shareMyLocation(BuildContext context) async {
    final access = await LocationService.requestAccess();
    if (!context.mounted) return;
    if (access != LocationAccess.granted) {
      showMessage(
        context,
        FamilyMessagesText.locationOff,
        action: access == LocationAccess.denied ? null : SnackBarAction(label: FamilyMessagesText.settings(), onPressed: () => LocationService.openSettings(access)),
      );
      return;
    }
    final repo = repository();
    try {
      await repo.setLocationSharing(true);
    } catch (error) {
      if (context.mounted) showMessage(context, FamilyMessagesText.forError(error));
      return;
    }
    await FamilyLocationReporter.instance.start(repo);
    if (context.mounted) showMembers(context);
  }

  /// "ليس الآن": ما بنشارك (بيقدر يشغّلها بعدين من كرته) → أفراد عائلتي
  static Future<void> notNow(BuildContext context) async {
    try {
      await repository().setLocationSharing(false);
    } catch (error) {
      if (context.mounted) showMessage(context, FamilyMessagesText.forError(error));
      return;
    }
    if (context.mounted) showMembers(context);
  }

  /// من قائمة كرتي: إيقاف/تشغيل مشاركة موقعي
  static Future<void> toggleSharing(BuildContext context, {required bool enable}) async {
    final members = context.read<FamilyMembersCubit>();
    if (enable) {
      final access = await LocationService.requestAccess();
      if (!context.mounted) return;
      if (access != LocationAccess.granted) {
        showMessage(context, FamilyMessagesText.locationOff, action: access == LocationAccess.denied ? null : SnackBarAction(label: FamilyMessagesText.settings(), onPressed: () => LocationService.openSettings(access)));
        return;
      }
    }
    final repo = repository();
    try {
      await repo.setLocationSharing(enable);
    } catch (error) {
      if (context.mounted) showMessage(context, FamilyMessagesText.forError(error));
      return;
    }
    if (enable) {
      await FamilyLocationReporter.instance.start(repo);
    } else {
      await FamilyLocationReporter.instance.stop();
    }
    if (!context.mounted) return;
    showMessage(context, enable ? FamilyMessagesText.sharingOn : FamilyMessagesText.sharingOff);
    members.refresh();
  }

  /// فتح التطبيق (الرئيسية): لو كنت موافق على المشاركة بيرجع يبعت موقعي
  static Future<void> resumeLocationSharing() async {
    final repo = repository();
    final circle = await repo.cachedCircle();
    if (circle?.mySharesLocation == true) await FamilyLocationReporter.instance.start(repo);
  }

  /// تسجيل الخروج
  static Future<void> stopLocationSharing() => FamilyLocationReporter.instance.stop();

  // ---------------- أفراد عائلتي ----------------

  /// تبويب "الأفراد" (بدل اللي مفتوح — والرئيسية بتضل تحته)
  static void showMembers(BuildContext context) {
    PilgrimTabsController.show(
      context,
      membersRoute,
      BlocProvider(create: (_) => FamilyMembersCubit(repository())..start(), child: const FamilyMembersScreen()),
    );
  }

  static Future<void> startChat(BuildContext context, FamilyMember member) =>
      ChatsController.openDirect(context, userId: member.userId, name: member.name, photoUrl: member.photoUrl, repository: BackendMode.family ? null : LocalChatRepository());

  /// الخريطة (نفس الأفراد ونفس التحديث) — [focus]: فرد أو نقطة التجمع
  static Future<void> openMap(BuildContext context, {FamilyMapFocus? focus}) {
    final cubit = context.read<FamilyMembersCubit>();
    return _push(context, BlocProvider.value(value: cubit, child: FamilyMapScreen(focus: focus)));
  }

  /// "عرض الموقع" من قائمة الكرت
  static void showMemberLocation(BuildContext context, FamilyMember member) {
    if (member.location == null || !member.sharesLocation) {
      showMessage(context, FamilyMessagesText.noLocation);
      return;
    }
    openMap(context, focus: FamilyMapFocus.member(member.userId));
  }

  /// "عرض نقطة التجمع"
  static void showMeetingPoint(BuildContext context) {
    if (context.read<FamilyMembersCubit>().state.circle?.meetingPoint == null) {
      showMessage(context, FamilyMessagesText.noMeetingPoint);
      return;
    }
    openMap(context, focus: const FamilyMapFocus.meetingPoint());
  }

  /// "حذف من الدائرة" (صاحب الدائرة بس) — بعد التأكيد
  static Future<void> removeMember(BuildContext context, FamilyMember member) async {
    final cubit = context.read<FamilyMembersCubit>();
    if (cubit.state.circle?.isOwner != true) {
      showMessage(context, FamilyMessagesText.onlyOwner);
      return;
    }
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        content: Text(FamilyMembersText.removeQuestion(member.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, false), child: Text(FamilyMembersText.cancel())),
          TextButton(onPressed: () => Navigator.pop(dialog, true), child: Text(FamilyMembersText.confirmRemove(), style: const TextStyle(color: Color(0xFFE74C3C)))),
        ],
      ),
    );
    if (sure != true || !context.mounted) return;
    try {
      await cubit.remove(member.userId);
      if (context.mounted) showMessage(context, FamilyMembersText.removed(member.name));
    } catch (error) {
      if (context.mounted) showMessage(context, FamilyMessagesText.forError(error));
    }
  }
}

enum _Kind { setup, share, members }

class _Target {
  final _Kind kind;
  final FamilyCircle? circle;

  const _Target.setup(this.circle) : kind = _Kind.setup;
  const _Target.share(FamilyCircle this.circle) : kind = _Kind.share;
  const _Target.members()
      : kind = _Kind.members,
        circle = null;
}
