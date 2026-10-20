import 'dart:ui';

import '../../../../core/l10n/tx.dart';

// -------------------------------------------------------------
// وصف شاشة خطوة (من الباب لبداية الطواف) بأرقام إطار Figma — كلهم نفس التصميم:
// العنوان الفرعي (SF Compact 556 16 #4C7A75) ← صورة 361×386 ← كرت (#4C7A75 10% بظل) نصه بالنص
// ← سطر/دعاء تحته (#4C7A75) ← زر أخضر
// النصوص: [left]/[top]/[width] = صندوق النص بـ Figma (top لأول سطر بـ line height 22)
// -------------------------------------------------------------
class TawafTextBox {
  final double left;
  final double top;
  final double width;

  const TawafTextBox(this.left, this.top, this.width);
}

/// السطر/الدعاء تحت الكرت: حجمه ووزنه بيختلف بين الشاشات بـ Figma
class TawafNote {
  final Tx text;
  final TawafTextBox box;
  final double size;
  final double weight;

  const TawafNote(this.text, this.box, {required this.size, required this.weight});
}

class TawafStepSpec {
  final Tx? title;
  final Tx subtitle;
  final TawafTextBox subtitleBox;

  /// الصورة (null = صورة الباب اللي وصله — شاشة الباب)
  final String? photo;
  final Rect photoRect;
  final Rect card;
  final Tx cardText;
  final TawafTextBox cardBox;
  final TawafNote note;
  final Rect button;
  final Tx buttonLabel;
  final double frameHeight;

  /// الهيدر: الشاشات الأولى "Frame 38" من y59، وابدأ الطواف والأشواط من y51 (TawafHeader)
  final bool highHeader;

  const TawafStepSpec({
    this.title,
    required this.subtitle,
    required this.subtitleBox,
    this.photo,
    required this.photoRect,
    required this.card,
    required this.cardText,
    required this.cardBox,
    required this.note,
    required this.button,
    required this.buttonLabel,
    this.frameHeight = 852,
    this.highHeader = false,
  });
}
