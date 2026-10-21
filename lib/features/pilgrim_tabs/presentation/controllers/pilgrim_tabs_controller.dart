import 'package:flutter/material.dart';

import '../../../../core/l10n/api_error_text.dart';
import '../../../../core/l10n/common_text.dart';
import '../../../chats/presentation/controllers/chats_controller.dart';
import '../../../family/presentation/controllers/family_controller.dart';
import '../../../family/presentation/widgets/track_choice_dialog.dart';
import '../../../group/data/models/company_services.dart';
import '../../../group/presentation/controllers/group_controller.dart';
import '../../../help_center/presentation/controllers/help_center_controller.dart';
import '../../../help_center/presentation/pages/help_center_screen.dart';

enum PilgrimTab { home, chats, people, map, help }

// -------------------------------------------------------------
// تبويبات المعتمر بشريط التنقل:
// الرئيسية → الرجوع للرئيسية — الدردشات / مركز المساعدة → التبويب بدل اللي مفتوح (بدون حركة انتقال)
// الأفراد → نافذة "مع من تريد التتبع؟" (بتنزل من فوق): العائلة (FamilyController) أو المجموعة (GroupController)
// — حتى وهو مفتوح، فبتقدر تبدّل بينهم — والرئيسية بتضل تحتهم (الرجوع من الجهاز بيرجعك لها)
// الخريطة لسا مش مبنية ("قريباً")
// -------------------------------------------------------------
class PilgrimTabsController {
  static const chatsRoute = '/tab/chats';

  static void open(BuildContext context, PilgrimTab tab) {
    switch (tab) {
      case PilgrimTab.home:
        Navigator.popUntil(context, (route) => route.isFirst);
      case PilgrimTab.chats:
        if (!CompanyServices.current.chatWithGuides) return _disabled(context);
        show(context, chatsRoute, ChatsController.listPage());
      case PilgrimTab.help:
        show(context, HelpCenterController.routeName, const HelpCenterScreen());
      case PilgrimTab.people:
        showTrackChoice(
          context,
          onFamily: (dialog) => FamilyController.openFromChoice(context, dialog),
          onGroup: (dialog) async {
            // تتبع المجموعة (GPS) مقفل لشركته
            if (CompanyServices.current.gpsTracking) return GroupController.openFromChoice(context, dialog);
            Navigator.pop(dialog);
            _disabled(context);
          },
        );
      case PilgrimTab.map:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(CommonText.comingSoon()), duration: const Duration(milliseconds: 900)));
    }
  }

  /// الخدمة مقفلة لشركة المعتمر
  static void _disabled(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(ApiErrorText.serviceDisabled())));
  }

  /// صفحة التبويب [name] بدل اللي مفتوح فوق الرئيسية — بدون حركة انتقال
  static void show(BuildContext context, String name, Widget page) {
    // نفس التبويب المفتوح → ولا شي
    if (ModalRoute.of(context)?.settings.name == name) return;
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        settings: RouteSettings(name: name),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, _, _) => page,
      ),
      (route) => route.isFirst,
    );
  }
}
