import 'package:flutter/material.dart';

import '../../../../core/l10n/common_text.dart';
import '../../../../core/l10n/tx.dart';
import '../../data/models/field_destination.dart';
import '../../data/models/field_mode_data.dart';
import '../../data/models/ihram_status.dart';
import '../l10n/field_mode_text.dart';
import '../pages/destination_choice_screen.dart';
import '../pages/haram_arrival_screen.dart';
import '../pages/ihram_prep_step_screen.dart';
import '../pages/ihram_status_screen.dart';
import '../pages/next_destination_screen.dart';
import '../pages/ready_next_step_screen.dart';
import '../pages/route_screen.dart';
import 'route_navigation_controller.dart';

// -------------------------------------------------------------
// FieldModeController — كل الربط بين شاشات وضع الميدان بمكان واحد:
//
// تهيئة وضع الميدان → ما حالة إحرامك؟ (لازم يختار)
//   ├─ لم أحرم بعد → حان وقت الاستعداد للإحرام → الطريق إلى ميقات ذو الحليفة
//   │    → الاستعداد للإحرام 1 → 2 → 3 → 4 → أنت جاهز للخطوة التالية
//   │    → وجهتك القادمة: رحلتك إلى مكة → الطريق إلى مكة المكرمة → أين تريد التوجه الآن؟
//   └─ أنا مُحرم → أنت جاهز للخطوة التالية → أين تريد التوجه الآن؟
//
// أين تريد التوجه الآن؟
//   ├─ الفندق → رحلتك إلى الفندق → الطريق إلى فندقك → رحلتك إلى المسجد الحرام
//   └─ المسجد الحرام → رحلتك إلى المسجد الحرام
// رحلتك إلى المسجد الحرام → الطريق إلى المسجد الحرام → وصلت إلى المسجد الحرام
// -------------------------------------------------------------
class FieldModeController {
  static final _data = FieldModeData.instance;

  static void _push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  static void _message(BuildContext context, Tx text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text())));
  }

  static void showMessage(BuildContext context, Tx text) => _message(context, text);

  // نتيجة زر "انا ضائع"
  static void showLostResult(BuildContext context, LostHelpResult result) => _message(context, switch (result) {
    LostHelpResult.alertSent => FieldModeText.lostAlertSent,
    LostHelpResult.rerouted => FieldModeText.lostRerouted,
    LostHelpResult.locating => FieldModeText.locating,
    LostHelpResult.needsLocation => FieldModeText.locationNeeded,
  });

  // شاشات لسا ما انصممت بـ Figma (طريقة ارتداء الإحرام، التفاصيل، انا ضائع، باب الملك فهد)
  static void comingSoon(BuildContext context) => _message(context, CommonText.comingSoon);

  // تهيئة وضع الميدان → ما حالة إحرامك؟ (بداية جديدة)
  static void start(BuildContext context) {
    _data.ihramStatus = null;
    _data.chosenDestination = null;
    _push(context, const IhramStatusScreen());
  }

  // ما حالة إحرامك؟ → حسب الاختيار (ما بيكمل بدون اختيار)
  static void continueFromIhramStatus(BuildContext context) {
    switch (_data.ihramStatus) {
      case null:
        _message(context, FieldModeText.chooseIhramStatus);
      case IhramStatus.notYet:
        _push(context, const NextDestinationScreen(destination: FieldDestination.miqat));
      case IhramStatus.muhrim:
        _push(context, const ReadyNextStepScreen());
    }
  }

  // وجهتك القادمة → ابدأ الطريق
  static void startRoute(BuildContext context, FieldDestination destination) {
    _push(context, RouteScreen(destination: destination));
  }

  // الطريق إلى ... → وصلت
  static void arrived(BuildContext context, FieldDestination destination) {
    switch (destination) {
      case FieldDestination.miqat:
        _push(context, const IhramPrepStepScreen(step: 1));
      case FieldDestination.mecca:
        _push(context, const DestinationChoiceScreen());
      case FieldDestination.hotel:
        _push(context, const NextDestinationScreen(destination: FieldDestination.haram));
      case FieldDestination.haram:
        _push(context, const HaramArrivalScreen());
    }
  }

  // الاستعداد للإحرام → تم (بالترتيب، وبعد الخطوة الأخيرة: أنت جاهز للخطوة التالية)
  static void completePrepStep(BuildContext context, int step) {
    if (step < IhramPrepStepScreen.stepsCount) {
      _push(context, IhramPrepStepScreen(step: step + 1));
    } else {
      _push(context, const ReadyNextStepScreen());
    }
  }

  // أنت جاهز للخطوة التالية → متابعة
  // المُحرم من الأول بيروح لاختيار الوجهة، واللي أحرم من الميقات بيكمل رحلته لمكة
  static void continueFromReady(BuildContext context) {
    if (_data.ihramStatus == IhramStatus.muhrim) {
      _push(context, const DestinationChoiceScreen());
    } else {
      _push(context, const NextDestinationScreen(destination: FieldDestination.mecca));
    }
  }

  // مركز المساعدة: "رجّعني للفندق" → رحلتك إلى الفندق (Figma 21:1232) → الطريق إلى فندقك
  static void startHotelTrip(BuildContext context) => chooseDestination(context, FieldDestination.hotel);

  // أين تريد التوجه الآن؟ → الفندق / المسجد الحرام
  static void chooseDestination(BuildContext context, FieldDestination destination) {
    _data.chosenDestination = destination;
    _push(context, NextDestinationScreen(destination: destination));
  }
}
