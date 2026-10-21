import '../../../../core/l10n/tx.dart';

/// نصوص شاشات المجموعات: القائمة، الإنشاء، التفاصيل، الأعضاء (Figma 473:4874 / 630:3979 / 630:4039 / 755:4070)
abstract final class CompanyGroupsText {
  // تبويب المجموعات
  static const title = Tx('المجموعات', 'Groups');
  static const search = Tx('بحث عن مجموعة', 'Search groups');
  static const createGroup = Tx('إنشاء مجموعة', 'Create Group');
  static const empty = Tx('لا توجد مجموعات حتى الآن', 'No groups yet');
  static const noResults = Tx('لا توجد نتائج', 'No results');
  // فلاتر: الكل / مكتملة (فيها مشرف) / غير مكتملة
  static const all = Tx('الكل', 'All');
  static const complete = Tx('مكتملة', 'Complete');
  static const incomplete = Tx('غير مكتملة', 'Incomplete');
  // كرت المجموعة
  static String pilgrimCount(int n, {bool hajj = false}) => hajj ? tr('$n حاج', '$n pilgrims') : tr('$n معتمر', '$n pilgrims');
  static String supervisorLine(Object name) => tr('مشرف المجموعة : $name', 'Supervisor: $name');
  static const noSupervisor = Tx('لا يوجد بعد', 'none yet');
  static const details = Tx('عرض تفاصيل المجموعة', 'View group details');

  // إنشاء مجموعة جديدة (630:3979)
  static const createTitle = Tx('إنشاء مجموعة جديدة', 'Create New Group');
  static const groupName = Tx('اسم المجموعة :', 'Group name:');
  static const groupNameHint = Tx('ادخل اسم المجموعة', 'Enter the group name');
  static const trip = Tx('الرحلة :', 'Trip:');
  static const tripHint = Tx('اختر الرحلة', 'Choose the trip');
  static const supervisor = Tx('اختر مشرف :', 'Choose a supervisor:');
  static const supervisorHint = Tx('اختر المشرف (اختياري)', 'Choose a supervisor (optional)');
  static const noSupervisorOption = Tx('بدون مشرف الآن', 'No supervisor for now');
  static const createButton = Tx('إنشاء المجموعة', 'Create Group');
  static const needTrip = Tx('اختر الرحلة واكتب اسم المجموعة', 'Choose the trip and enter the group name');
  // السعة والملاحظات (Figma: "اضافة المعتمرون: العدد")
  static String capacity({bool hajj = false}) => hajj ? tr('عدد الحجاج :', 'Pilgrims capacity:') : tr('عدد المعتمرين :', 'Pilgrims capacity:');
  static const capacityHint = Tx('العدد الأقصى (اختياري)', 'Maximum number (optional)');
  static const invalidCapacity = Tx('اكتب عدداً صحيحاً أكبر من صفر', 'Enter a whole number greater than zero');
  static const notesHint = Tx('اكتب ملاحظاتك (اختياري)', 'Write your notes (optional)');
  static String pilgrimCountOf(int n, int max, {bool hajj = false}) => hajj ? tr('$n / $max حاج', '$n / $max pilgrims') : tr('$n / $max معتمر', '$n / $max pilgrims');

  // تعديل وحذف المجموعة
  static const editTitle = Tx('تعديل المجموعة', 'Edit group');
  static const save = Tx('حفظ', 'Save');
  static const saved = Tx('تم حفظ المجموعة', 'Group saved');
  static const deleteGroup = Tx('حذف المجموعة', 'Delete group');
  static String deleteConfirm(Object name) => tr('حذف «$name»؟ لا يمكن التراجع عن ذلك.', 'Delete "$name"? This cannot be undone.');
  static const deleted = Tx('تم حذف المجموعة', 'Group deleted');
  static const hasMembers = Tx('احذف معتمري المجموعة أولاً ثم احذفها', "Remove the group's pilgrims first, then delete it");
  static const cancel = Tx('إلغاء', 'Cancel');
  static const full = Tx('المجموعة ممتلئة (وصلت العدد الأقصى)', 'The group is full');
  // بوب-أب (656:4748)
  static const createdTitle = Tx('تم إنشاء المجموعة', 'Group Created');
  static String createdCode(Object code) => tr('رمز الانضمام: $code', 'Join code: $code');
  static const backToGroups = Tx('العودة للمجموعات', 'Back to Groups');

  // تفاصيل المجموعة (630:4039)
  static const groupDetail = Tx('تفاصيل المجموعة', 'Group Details');
  static const tripDate = Tx('تاريخ الرحلة', 'Trip date');
  static String pilgrims({bool hajj = false}) => hajj ? tr('الحجاج', 'Pilgrims') : tr('المعتمرون', 'Pilgrims');
  static const allMembers = Tx('عرض جميع الاعضاء', 'View all members');
  static const addMembers = Tx('إضافة اعضاء مجموعة', 'Add group members');
  static const chat = Tx('رؤية الدردشة', 'View chat');
  static const changeSupervisor = Tx('تغيير المشرف', 'Change supervisor');
  static const addSupervisor = Tx('إضافة المشرف', 'Add supervisor');
  static const notes = Tx('ملاحظات إضافية :', 'Additional notes:');
  static const noNotes = Tx('لا توجد ملاحظات حتى اللحظة', 'No notes yet');
  static String joinCode({bool hajj = false}) => hajj ? tr('رمز الانضمام للحجاج', 'Pilgrims join code') : tr('رمز الانضمام للمعتمرين', 'Pilgrims join code');
  static const codeCopied = Tx('تم نسخ الرمز', 'Code copied');

  // أعضاء المجموعة (755:4070)
  static const membersTitle = Tx('أعضاء المجموعة', 'Group Members');
  static const searchMembers = Tx('بحث عن عضو', 'Search members');
  static const addMember = Tx('إضافة عضو', 'Add Member');
  static const removeMember = Tx('حذف من المجموعة', 'Remove from group');
  static const removed = Tx('تم حذف العضو من المجموعة', 'Member removed');
  static const noMembers = Tx('لا يوجد أعضاء بعد', 'No members yet');
}
