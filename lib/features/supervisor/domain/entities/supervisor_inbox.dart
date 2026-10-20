import 'package:equatable/equatable.dart';

// -------------------------------------------------------------
// إشعارات المشرف ومحادثات المجموعات
// -------------------------------------------------------------

/// إشعار — [important] بيطلع بالكرت الأغمق مع ظل ونص أسود (مثل "تنبيه مهم")
class SupervisorNotification extends Equatable {
  final String title;
  final String body;
  final bool important;

  const SupervisorNotification({required this.title, required this.body, this.important = false});

  @override
  List<Object?> get props => [title, body, important];
}

/// مجموعة إشعارات تحت عنوان وقت ("اليوم"، "الأمس 9:40")
class NotificationSection extends Equatable {
  final String label;
  final List<SupervisorNotification> items;

  const NotificationSection({required this.label, required this.items});

  @override
  List<Object?> get props => [label, items];
}

/// محادثة مجموعة بشاشة الدردشات
class ChatThread extends Equatable {
  final String id;
  final String name;
  final String lastMessage;
  final String time;

  const ChatThread({required this.id, required this.name, required this.lastMessage, required this.time});

  @override
  List<Object?> get props => [id, name, lastMessage, time];
}
