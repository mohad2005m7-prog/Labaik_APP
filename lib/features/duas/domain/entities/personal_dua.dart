import 'package:equatable/equatable.dart';

// -------------------------------------------------------------
// دعاء كتبه المعتمر بنفسه ("سجل أدعيتي") — عنوان ونص وآخر تعديل
// -------------------------------------------------------------
class PersonalDua extends Equatable {
  final String id;
  final String title;
  final String text;
  final DateTime updatedAt;

  const PersonalDua({required this.id, required this.title, required this.text, required this.updatedAt});

  @override
  List<Object> get props => [id, title, text, updatedAt];
}
