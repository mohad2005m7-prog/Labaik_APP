import 'package:equatable/equatable.dart';

// -------------------------------------------------------------
// إشعار للشركة (Figma "الاشعارات" 751:4011): عنوان ونص
// [isRead] false = الكرت الأغمق بظل (جديد ما انقرا) — [type]/[groupId]/[referenceId] للانتقال لموضوعه بالضغط
// -------------------------------------------------------------
class CompanyNotification extends Equatable {
  final String id;
  final String title;
  final String body;
  final bool important;
  final DateTime createdAt;
  final bool isRead;
  final int type;
  final String? groupId;
  final String? referenceId;

  const CompanyNotification({required this.id, required this.title, required this.body, required this.createdAt, this.important = false, this.isRead = true, this.type = 0, this.groupId, this.referenceId});

  @override
  List<Object?> get props => [id, title, body, important, createdAt, isRead, type, groupId, referenceId];
}
