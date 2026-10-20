import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/tx.dart';
import '../../../../core/utils/app_launcher.dart';
import '../../../assistant/presentation/controllers/assistant_controller.dart';
import '../../../chats/presentation/controllers/chats_controller.dart';
import '../../../chats/presentation/cubits/conversation_cubit.dart';
import '../../../family/presentation/controllers/family_controller.dart';
import '../../../field_mode/presentation/controllers/field_mode_controller.dart';
import '../../data/repositories/lost_child_repository_impl.dart';
import '../../data/repositories/supervisor_repository_impl.dart';
import '../../domain/entities/supervisor_contact.dart';
import '../../domain/repositories/lost_child_repository.dart';
import '../../domain/repositories/supervisor_repository.dart';
import '../cubits/lost_child_report_cubit.dart';
import '../cubits/supervisor_contact_cubit.dart';
import '../l10n/help_messages_text.dart';
import '../l10n/lost_child_text.dart';
import '../pages/help_center_screen.dart';
import '../pages/lost_child_report_screen.dart';
import '../pages/quick_contact_screen.dart';
import '../pages/share_report_screen.dart';
import '../pages/supervisor_chat_screen.dart';
import '../widgets/report_sent_dialog.dart';

// -------------------------------------------------------------
// التنقل بمركز المساعدة (بروتوتايب Figma + طلب صاحب المشروع):
// شريط التنقل "مركز المساعدة" (PilgrimTabsController) أو "انا ضائع" بوضع الميدان أو الإعدادات → كيف بنقدر نساعدك؟
//   ├─ تائه ؟ تواصل مع مشرفك → التواصل السريع مع المشرف
//   │     ├─ اتصال هاتفي → الاتصال برقم المشرف (من السيرفر)
//   │     └─ محادثة المشرف → المحادثة الفردية (رسائل فعلية عبر السيرفر — نفس محادثة المشرف بالدردشات)
//   ├─ رجّعني للفندق → رحلتك إلى الفندق (وضع الميدان 21:1232)
//   ├─ رؤية العائلة → دائرة العائلة (FamilyController: أفراد عائلتي 111:5255 — أو الإنشاء/الانضمام لو مش بدائرة)
//   ├─ الإبلاغ عن طفل مفقود → النموذج → إرسال البلاغ للمشرف → هل ترغب بمشاركة البلاغ؟
//   │     ├─ نعم , مشاركة البلاغ → (إرسال للسيرفر) → تم إرسال البلاغ بنجاح! → تأكيد → الرئيسية
//   │     └─ لا , شكرا → البلاغ بيلغى ← مركز المساعدة
//   └─ اسأل عن التطبيق والمناسك → المساعد الذكي
// -------------------------------------------------------------
class HelpCenterController {
  static const routeName = '/help-center';

  // مصادر البيانات (السيرفر) — الاختبارات بتبدّلها
  static SupervisorRepository Function() supervisorRepository = SupervisorRepositoryImpl.new;
  static LostChildRepository Function() lostChildRepository = LostChildRepositoryImpl.new;

  static Future<void> _push(BuildContext context, Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  static void showMessage(BuildContext context, Tx text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text()), duration: const Duration(milliseconds: 1800)));
  }

  /// مركز المساعدة فوق الشاشة الحالية (من "انا ضائع" بوضع الميدان أو من الإعدادات) — بدون حركة انتقال
  /// (من شريط التنقل: PilgrimTabsController بيبدّل التبويب)
  static Future<void> open(BuildContext context) => Navigator.push(
    context,
    PageRouteBuilder(
      settings: const RouteSettings(name: routeName),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, _, _) => const HelpCenterScreen(),
    ),
  );

  static void toHome(BuildContext context) => Navigator.popUntil(context, (route) => route.isFirst);

  static void toQuickContact(BuildContext context) => _push(context, BlocProvider(create: (_) => SupervisorContactCubit(supervisorRepository())..load(), child: const QuickContactScreen()));

  static void toHotel(BuildContext context) => FieldModeController.startHotelTrip(context);

  static void toFamily(BuildContext context) => FamilyController.openFamily(context);

  static void toAssistant(BuildContext context) => AssistantController.open(context);

  static void toLostChild(BuildContext context) => _push(context, BlocProvider(create: (_) => LostChildReportCubit(lostChildRepository()), child: const LostChildReportScreen()));

  // ---------------- التواصل السريع ----------------

  /// المشرف لو جاهز — وإلا رسالة بالسبب (لسا بيحمّل / مش مربوط / خطأ السيرفر)
  static SupervisorContact? _supervisor(BuildContext context, SupervisorContactState state) {
    final contact = state.contact;
    if (contact != null) return contact;
    showMessage(context, switch (state.status) {
      SupervisorStatus.loading => HelpMessagesText.loadingSupervisor,
      SupervisorStatus.notLinked => HelpMessagesText.notLinked,
      _ => HelpMessagesText.forError(state.error ?? Object()),
    });
    return null;
  }

  static Future<void> call(BuildContext context, SupervisorContactState state) async {
    final contact = _supervisor(context, state);
    if (contact == null) return;
    if (!contact.hasPhone) {
      showMessage(context, HelpMessagesText.noPhone);
      return;
    }
    final opened = await AppLauncher.call(contact.phone!);
    if (!opened && context.mounted) showMessage(context, HelpMessagesText.callFailed);
  }

  static void toChat(BuildContext context, SupervisorContactState state) {
    final contact = _supervisor(context, state);
    if (contact == null) return;
    final conversationId = contact.conversationId;
    if (conversationId == null) {
      showMessage(context, HelpMessagesText.chatUnavailable);
      return;
    }
    _push(
      context,
      BlocProvider(
        create: (_) => ConversationCubit(ChatsController.chatRepository(), conversationId)..start(),
        child: SupervisorChatScreen(supervisor: contact),
      ),
    );
  }

  // ---------------- بلاغ الطفل المفقود ----------------

  /// "إرسال البلاغ للمشرف": لازم العمر والوصف والموقع (الصورة اختيارية) → هل ترغب بمشاركة البلاغ؟
  static void reviewReport(BuildContext context) {
    final cubit = context.read<LostChildReportCubit>();
    final report = cubit.state.report;
    final missing = report.age == null
        ? LostChildText.chooseAge
        : report.description.trim().isEmpty
        ? LostChildText.enterDescription
        : report.location == null
        ? LostChildText.attachLocation
        : null;
    if (missing != null) {
      showMessage(context, missing);
      return;
    }
    FocusScope.of(context).unfocus();
    _push(context, BlocProvider.value(value: cubit, child: const ShareReportScreen()));
  }

  /// "نعم , مشاركة البلاغ": البلاغ بيروح للسيرفر (للمشرف والقريبين) → تم إرسال البلاغ بنجاح!
  static Future<void> shareReport(BuildContext context) async {
    final cubit = context.read<LostChildReportCubit>();
    try {
      await cubit.submit(shareWithNearby: true);
    } catch (error) {
      if (context.mounted) showMessage(context, HelpMessagesText.forError(error));
      return;
    }
    if (!context.mounted) return;
    await showReportSent(context, onConfirm: () => toHome(context));
  }

  /// "لا , شكرا": البلاغ بيلغى وبيرجع لمركز المساعدة
  static void cancelReport(BuildContext context) {
    if (context.read<LostChildReportCubit>().state.submitting) return;
    Navigator.popUntil(context, (route) => route.settings.name == routeName || route.isFirst);
  }
}
