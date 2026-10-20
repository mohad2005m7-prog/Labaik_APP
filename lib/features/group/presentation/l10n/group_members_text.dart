import '../../../../core/l10n/tx.dart';

/// نصوص "لائحة أفراد المجموعة" (Figma 111:5507 و 111:6394) — بنفس كتابة Figma
abstract final class GroupMembersText {
  static const title = Tx('أفراد مجموعتي', 'My group');
  static const subtitle = Tx('ابقَ على تواصل مع أفراد مجموعتك أثناء الرحلة.', 'Stay in touch with your group during the trip.');
  static const search = Tx('بحث', 'Search');
  static const supervisor = Tx('مشرف المجموعة', 'Group supervisor');
  static const showOnMap = Tx('رؤية المجموعة على الخريطة', 'See the group on the map');
  static const showMeetingPoint = Tx('عرض نقطة التجمع', 'Show meeting point');

  // مش بـ Figma
  static const empty = Tx('لا يوجد أفراد بعد', 'No members yet');
  static const noResults = Tx('لا توجد نتائج', 'No results');
  static const notLinked = Tx('لم يتم ربطك بمجموعة بعد', "You haven't been added to a group yet");
}
