import '../../../../core/utils/json_fields.dart';

/// المجموعة قبل الانضمام (شاشة "تأكد من مجموعتك") — من GET /groups/{code}:
/// GroupSummaryDto { id, name, leaderName?, memberCount }
class GroupPreview {
  final String id;
  final String code;
  final String name;

  /// null = الشركة لسا ما عيّنت مشرف
  final String? supervisor;
  final int memberCount;

  const GroupPreview({required this.id, required this.code, required this.name, this.supervisor, this.memberCount = 0});

  factory GroupPreview.fromJson(Map<String, dynamic> json, String code) {
    final leader = json.field('leaderName')?.toString().trim();
    return GroupPreview(
      id: json.requireString('id'),
      code: code,
      name: json.field('name')?.toString() ?? '',
      supervisor: leader == null || leader.isEmpty ? null : leader,
      memberCount: json.optionalInt('memberCount') ?? 0,
    );
  }
}
