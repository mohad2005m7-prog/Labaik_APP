import '../../../../core/l10n/tx.dart';

/// نصوص شاشة الأدعية (سجل أدعيتي / أدعية مقترحة)
abstract final class DuasText {
  static const title = Tx('الأدعية', 'Duas');
  static const subtitle = Tx('اجعل دعاءك قريبًا منك، واحفظ الأدعية اللي بتحب تدعي فيها.', 'Keep your duas close, and save the ones you love to pray.');
  static const myDuasTab = Tx('سجل أدعيتي', 'My duas');
  static const suggestedTab = Tx('أدعية مقترحة', 'Suggested duas');
  static const myDuasTitle = Tx('أدعيتك الخاصة', 'Your own duas');
  static const myDuasHint = Tx('اكتب الأدعية اللي بتحب تحفظها وترجع إلها وقت ما تحتاجها.', 'Write the duas you want to keep and return to whenever you need them.');
  static const addDua = Tx(' + إضافة دعاء', '+ Add dua');
  static const edit = Tx('تعديل', 'Edit');
  static const delete = Tx('حذف', 'Delete');
  static const cancel = Tx('إلغاء', 'Cancel');
  static const deleteQuestion = Tx('حذف الدعاء؟', 'Delete this dua?');
  static const deleted = Tx('تم حذف الدعاء', 'Dua deleted');

  /// "آخر تعديل: اليوم" — أمس، أو التاريخ لو أقدم
  static String lastEdited(DateTime at) {
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day).difference(DateTime(at.year, at.month, at.day)).inDays;
    final when = switch (days) {
      0 => tr('اليوم', 'Today'),
      1 => tr('أمس', 'Yesterday'),
      _ => '${at.day}/${at.month}/${at.year}',
    };
    return tr('آخر تعديل: $when', 'Last edited: $when');
  }
}
