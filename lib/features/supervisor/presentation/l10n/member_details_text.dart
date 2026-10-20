import '../../../../core/l10n/tx.dart';

/// نصوص صفحة العضو
abstract final class MemberDetailsText {
  static String pilgrimNumber(int n, {required bool female}) => tr(female ? 'معتمرة رقم $n' : 'معتمر رقم $n', 'Pilgrim no. $n');
  static const moreInfo = Tx('معلومات إضافية', 'More information');
  static const nationality = Tx('الجنسية', 'Nationality');
  static const health = Tx('الحالة الصحية', 'Health status');
  static const notes = Tx('ملاحظات', 'Notes');
  static const contact = Tx('تواصل', 'Contact');
}
