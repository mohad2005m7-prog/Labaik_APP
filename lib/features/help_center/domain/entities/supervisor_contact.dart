import 'package:equatable/equatable.dart';

// -------------------------------------------------------------
// مشرف مجموعة المعتمر (من السيرفر — الشركة بتربط المعتمر بمجموعته ومشرفها)
// [phone]: الرقم المخزّن بحساب المشرف أو اللي الشركة حاطّته بقائمة المشرفين
// [conversationId]: المحادثة الفردية بين المعتمر ومشرفه
// -------------------------------------------------------------
class SupervisorContact extends Equatable {
  final String id;
  final String name;
  final String? phone;
  final String? photoUrl;
  final String? conversationId;

  const SupervisorContact({required this.id, required this.name, this.phone, this.photoUrl, this.conversationId});

  bool get hasPhone => (phone ?? '').trim().isNotEmpty;

  @override
  List<Object?> get props => [id, name, phone, photoUrl, conversationId];
}
