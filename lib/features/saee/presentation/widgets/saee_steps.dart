import 'dart:ui';

import '../../../../core/theme/figma_text.dart';
import '../../../tawaf/presentation/widgets/tawaf_step_spec.dart';
import '../l10n/saee_steps_text.dart';

// -------------------------------------------------------------
// خطوات السعي بأرقام Figma — نفس TawafStepSpec (كلها layout موحّد)
// الأماكن من Figma: 256:5860 / 256:5887 / 256:5914 / 256:5941 / 256:5972 / 256:6393
// الصور من نفس الإطارات (assets/images/saee)
// -------------------------------------------------------------
abstract final class SaeeSteps {
  static const _photos = 'assets/images/saee';

  /// ١. الاضطباع بعد الطواف
  static const idtiba = TawafStepSpec(
    title: SaeeStepsText.idtibaTitle,
    subtitle: SaeeStepsText.idtibaSubtitle,
    subtitleBox: TawafTextBox(28, 117, 350),
    photo: '$_photos/idtiba_after_tawaf.jpg',
    photoRect: Rect.fromLTWH(17, 177, 361, 386),
    card: Rect.fromLTWH(17, 595, 360, 59),
    cardText: SaeeStepsText.idtibaCard,
    cardBox: TawafTextBox(39, 603, 316),
    note: TawafNote(SaeeStepsText.idtibaNote, TawafTextBox(86, 678, 217), size: 14, weight: FigmaWeight.poppinsMedium),
    button: Rect.fromLTWH(17, 732, 361, 50),
    buttonLabel: SaeeStepsText.idtibaButton,
  );

  /// ٢. صلاة ركعتي الطواف
  static const prayer = TawafStepSpec(
    title: SaeeStepsText.prayerTitle,
    subtitle: SaeeStepsText.prayerSubtitle,
    subtitleBox: TawafTextBox(28, 117, 344),
    photo: '$_photos/prayer_maqam.jpg',
    photoRect: Rect.fromLTWH(16, 155, 361, 386),
    card: Rect.fromLTWH(17, 573, 360, 59),
    cardText: SaeeStepsText.prayerCard,
    cardBox: TawafTextBox(52, 581, 290),
    note: TawafNote(SaeeStepsText.prayerNote, TawafTextBox(17, 656, 356), size: 14, weight: FigmaWeight.poppinsMedium),
    button: Rect.fromLTWH(17, 732, 361, 50),
    buttonLabel: SaeeStepsText.prayerButton,
  );

  /// ٣. شرب ماء زمزم
  static const zamzam = TawafStepSpec(
    title: SaeeStepsText.zamzamTitle,
    subtitle: SaeeStepsText.zamzamSubtitle,
    subtitleBox: TawafTextBox(22, 117, 350),
    photo: '$_photos/zamzam.jpg',
    photoRect: Rect.fromLTWH(16, 177, 361, 386),
    card: Rect.fromLTWH(17, 595, 360, 59),
    cardText: SaeeStepsText.zamzamCard,
    cardBox: TawafTextBox(17, 604, 359),
    note: TawafNote(SaeeStepsText.zamzamNote, TawafTextBox(31, 678, 327), size: 14, weight: FigmaWeight.poppinsMedium),
    button: Rect.fromLTWH(16, 732, 361, 50),
    buttonLabel: SaeeStepsText.zamzamButton,
  );

  /// ٤. اتجه نحو المسعى
  static const masaa = TawafStepSpec(
    title: SaeeStepsText.masaaTitle,
    subtitle: SaeeStepsText.masaaSubtitle,
    subtitleBox: TawafTextBox(22, 117, 350),
    photo: '$_photos/masaa_direction.jpg',
    photoRect: Rect.fromLTWH(16, 155, 361, 386),
    card: Rect.fromLTWH(17, 573, 360, 59),
    cardText: SaeeStepsText.masaaCard,
    cardBox: TawafTextBox(26, 581, 342),
    note: TawafNote(SaeeStepsText.masaaNote, TawafTextBox(115, 656, 158), size: 14, weight: FigmaWeight.poppinsMedium),
    button: Rect.fromLTWH(17, 710, 361, 50),
    buttonLabel: SaeeStepsText.masaaButton,
  );

  /// ٥. ابدأ السعي من الصفا (high header)
  static const ready = TawafStepSpec(
    title: SaeeStepsText.readyTitle,
    subtitle: SaeeStepsText.readySubtitle,
    subtitleBox: TawafTextBox(208, 117, 169),
    photo: '$_photos/safa_start.jpg',
    photoRect: Rect.fromLTWH(15, 155, 361, 386),
    card: Rect.fromLTWH(17, 573, 360, 59),
    cardText: SaeeStepsText.readyCard,
    cardBox: TawafTextBox(17, 580, 359),
    note: TawafNote(SaeeStepsText.readyNote, TawafTextBox(27, 656, 339), size: 14, weight: FigmaWeight.poppinsMedium),
    button: Rect.fromLTWH(17, 725, 361, 50),
    buttonLabel: SaeeStepsText.readyButton,
    highHeader: true,
  );

  /// ٦. اتجه إلى صالونات الحلاقة
  static const barbershop = TawafStepSpec(
    title: SaeeStepsText.barbershopTitle,
    subtitle: SaeeStepsText.barbershopSubtitle,
    subtitleBox: TawafTextBox(59, 117, 319),
    photo: '$_photos/barbershop.jpg',
    photoRect: Rect.fromLTWH(16, 155, 361, 386),
    card: Rect.fromLTWH(17, 573, 360, 59),
    cardText: SaeeStepsText.barbershopCard,
    cardBox: TawafTextBox(49, 581, 296),
    note: TawafNote(SaeeStepsText.barbershopNote, TawafTextBox(47, 656, 294), size: 14, weight: FigmaWeight.poppinsMedium),
    button: Rect.fromLTWH(17, 710, 361, 50),
    buttonLabel: SaeeStepsText.barbershopButton,
  );
}
