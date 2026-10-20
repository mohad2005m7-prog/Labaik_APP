import 'package:equatable/equatable.dart';

// -------------------------------------------------------------
// إشعار للشركة (Figma "الاشعارات" 751:4011): عنوان ونص، و[important] = الكرت الأغمق بظل ("تم إنشاء مجموعة جديدة")
// -------------------------------------------------------------
class CompanyNotification extends Equatable {
  final String id;
  final String title;
  final String body;
  final bool important;
  final DateTime createdAt;

  const CompanyNotification({required this.id, required this.title, required this.body, required this.createdAt, this.important = false});

  @override
  List<Object?> get props => [id, title, body, important, createdAt];
}
