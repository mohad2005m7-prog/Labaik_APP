import '../../../../core/l10n/tx.dart';

/// نصوص اختيار صورة (كاميرا / معرض / حذف)
abstract final class PhotoPickerText {
  static const camera = Tx('التقاط صورة', 'Take a photo');
  static const gallery = Tx('اختيار من المعرض', 'Choose from gallery');
  static const remove = Tx('حذف الصورة', 'Remove photo');
  static const error = Tx('تعذّر فتح الكاميرا أو المعرض', "Couldn't open the camera or gallery");
}
