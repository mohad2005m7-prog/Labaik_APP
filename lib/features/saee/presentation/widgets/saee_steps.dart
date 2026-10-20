import 'dart:ui';

import '../../../../core/theme/figma_text.dart';
import '../../../tawaf/presentation/widgets/tawaf_step_spec.dart';
import '../l10n/saee_steps_text.dart';

// -------------------------------------------------------------
// خطوات السعي بأرقام Figma — نفس TawafStepSpec (كلها layout موحّد)
// الصور: idtiba + prayer تستخدمان صور الطواف (مشابهة الموضوع)
// الصور الناقصة: [GAP] — يجب إضافتها لـ assets/images/saee/
// -------------------------------------------------------------
abstract final class SaeeSteps {
  static const _photos = 'assets/images/saee';
  static const _tawafPhotos = 'assets/images/tawaf';

  /// ١. الاضطباع بعد الطواف
  static const idtiba = TawafStepSpec(
    title: SaeeStepsText.idtibaTitle,
    subtitle: SaeeStepsText.idtibaSubtitle,
    subtitleBox: TawafTextBox(98, 117, 280),
    photo: '$_tawafPhotos/idtiba.jpg',
    photoRect: Rect.fromLTWH(16, 155, 361, 386),
    card: Rect.fromLTWH(17, 576, 360, 59),
    cardText: SaeeStepsText.idtibaCard,
    cardBox: TawafTextBox(39, 584, 316),
    note: TawafNote(SaeeStepsText.idtibaNote, TawafTextBox(105, 659, 178), size: 14, weight: FigmaWeight.poppinsMedium),
    button: Rect.fromLTWH(17, 713, 361, 50),
    buttonLabel: SaeeStepsText.idtibaButton,
  );

  /// ٢. صلاة ركعتي الطواف — [GAP: صورة مناسبة للصلاة عند المقام]
  static const prayer = TawafStepSpec(
    title: SaeeStepsText.prayerTitle,
    subtitle: SaeeStepsText.prayerSubtitle,
    subtitleBox: TawafTextBox(130, 117, 243),
    photo: '$_tawafPhotos/inside_haram.jpg',
    photoRect: Rect.fromLTWH(17, 155, 361, 386),
    card: Rect.fromLTWH(17, 573, 361, 59),
    cardText: SaeeStepsText.prayerCard,
    cardBox: TawafTextBox(31, 581, 333),
    note: TawafNote(SaeeStepsText.prayerNote, TawafTextBox(100, 659, 184), size: 14, weight: FigmaWeight.poppinsMedium),
    button: Rect.fromLTWH(17, 710, 361, 50),
    buttonLabel: SaeeStepsText.prayerButton,
  );

  /// ٣. شرب ماء زمزم — [GAP: '$_photos/zamzam.jpg']
  static const zamzam = TawafStepSpec(
    title: SaeeStepsText.zamzamTitle,
    subtitle: SaeeStepsText.zamzamSubtitle,
    subtitleBox: TawafTextBox(118, 117, 257),
    photo: '$_photos/zamzam.jpg',
    photoRect: Rect.fromLTWH(16, 155, 361, 386),
    card: Rect.fromLTWH(17, 573, 361, 59),
    cardText: SaeeStepsText.zamzamCard,
    cardBox: TawafTextBox(44, 581, 317),
    note: TawafNote(SaeeStepsText.zamzamNote, TawafTextBox(90, 659, 207), size: 14, weight: FigmaWeight.poppinsMedium),
    button: Rect.fromLTWH(17, 710, 361, 50),
    buttonLabel: SaeeStepsText.zamzamButton,
  );

  /// ٤. اتجه نحو المسعى — [GAP: '$_photos/masaa_direction.jpg']
  static const masaa = TawafStepSpec(
    title: SaeeStepsText.masaaTitle,
    subtitle: SaeeStepsText.masaaSubtitle,
    subtitleBox: TawafTextBox(97, 117, 280),
    photo: '$_photos/masaa_direction.jpg',
    photoRect: Rect.fromLTWH(16, 155, 361, 386),
    card: Rect.fromLTWH(17, 573, 361, 59),
    cardText: SaeeStepsText.masaaCard,
    cardBox: TawafTextBox(35, 581, 333),
    note: TawafNote(SaeeStepsText.masaaNote, TawafTextBox(90, 659, 207), size: 14, weight: FigmaWeight.poppinsMedium),
    button: Rect.fromLTWH(17, 710, 361, 50),
    buttonLabel: SaeeStepsText.masaaButton,
  );

  /// ٥. ابدأ السعي من الصفا (high header) — [GAP: '$_photos/safa_start.jpg']
  static const ready = TawafStepSpec(
    title: SaeeStepsText.readyTitle,
    subtitle: SaeeStepsText.readySubtitle,
    subtitleBox: TawafTextBox(121, 117, 253),
    photo: '$_photos/safa_start.jpg',
    photoRect: Rect.fromLTWH(16, 155, 361, 386),
    card: Rect.fromLTWH(17, 573, 360, 59),
    cardText: SaeeStepsText.readyCard,
    cardBox: TawafTextBox(55, 581, 283),
    note: TawafNote(SaeeStepsText.readyNote, TawafTextBox(18, 659, 357), size: 13, weight: FigmaWeight.poppinsMedium),
    button: Rect.fromLTWH(17, 732, 361, 50),
    buttonLabel: SaeeStepsText.readyButton,
    highHeader: true,
  );

  /// ٦. اتجه إلى صالونات الحلاقة — [GAP: '$_photos/barbershop.jpg']
  static const barbershop = TawafStepSpec(
    title: SaeeStepsText.barbershopTitle,
    subtitle: SaeeStepsText.barbershopSubtitle,
    subtitleBox: TawafTextBox(37, 117, 355),
    photo: '$_photos/barbershop.jpg',
    photoRect: Rect.fromLTWH(16, 155, 361, 386),
    card: Rect.fromLTWH(17, 573, 361, 59),
    cardText: SaeeStepsText.barbershopCard,
    cardBox: TawafTextBox(47, 581, 303),
    note: TawafNote(SaeeStepsText.barbershopNote, TawafTextBox(50, 659, 295), size: 14, weight: FigmaWeight.poppinsMedium),
    button: Rect.fromLTWH(17, 710, 361, 50),
    buttonLabel: SaeeStepsText.barbershopButton,
  );
}
