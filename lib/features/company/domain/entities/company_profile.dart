import 'package:equatable/equatable.dart';

// -------------------------------------------------------------
// بيانات الشركة (CompanyDto من GET /company/me) — الملف الشخصي وتعديل البيانات ومعلومات التواصل
// [licenseNumber] = رقم السجل التجاري (رقم الترخيص) — [contactName] = اسم مسؤول الشركة
// [supportEmail] = بريد دعم لبيك (من إعدادات السيرفر — لـ "المساعدة والدعم")
// -------------------------------------------------------------
class CompanyProfile extends Equatable {
  final String id;
  final String name;
  final String? logoUrl;
  final String licenseNumber;
  final String? country;
  final String? city;
  final String? email;
  final String? phone;
  final String contactName;
  final String? supportEmail;

  const CompanyProfile({
    this.id = '',
    required this.name,
    required this.licenseNumber,
    required this.contactName,
    this.logoUrl,
    this.country,
    this.city,
    this.email,
    this.phone,
    this.supportEmail,
  });

  CompanyProfile copyWith({String? logoUrl, String? name, String? licenseNumber, String? country, String? city, String? email, String? phone, String? contactName}) => CompanyProfile(
        id: id,
        name: name ?? this.name,
        logoUrl: logoUrl ?? this.logoUrl,
        licenseNumber: licenseNumber ?? this.licenseNumber,
        country: country ?? this.country,
        city: city ?? this.city,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        contactName: contactName ?? this.contactName,
        supportEmail: supportEmail,
      );

  @override
  List<Object?> get props => [id, name, logoUrl, licenseNumber, country, city, email, phone, contactName, supportEmail];
}
