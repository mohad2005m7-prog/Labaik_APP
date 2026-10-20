import 'dart:ui';

import '../../../../core/l10n/tx.dart';

// -------------------------------------------------------------
// نافذة "Success Screen" (391 عرض #ECF4F1) بأرقام Figma نفسها:
// العنوان (SF Compact 790 20 line height 28 بالنص) — فقرات (14 line height 22) — زر أخضر 183×39
// -------------------------------------------------------------
class LearningPopupBlock {
  final Tx text;
  final double left;
  final double top;
  final double width;
  final bool center;

  /// وزن الخط (Noto Sans Arabic) — مقاس بعرض سطور Figma
  final double weight;

  /// نقطة "•" قبل الفقرة: طرفها اليمين (null = بدون نقطة)
  final double? bulletRight;

  const LearningPopupBlock(this.text, {required this.left, required this.top, required this.width, this.center = false, this.weight = 400, this.bulletRight});
}

class LearningPopupSpec {
  final double height;
  final Tx title;
  final double titleTop;

  /// صندوق العنوان (361 عرض) من x — النص بنصه
  final double titleLeft;
  final String? icon;
  final Rect? iconBox;
  final List<LearningPopupBlock> blocks;
  final Rect button;
  final Tx buttonLabel;

  /// الزر بيرجع للرئيسية (مبروك إتمام العمرة) — غير هيك بيسكّر النافذة بس
  final bool toHome;

  const LearningPopupSpec({
    required this.height,
    required this.title,
    required this.titleTop,
    this.titleLeft = 15,
    this.icon,
    this.iconBox,
    required this.blocks,
    required this.button,
    required this.buttonLabel,
    this.toHome = false,
  });
}
