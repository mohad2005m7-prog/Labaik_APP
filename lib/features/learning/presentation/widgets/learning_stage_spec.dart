import 'dart:ui';

import '../../../../core/l10n/tx.dart';
import 'learning_popup_spec.dart';

// -------------------------------------------------------------
// وصف شاشة مرحلة تعلم بأرقام إطار Figma (كل المراحل نفس التصميم بعناصر وأماكن مختلفة)
// الأيقونات PNG مقصوصة من Figma: [LearningIcon.box] = مكان الصورة كلها (مش الرسمة بس)
// -------------------------------------------------------------
class LearningIcon {
  final String name;
  final Rect box;

  const LearningIcon(this.name, this.box);

  String get asset => 'assets/images/learning/$name.png';
}

/// شريحة: مستطيل (#4C7A75 25%) + أيقونة + عنوان (SF Compact 457 14) طرفه [textRight] وأعلى صندوقه [textTop]
/// [raised]: الشريحة اللي فوق الكروت (عليها ظل وعلى خلفية بيضا)
class LearningChip {
  final Rect rect;
  final Tx label;
  final double textRight;
  final double textTop;
  final LearningIcon icon;
  final bool raised;

  const LearningChip({required this.rect, required this.label, required this.textRight, required this.textTop, required this.icon, this.raised = false});
}

/// كرت (#4C7A75 10% بظل): الشريحة + النص (SF Compact 350 14) من [bodyLeft] لـ [bodyRight] وأعلى صندوقه [bodyTop]
class LearningCard {
  final Rect rect;
  final LearningChip chip;
  final Tx body;
  final double bodyLeft;
  final double bodyRight;
  final double bodyTop;

  const LearningCard({required this.rect, required this.chip, required this.body, required this.bodyTop, required this.bodyRight, this.bodyLeft = 22});
}

/// زر ذهبي (#A59063) بيفتح نافذة — النص أبيض (SF Compact 790: حجمه بيختلف بين الأزرار) وأعلى صندوقه [textTop]
/// بنص الزر — أو طرفه عند [textRight] لو قبله سهم "→" ([arrow]: مكان خطه)
class LearningLink {
  final Rect rect;
  final Tx label;
  final double textTop;
  final double textSize;
  final double textWeight;
  final double? textRight;
  final Rect? arrow;
  final LearningPopupSpec popup;

  const LearningLink({required this.rect, required this.label, required this.textTop, required this.popup, this.textSize = 15, this.textWeight = 640, this.textRight, this.arrow});
}

/// نص سطر واحد (العنوان تحت الهيدر والسطر تحت الشريحة): صندوقه بـ Figma (Auto width)
class LearningLine {
  final Tx text;
  final double left;
  final double top;
  final double width;

  const LearningLine(this.text, {required this.left, required this.top, required this.width});
}

class LearningStageSpec {
  final double frameHeight;
  final Tx title;
  final LearningLine subtitle;
  final LearningChip topChip;
  final LearningLine note;
  final List<LearningCard> cards;
  final List<LearningLink> links;

  /// الزر الأخضر: "التالي" (أو "تمت العمرة" بآخر مرحلة)
  final Rect next;
  final Tx nextLabel;

  /// زر "الرئيسية" (أبيض بحد أسود) — آخر مرحلة ما فيها
  final Rect? home;

  const LearningStageSpec({
    required this.frameHeight,
    required this.title,
    required this.subtitle,
    required this.topChip,
    required this.note,
    required this.cards,
    required this.links,
    required this.next,
    required this.nextLabel,
    this.home,
  });
}
