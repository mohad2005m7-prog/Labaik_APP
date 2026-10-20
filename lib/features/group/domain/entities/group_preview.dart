import '../../../../core/utils/json_fields.dart';

/// المجموعة قبل الانضمام (شاشة "تأكد من مجموعتك") — من GET /groups/{code}:
/// GroupSummaryDto { id, name, leaderName?, memberCount, tripDate? ("yyyy-MM-dd"), companyName?, leaderPhotoUrl? }
class GroupPreview {
  final String id;
  final String code;
  final String name;

  /// null = الشركة لسا ما عيّنت مشرف
  final String? supervisor;
  final int memberCount;

  /// تاريخ رحلة المجموعة (null = مجموعة بلا رحلة أو سيرفر أقدم)
  final DateTime? tripDate;
  final String? companyName;

  const GroupPreview({required this.id, required this.code, required this.name, this.supervisor, this.memberCount = 0, this.tripDate, this.companyName});

  factory GroupPreview.fromJson(Map<String, dynamic> json, String code) {
    final leader = json.field('leaderName')?.toString().trim();
    final company = json.field('companyName')?.toString().trim();
    return GroupPreview(
      id: json.requireString('id'),
      code: code,
      name: json.field('name')?.toString() ?? '',
      supervisor: leader == null || leader.isEmpty ? null : leader,
      memberCount: json.optionalInt('memberCount') ?? 0,
      tripDate: DateTime.tryParse(json.field('tripDate')?.toString() ?? ''),
      companyName: company == null || company.isEmpty ? null : company,
    );
  }
}
