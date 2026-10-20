import '../../../../core/l10n/tx.dart';

/// نصوص شاشة أعضاء المجموعة
abstract final class GroupMembersText {
  static const title = Tx('أعضاء المجموعة', 'Group members');
  static const tabAll = Tx('الكل', 'All');
  static String tabPresent(Object n) => tr('($n) حاضر', 'Present ($n)');
  static String tabAbsent(Object n) => tr('($n) غير حاضر', 'Absent ($n)');
  static const search = Tx('ابحث عن الاسم أو الرقم', 'Search by name or number');
}
