import 'package:equatable/equatable.dart';

// -------------------------------------------------------------
// عضو (معتمر) بمجموعة المشرف — قائمة الأعضاء وصفحة العضو
// [photo]: صورة العضو اللي هو أضافها بحسابه (رابط من الباك إند) — null = ما أضاف صورة
// الحضور والرقم والجنس null = السيرفر لسا ما بيبعتهم (بيطلعوا فاضيين)
// المشرف ما بيعدّل صور الأعضاء، بس بيقدر يكبّرها ويشوفها
// -------------------------------------------------------------
enum MemberGender { male, female }

class GroupMember extends Equatable {
  final String id;
  final String name;
  final String? photo;

  /// null = مش معروف (بيطلع بتبويب "الكل" بس)
  final bool? present;

  /// رقم المعتمر بالمجموعة ("معتمرة رقم 15")
  final int? number;
  final MemberGender? gender;
  final String? email;

  /// معلومات إضافية — null = ما في معلومة
  final String? nationality;
  final String? health;
  final String? notes;

  const GroupMember({
    required this.id,
    required this.name,
    this.photo,
    this.present,
    this.number,
    this.gender,
    this.email,
    this.nationality,
    this.health,
    this.notes,
  });

  GroupMember withPresence(bool value) =>
      GroupMember(id: id, name: name, photo: photo, present: value, number: number, gender: gender, email: email, nationality: nationality, health: health, notes: notes);

  @override
  List<Object?> get props => [id, name, photo, present, number, gender, email, nationality, health, notes];
}
