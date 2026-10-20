import '../../../../core/utils/json_fields.dart';

// -------------------------------------------------------------
// مجموعتي من GET /home → "group" (null = مش مضاف لمجموعة — الشركة هي اللي بتضيف الأعضاء والمشرفين):
// { "id", "name", "leaderName", "memberCount", "myRole" (1 Leader · 2 Member), "unreadAnnouncements" }
// -------------------------------------------------------------
class HomeGroup {
  final String id;
  final String name;
  final String? leaderName;
  final int memberCount;

  /// مشرف المجموعة (myRole == 1) — زر "نشر إعلان" بيظهر حسبه، مش حسب user.roles
  final bool isLeader;
  final int unreadAnnouncements;

  /// رسائل دردشة المجموعة غير المقروءة
  final int unreadMessages;

  const HomeGroup({required this.id, required this.name, this.leaderName, this.memberCount = 0, this.isLeader = false, this.unreadAnnouncements = 0, this.unreadMessages = 0});

  /// من جسم رد /home كله
  static HomeGroup? fromHome(Object? home) {
    final group = home is Map<String, dynamic> ? home.field('group') : null;
    if (group is! Map<String, dynamic>) return null;
    final leader = group.field('leaderName')?.toString().trim();
    return HomeGroup(
      id: group.requireString('id'),
      name: group.field('name')?.toString() ?? '',
      leaderName: leader == null || leader.isEmpty ? null : leader,
      memberCount: group.optionalInt('memberCount') ?? 0,
      isLeader: group.optionalInt('myRole') == 1,
      unreadAnnouncements: group.optionalInt('unreadAnnouncements') ?? 0,
      unreadMessages: group.optionalInt('unreadMessages') ?? 0,
    );
  }
}
