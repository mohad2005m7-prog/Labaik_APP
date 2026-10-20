import 'dart:ui';

import '../l10n/learning_common_text.dart';
import '../l10n/learning_popup_text.dart';
import 'learning_popup_spec.dart';

// -------------------------------------------------------------
// النوافذ بأرقام Figma (الكرت 391 عرض — x من طرفه): أماكن السطور مقاسة من لقطات Figma
// -------------------------------------------------------------
abstract final class LearningPopups {
  /// المحظورات الخاصة بالرجال (248:9883 — 391×356)
  static const men = LearningPopupSpec(
    height: 356,
    title: LearningPopupText.menTitle,
    titleTop: 33,
    blocks: [
      LearningPopupBlock(LearningPopupText.menSewn, left: 15, top: 93.75, width: 340.5, weight: 500, bulletRight: 368.5),
      LearningPopupBlock(LearningPopupText.menHead, left: 15, top: 193.25, width: 340.5, weight: 500, bulletRight: 368.5),
    ],
    button: Rect.fromLTWH(100, 287, 183.13, 39),
    buttonLabel: LearningCommonText.ok,
  );

  /// المحظورات الخاصة بالنساء (248:9901 — 391×356): النقاط أقرب للنص من نافذة الرجال (متل Figma)
  static const women = LearningPopupSpec(
    height: 356,
    title: LearningPopupText.womenTitle,
    titleTop: 33,
    blocks: [
      LearningPopupBlock(LearningPopupText.womenFace, left: 12, top: 93.25, width: 321.5, weight: 500, bulletRight: 347.5),
      LearningPopupBlock(LearningPopupText.womenGloves, left: 12, top: 215.25, width: 321.5, weight: 500, bulletRight: 347.5),
    ],
    button: Rect.fromLTWH(100, 287, 183.13, 39),
    buttonLabel: LearningCommonText.ok,
  );

  /// ماذا لو انتقض وضوئي أو نسيت عدد الأشواط؟ (248:9858 — 391×305)
  static const wudu = LearningPopupSpec(
    height: 305,
    title: LearningPopupText.wuduTitle,
    titleTop: 44,
    blocks: [LearningPopupBlock(LearningPopupText.wuduBody, left: 8, top: 107.25, width: 375, center: true)],
    button: Rect.fromLTWH(104, 194, 183.13, 39),
    buttonLabel: LearningCommonText.ok,
  );

  /// شروط وأحكام السعي (249:4065 — 391×305)
  static const sai = LearningPopupSpec(
    height: 305,
    title: LearningPopupText.saiTitle,
    titleTop: 40,
    blocks: [LearningPopupBlock(LearningPopupText.saiBody, left: 8, top: 87, width: 368, center: true, weight: 500)],
    button: Rect.fromLTWH(100, 172, 183.13, 39),
    buttonLabel: LearningCommonText.ok,
  );

  /// مبروك إتمام العمرة (249:4729 — 391×305) → الرئيسية
  static const done = LearningPopupSpec(
    height: 305,
    title: LearningPopupText.doneTitle,
    titleTop: 86,
    titleLeft: 19,
    icon: 'assets/images/learning/ic_confetti.png',
    iconBox: Rect.fromLTWH(174, 20, 52, 52),
    blocks: [LearningPopupBlock(LearningPopupText.doneBody, left: 12, top: 121.75, width: 368, center: true, weight: 500)],
    button: Rect.fromLTWH(104, 204, 183.13, 39),
    buttonLabel: LearningCommonText.backHome,
    toHome: true,
  );
}
