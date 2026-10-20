import 'package:equatable/equatable.dart';

// -------------------------------------------------------------
// بيانات المشرف نفسه (ملفي الشخصي / تعديل الملف الشخصي)
// الاسم والإيميل من حسابه، والهاتف والصورة هو اللي بيضيفهم — ما في بيانات عشوائية
// [photo]: مسار الصورة على الجهاز (أو رابط لما ينربط الباك إند) — null = ما أضاف صورة
// -------------------------------------------------------------
class SupervisorProfile extends Equatable {
  final String fullName;
  final String email;
  final String phone;
  final String? photo;

  const SupervisorProfile({this.fullName = '', this.email = '', this.phone = '', this.photo});

  static const empty = SupervisorProfile();

  SupervisorProfile copyWith({String? fullName, String? email, String? phone, String? photo, bool clearPhoto = false}) {
    return SupervisorProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photo: clearPhoto ? null : (photo ?? this.photo),
    );
  }

  /// الاسم الأول للترحيب بالرئيسية
  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? '' : parts.first;
  }

  @override
  List<Object?> get props => [fullName, email, phone, photo];
}
