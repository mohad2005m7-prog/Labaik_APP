import 'dart:ui';

import '../l10n/learning_common_text.dart';
import '../l10n/learning_ihram_text.dart';
import '../l10n/learning_sai_text.dart';
import '../l10n/learning_tahallul_text.dart';
import '../l10n/learning_tawaf_text.dart';
import 'learning_popups.dart';
import 'learning_stage_spec.dart';

// -------------------------------------------------------------
// المراحل الأربعة بأرقام إطارات Figma ("تعلم احرام"): الصناديق المباشرة من ملف Figma،
// واللي جوّا المجموعات (الشرائح والأيقونات ونصوص الكروت) مقاسة من لقطات Figma المكبّرة
// -------------------------------------------------------------
abstract final class LearningStages {
  static const all = [ihram, tawaf, sai, tahallul];

  /// "تمت العمرة" بآخر مرحلة
  static const donePopup = LearningPopups.done;

  /// المرحلة الأولى: الإحرام (222:1956 — 393×1280)
  static const ihram = LearningStageSpec(
    frameHeight: 1280,
    title: LearningIhramText.title,
    subtitle: LearningLine(LearningIhramText.subtitle, left: 130, top: 111, width: 247),
    topChip: LearningChip(rect: Rect.fromLTWH(113, 158, 165, 29), label: LearningIhramText.topChip, textRight: 264, textTop: 160.25, icon: LearningIcon('ic_shower', Rect.fromLTWH(126, 161, 26, 27)), raised: true),
    note: LearningLine(LearningIhramText.topNote, left: 84, top: 197, width: 249),
    cards: [
      LearningCard(
        rect: Rect.fromLTWH(16, 241, 361, 73),
        chip: LearningChip(rect: Rect.fromLTWH(265, 248, 103, 30), label: LearningIhramText.miqat, textRight: 333, textTop: 251.75, icon: LearningIcon('ic_pin', Rect.fromLTWH(334, 250, 26, 28))),
        body: LearningIhramText.miqatBody,
        bodyLeft: 56,
        bodyRight: 368,
        bodyTop: 281,
      ),
      LearningCard(
        rect: Rect.fromLTWH(16, 330, 361, 177),
        chip: LearningChip(rect: Rect.fromLTWH(227, 337, 141, 30), label: LearningIhramText.clothes, textRight: 329, textTop: 340.75, icon: LearningIcon('ic_shirt', Rect.fromLTWH(334.5, 340, 26, 26))),
        body: LearningIhramText.clothesBody,
        bodyLeft: 27,
        bodyRight: 367,
        bodyTop: 381.5,
      ),
      LearningCard(
        rect: Rect.fromLTWH(16, 523, 361, 101),
        chip: LearningChip(rect: Rect.fromLTWH(230, 528, 141, 30), label: LearningIhramText.intention, textRight: 329, textTop: 532, icon: LearningIcon('ic_heart', Rect.fromLTWH(334.5, 531, 26, 25))),
        body: LearningIhramText.intentionBody,
        bodyLeft: 32,
        bodyRight: 368,
        bodyTop: 568,
      ),
      // صندوق النص 116 والسطور الأربعة بنصه (Figma: محاذاة عمودية بالنص)
      LearningCard(
        rect: Rect.fromLTWH(16, 640, 361, 148),
        chip: LearningChip(rect: Rect.fromLTWH(62, 651, 305, 30), label: LearningIhramText.condition, textRight: 330, textTop: 653, icon: LearningIcon('ic_shield', Rect.fromLTWH(334, 653, 26, 26))),
        body: LearningIhramText.conditionBody,
        bodyLeft: 35,
        bodyRight: 367,
        bodyTop: 688,
      ),
      LearningCard(
        rect: Rect.fromLTWH(16, 804, 361, 148),
        chip: LearningChip(rect: Rect.fromLTWH(225, 815, 142, 30), label: LearningIhramText.prohibitions, textRight: 330, textTop: 817, icon: LearningIcon('ic_shield', Rect.fromLTWH(334, 817, 26, 26))),
        body: LearningIhramText.prohibitionsBody,
        bodyLeft: 35,
        bodyRight: 367,
        bodyTop: 853,
      ),
    ],
    links: [
      LearningLink(rect: Rect.fromLTWH(20, 968, 165, 38), label: LearningIhramText.menRules, textTop: 973.25, textSize: 14, textWeight: 690, popup: LearningPopups.men),
      LearningLink(rect: Rect.fromLTWH(211, 968, 165, 38), label: LearningIhramText.womenRules, textTop: 973.25, textSize: 14, textWeight: 690, popup: LearningPopups.women),
    ],
    next: Rect.fromLTWH(17, 1038, 361, 50),
    nextLabel: LearningCommonText.next,
    home: Rect.fromLTWH(15, 1112, 361, 50),
  );

  /// المرحلة الثانية: الطواف (202:2918 — 393×1089)
  static const tawaf = LearningStageSpec(
    frameHeight: 1089,
    title: LearningTawafText.title,
    subtitle: LearningLine(LearningTawafText.subtitle, left: 151, top: 111, width: 228),
    topChip: LearningChip(rect: Rect.fromLTWH(133, 151, 165, 29), label: LearningTawafText.topChip, textRight: 254.5, textTop: 155, icon: LearningIcon('ic_rotate', Rect.fromLTWH(174.5, 153, 24, 25)), raised: true),
    note: LearningLine(LearningTawafText.topNote, left: 48, top: 185, width: 280),
    cards: [
      LearningCard(
        rect: Rect.fromLTWH(15, 225, 361, 102),
        chip: LearningChip(rect: Rect.fromLTWH(250, 234, 115.5, 29.5), label: LearningTawafText.direction, textRight: 329.5, textTop: 238.5, icon: LearningIcon('ic_compass', Rect.fromLTWH(337.5, 235, 26, 27))),
        body: LearningTawafText.directionBody,
        bodyRight: 364,
        bodyTop: 273.5,
      ),
      LearningCard(
        rect: Rect.fromLTWH(15, 348.5, 361, 105.5),
        chip: LearningChip(rect: Rect.fromLTWH(222.5, 360.5, 141, 30), label: LearningTawafText.purity, textRight: 322, textTop: 364, icon: LearningIcon('ic_lotus', Rect.fromLTWH(327.5, 360.5, 28, 28))),
        body: LearningTawafText.purityBody,
        bodyRight: 362,
        bodyTop: 400,
      ),
      LearningCard(
        rect: Rect.fromLTWH(15, 466, 361, 106),
        chip: LearningChip(rect: Rect.fromLTWH(196.5, 475, 167, 29.5), label: LearningTawafText.startLine, textRight: 319, textTop: 479, icon: LearningIcon('ic_flag', Rect.fromLTWH(327, 476.5, 27, 28))),
        body: LearningTawafText.startLineBody,
        bodyLeft: 18,
        bodyRight: 361,
        bodyTop: 519,
      ),
      LearningCard(
        rect: Rect.fromLTWH(16, 591, 359, 101),
        chip: LearningChip(rect: Rect.fromLTWH(182, 601.5, 181, 30), label: LearningTawafText.ramal, textRight: 329, textTop: 606.5, icon: LearningIcon('ic_muhrim', Rect.fromLTWH(333, 604, 21, 25.5))),
        body: LearningTawafText.ramalBody,
        bodyRight: 357,
        bodyTop: 642.5,
      ),
      LearningCard(
        rect: Rect.fromLTWH(15, 711, 361, 102),
        chip: LearningChip(rect: Rect.fromLTWH(222.5, 718, 141, 30), label: LearningTawafText.hijr, textRight: 332, textTop: 721.5, icon: LearningIcon('ic_rotate', Rect.fromLTWH(335, 720, 24, 25))),
        body: LearningTawafText.hijrBody,
        bodyRight: 363,
        bodyTop: 762.5,
      ),
    ],
    links: [LearningLink(rect: Rect.fromLTWH(40, 829, 316, 38), label: LearningTawafText.wuduQuestion, textTop: 836.5, textRight: 339, arrow: Rect.fromLTWH(49, 845.5, 9.5, 3.5), popup: LearningPopups.wudu)],
    next: Rect.fromLTWH(17, 899, 360, 50),
    nextLabel: LearningCommonText.next,
    home: Rect.fromLTWH(17, 973, 360, 50),
  );

  /// المرحلة الثالثة: السعي (243:3922 — 393×1070)
  static const sai = LearningStageSpec(
    frameHeight: 1070,
    title: LearningSaiText.title,
    subtitle: LearningLine(LearningSaiText.subtitle, left: 112, top: 113, width: 265),
    topChip: LearningChip(rect: Rect.fromLTWH(117, 153, 165, 30), label: LearningSaiText.topChip, textRight: 262.5, textTop: 157, icon: LearningIcon('ic_mountains', Rect.fromLTWH(130, 160, 73, 18)), raised: true),
    note: LearningLine(LearningSaiText.topNote, left: 131, top: 189, width: 135),
    cards: [
      LearningCard(
        rect: Rect.fromLTWH(14, 222, 361, 102),
        chip: LearningChip(rect: Rect.fromLTWH(195, 234, 168.5, 29.5), label: LearningSaiText.counting, textRight: 323.5, textTop: 238.5, icon: LearningIcon('ic_steps', Rect.fromLTWH(329, 237, 29, 26))),
        body: LearningSaiText.countingBody,
        bodyLeft: 19,
        bodyRight: 364,
        bodyTop: 268,
      ),
      LearningCard(
        rect: Rect.fromLTWH(15, 338, 361, 97),
        chip: LearningChip(rect: Rect.fromLTWH(217.5, 347.5, 146, 30), label: LearningSaiText.startLine, textRight: 327.5, textTop: 352, icon: LearningIcon('ic_flag', Rect.fromLTWH(329, 349.5, 27, 28))),
        body: LearningSaiText.startLineBody,
        bodyLeft: 14,
        bodyRight: 364,
        bodyTop: 382,
      ),
      LearningCard(
        rect: Rect.fromLTWH(16, 445, 361, 102),
        chip: LearningChip(rect: Rect.fromLTWH(216, 452.5, 147.5, 30), label: LearningSaiText.supplication, textRight: 322, textTop: 457.5, icon: LearningIcon('ic_hands', Rect.fromLTWH(331, 452, 30, 29))),
        body: LearningSaiText.supplicationBody,
        bodyRight: 364,
        bodyTop: 488.5,
      ),
      LearningCard(
        rect: Rect.fromLTWH(16, 572, 361, 102),
        chip: LearningChip(rect: Rect.fromLTWH(222.5, 582, 141, 34.5), label: LearningSaiText.harwala, textRight: 322, textTop: 589.5, icon: LearningIcon('ic_runner', Rect.fromLTWH(322, 581, 31, 33))),
        body: LearningSaiText.harwalaBody,
        bodyLeft: 18,
        bodyRight: 363.5,
        bodyTop: 627,
      ),
      LearningCard(
        rect: Rect.fromLTWH(16, 697, 361, 101),
        chip: LearningChip(rect: Rect.fromLTWH(178, 705.5, 185.5, 29), label: LearningSaiText.ramal, textRight: 322, textTop: 711, icon: LearningIcon('ic_heart', Rect.fromLTWH(327, 708.5, 26, 25))),
        body: LearningSaiText.ramalBody,
        bodyRight: 363.5,
        bodyTop: 747.5,
      ),
    ],
    links: [LearningLink(rect: Rect.fromLTWH(113, 814, 165, 38), label: LearningSaiText.rules, textTop: 821.5, popup: LearningPopups.sai)],
    next: Rect.fromLTWH(15, 884, 361, 50),
    nextLabel: LearningCommonText.next,
    home: Rect.fromLTWH(15, 958, 361, 50),
  );

  /// المرحلة الرابعة: التحلّل (249:4165 — 393×1001) — "تمت العمرة" ← مبروك إتمام العمرة
  static const tahallul = LearningStageSpec(
    frameHeight: 1001,
    title: LearningTahallulText.title,
    subtitle: LearningLine(LearningTahallulText.subtitle, left: 126, top: 113, width: 251),
    topChip: LearningChip(rect: Rect.fromLTWH(112, 149, 165, 30), label: LearningTahallulText.topChip, textRight: 262.5, textTop: 153, icon: LearningIcon('ic_scissors_comb', Rect.fromLTWH(136, 151.5, 29, 27)), raised: true),
    note: LearningLine(LearningTahallulText.topNote, left: 84, top: 191, width: 226),
    cards: [
      LearningCard(
        rect: Rect.fromLTWH(14, 225, 361, 102),
        chip: LearningChip(rect: Rect.fromLTWH(234, 230.5, 133, 30), label: LearningTahallulText.men, textRight: 330, textTop: 235.5, icon: LearningIcon('ic_man', Rect.fromLTWH(334.5, 232, 27.5, 27.5))),
        body: LearningTahallulText.menBody,
        bodyRight: 367,
        bodyTop: 267,
      ),
      LearningCard(
        rect: Rect.fromLTWH(14, 348, 361, 87),
        chip: LearningChip(rect: Rect.fromLTWH(234, 354.5, 133, 30), label: LearningTahallulText.women, textRight: 327, textTop: 360.5, icon: LearningIcon('ic_woman', Rect.fromLTWH(331.5, 356, 27.5, 27.5))),
        body: LearningTahallulText.womenBody,
        bodyRight: 367,
        bodyTop: 391.5,
      ),
      LearningCard(
        rect: Rect.fromLTWH(14, 457, 361, 102),
        chip: LearningChip(rect: Rect.fromLTWH(188, 475, 179, 29.5), label: LearningTahallulText.barbers, textRight: 333, textTop: 479.5, icon: LearningIcon('ic_barber', Rect.fromLTWH(336.5, 478, 23.5, 24))),
        body: LearningTahallulText.barbersBody,
        bodyLeft: 18,
        bodyRight: 357,
        bodyTop: 512.5,
      ),
    ],
    links: [],
    next: Rect.fromLTWH(16, 831, 361, 50),
    nextLabel: LearningCommonText.done,
  );
}
