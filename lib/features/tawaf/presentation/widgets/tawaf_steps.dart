import 'dart:ui';

import '../../../../core/theme/figma_text.dart';
import '../l10n/tawaf_steps_text.dart';
import 'tawaf_step_spec.dart';

// -------------------------------------------------------------
// خطوات الدخول للحرم لحد بداية الطواف بأرقام Figma (كلها من ملف Figma مباشرة)
// صناديق النصوص اللي بنص الكرت: "auto height" (top = أول سطر) أو "fixed" بالنص عمودياً (محسوب هون)
// -------------------------------------------------------------
abstract final class TawafSteps {
  static const _photos = 'assets/images/tawaf';

  /// الوصول إلى باب الملك فهد (203:1886) — العنوان والصورة حسب الباب اللي وصله
  static const gate = TawafStepSpec(
    subtitle: TawafStepsText.gateSubtitle,
    subtitleBox: TawafTextBox(154, 117, 223),
    photoRect: Rect.fromLTWH(16, 155, 362, 386),
    card: Rect.fromLTWH(17, 573, 361, 59),
    cardText: TawafStepsText.gateCard,
    cardBox: TawafTextBox(90, 592, 216),
    note: TawafNote(TawafStepsText.gateNote, TawafTextBox(135, 656, 124), size: 16, weight: FigmaWeight.semiBold),
    button: Rect.fromLTWH(13, 710, 361, 50),
    buttonLabel: TawafStepsText.gateButton,
  );

  /// داخل الحرم: اتبع الممر إلى المطاف (203:1912) → نافذة "تنبيه قبل المتابعة"
  static const inside = TawafStepSpec(
    title: TawafStepsText.insideTitle,
    subtitle: TawafStepsText.insideSubtitle,
    subtitleBox: TawafTextBox(97, 117, 279),
    photo: '$_photos/inside_haram.jpg',
    photoRect: Rect.fromLTWH(17, 155, 361, 386),
    card: Rect.fromLTWH(16, 573, 361, 59),
    cardText: TawafStepsText.insideCard,
    cardBox: TawafTextBox(57, 580, 280),
    note: TawafNote(TawafStepsText.insideNote, TawafTextBox(92, 656, 195), size: 16, weight: FigmaWeight.semiBold),
    button: Rect.fromLTWH(17, 710, 361, 50),
    buttonLabel: TawafStepsText.insideButton,
  );

  /// لحظة رؤية الكعبة (203:2012 — إطار 923 فبتتمرر 71): الدعاء 3 سطور بنص صندوق 81
  static const kaaba = TawafStepSpec(
    title: TawafStepsText.kaabaTitle,
    subtitle: TawafStepsText.kaabaSubtitle,
    subtitleBox: TawafTextBox(129, 117, 247),
    photo: '$_photos/kaaba_view.jpg',
    photoRect: Rect.fromLTWH(18, 155, 361, 386),
    card: Rect.fromLTWH(17, 576, 360, 59),
    cardText: TawafStepsText.kaabaCard,
    cardBox: TawafTextBox(49, 584, 297),
    note: TawafNote(TawafStepsText.kaabaDua, TawafTextBox(23, 666.5, 356), size: 16, weight: FigmaWeight.sfRegular),
    button: Rect.fromLTWH(18, 756, 361, 50),
    buttonLabel: TawafStepsText.kaabaButton,
    frameHeight: 923,
  );

  /// اقتربت من صحن المطاف (203:1983): نص الكرت سطرين بنص صندوق 20
  static const approach = TawafStepSpec(
    title: TawafStepsText.approachTitle,
    subtitle: TawafStepsText.approachSubtitle,
    subtitleBox: TawafTextBox(130, 117, 243),
    photo: '$_photos/mataf_approach.jpg',
    photoRect: Rect.fromLTWH(17, 155, 361, 386),
    card: Rect.fromLTWH(17, 576, 361, 59),
    cardText: TawafStepsText.approachCard,
    cardBox: TawafTextBox(31, 584, 333),
    note: TawafNote(TawafStepsText.approachNote, TawafTextBox(118, 659, 171), size: 16, weight: FigmaWeight.semiBold),
    button: Rect.fromLTWH(17, 713, 361, 50),
    buttonLabel: TawafStepsText.approachButton,
  );

  /// الاضطباع للرجال (203:2041)
  static const idtiba = TawafStepSpec(
    title: TawafStepsText.idtibaTitle,
    subtitle: TawafStepsText.idtibaSubtitle,
    subtitleBox: TawafTextBox(98, 117, 280),
    photo: '$_photos/idtiba.jpg',
    photoRect: Rect.fromLTWH(16, 155, 361, 386),
    card: Rect.fromLTWH(17, 576, 360, 59),
    cardText: TawafStepsText.idtibaCard,
    cardBox: TawafTextBox(39, 584, 316),
    note: TawafNote(TawafStepsText.idtibaNote, TawafTextBox(105, 659, 178), size: 14, weight: FigmaWeight.poppinsMedium),
    button: Rect.fromLTWH(17, 713, 361, 50),
    buttonLabel: TawafStepsText.idtibaButton,
  );

  /// نقطة بداية الطواف (203:2068)
  static const start = TawafStepSpec(
    title: TawafStepsText.startTitle,
    subtitle: TawafStepsText.startSubtitle,
    subtitleBox: TawafTextBox(122, 117, 250),
    photo: '$_photos/tawaf_start_point.jpg',
    photoRect: Rect.fromLTWH(17, 155, 361, 386),
    card: Rect.fromLTWH(17, 573, 360, 59),
    cardText: TawafStepsText.startCard,
    cardBox: TawafTextBox(33, 581, 328),
    note: TawafNote(TawafStepsText.startDua, TawafTextBox(26, 656, 342), size: 14, weight: FigmaWeight.poppinsMedium),
    button: Rect.fromLTWH(17, 732, 361, 50),
    buttonLabel: TawafStepsText.startButton,
  );

  /// ابدأ الطواف (203:2095) — هيدره أعلى بـ 8 (Frame 38 من y51)
  static const begin = TawafStepSpec(
    title: TawafStepsText.beginTitle,
    subtitle: TawafStepsText.beginSubtitle,
    subtitleBox: TawafTextBox(121, 117, 253),
    photo: '$_photos/tawaf_begin.jpg',
    photoRect: Rect.fromLTWH(16, 155, 361, 386),
    card: Rect.fromLTWH(16, 573, 360, 59),
    cardText: TawafStepsText.beginCard,
    cardBox: TawafTextBox(55, 581, 283),
    note: TawafNote(TawafStepsText.beginNote, TawafTextBox(18, 656, 356), size: 14, weight: FigmaWeight.semiBold),
    button: Rect.fromLTWH(16, 732, 361, 50),
    buttonLabel: TawafStepsText.beginButton,
    highHeader: true,
  );
}
