import '../../../../core/l10n/tx.dart';

/// نصوص شاشة إضافة دعاء جديد (ونفسها لتعديل دعاء)
abstract final class DuaFormText {
  static const addTitle = Tx('إضافة دعاء جديد', 'Add a new dua');
  static const editTitle = Tx('تعديل الدعاء', 'Edit dua');
  static const duaTitle = Tx('عنوان الدعاء', 'Dua title');
  static const duaTitleHint = Tx('مثال: دعاء لأهلي', 'e.g. A dua for my family');
  static const duaText = Tx('نص الدعاء', 'Dua text');
  static const duaTextHint = Tx('اكتب دعاءك هنا...', 'Write your dua here...');
  static const save = Tx('حفظ الدعاء', 'Save dua');
  static const cancel = Tx('إلغاء', 'Cancel');
  static const saved = Tx('تم حفظ الدعاء', 'Dua saved');
  static const errorTitle = Tx('يرجى كتابة عنوان الدعاء', 'Please enter the dua title');
  static const errorText = Tx('يرجى كتابة نص الدعاء', 'Please write the dua');
}
