import '../../../../core/l10n/tx.dart';

/// نصوص شاشة أعضاء المجموعة
abstract final class GroupMembersText {
  static const title = Tx('أعضاء المجموعة', 'Group members');
  static const tabAll = Tx('الكل', 'All');
  static String tabPresent(Object n) => tr('($n) حاضر', 'Present ($n)');
  static String tabAbsent(Object n) => tr('($n) غير حاضر', 'Absent ($n)');
  static const search = Tx('ابحث عن الاسم أو الرقم', 'Search by name or number');

  // التحكم بالمعتمرين (مش بـ Figma): إضافة بالإيميل، والضغط المطوّل → تسجيل الحضور أو إزالة
  static const markPresent = Tx('تسجيل حاضر', 'Mark present');
  static const markAbsent = Tx('تسجيل غير حاضر', 'Mark absent');
  static const add = Tx('إضافة عضو', 'Add Member');
  static String removeConfirm(Object name) => tr('إزالة $name من المجموعة؟', 'Remove $name from the group?');
  static const remove = Tx('إزالة', 'Remove');
  static const cancel = Tx('إلغاء', 'Cancel');
  static const removed = Tx('تمت إزالة المعتمر من المجموعة', 'Pilgrim removed from the group');
  static const failed = Tx('تعذّر تنفيذ العملية، حاول مرة أخرى', 'Something went wrong, please try again');
}
