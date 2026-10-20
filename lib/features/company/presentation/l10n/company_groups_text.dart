import '../../../../core/l10n/tx.dart';

/// نصوص شاشات المجموعات: القائمة، التفاصيل، الأعضاء، صفحة العضو
abstract final class CompanyGroupsText {
  // تبويب المجموعات
  static const title = Tx('المجموعات', 'Groups');
  static const search = Tx('بحث عن مجموعة', 'Search groups');
  static const createGroup = Tx('إنشاء مجموعة', 'Create Group');
  static const empty = Tx('لا توجد مجموعات حتى الآن', 'No groups yet');
  // فلاتر
  static const all = Tx('الكل', 'All');
  static const active = Tx('النشطة', 'Active');
  static const ended = Tx('المنتهية', 'Ended');
  // كرت المجموعة
  static const memberCount = Tx('عضو', 'members');

  // تفاصيل المجموعة
  static const groupDetail = Tx('تفاصيل المجموعة', 'Group Details');
  static const members = Tx('الأعضاء', 'Members');
  static const chat = Tx('المحادثة', 'Chat');
  static const editGroup = Tx('تعديل المجموعة', 'Edit Group');

  // قائمة الأعضاء
  static const membersTitle = Tx('الأعضاء', 'Members');
  static const searchMembers = Tx('بحث عن عضو', 'Search members');
  static const addMember = Tx('إضافة عضو', 'Add Member');

  // صفحة العضو
  static const memberTitle = Tx('بيانات العضو', 'Member Details');

  // بوب-أب تم إنشاء المجموعة
  static const createdTitle = Tx('تم إنشاء المجموعة', 'Group Created');
  static const backToGroups = Tx('العودة للمجموعات', 'Back to Groups');
}
