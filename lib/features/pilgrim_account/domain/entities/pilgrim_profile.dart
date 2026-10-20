import 'package:equatable/equatable.dart';

enum PilgrimGender { male, female }

// -------------------------------------------------------------
// بيانات المعتمر (تعديل البيانات الشخصية) — منفصلة تماماً عن بيانات المشرف
// الاسم والإيميل من حسابه، والهاتف والجنس والصورة هو اللي بيضيفهم (ما في صورة أو بيانات تجريبية)
// [photo]: مسار الصورة على الجهاز — null = ما أضاف صورة
// -------------------------------------------------------------
class PilgrimProfile extends Equatable {
  final String fullName;
  final String email;
  final String phone;
  final PilgrimGender? gender;
  final String? photo;

  const PilgrimProfile({this.fullName = '', this.email = '', this.phone = '', this.gender, this.photo});

  static const empty = PilgrimProfile();

  PilgrimProfile copyWith({String? fullName, String? email, String? phone, PilgrimGender? gender, String? photo, bool clearPhoto = false}) {
    return PilgrimProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      photo: clearPhoto ? null : (photo ?? this.photo),
    );
  }

  Map<String, Object?> toJson() => {'fullName': fullName, 'email': email, 'phone': phone, 'gender': gender?.name, 'photo': photo};

  factory PilgrimProfile.fromJson(Map<String, dynamic> json) => PilgrimProfile(
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        gender: PilgrimGender.values.asNameMap()[json['gender']],
        photo: json['photo'] as String?,
      );

  @override
  List<Object?> get props => [fullName, email, phone, gender, photo];
}
