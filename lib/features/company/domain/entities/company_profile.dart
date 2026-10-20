import 'package:equatable/equatable.dart';

// -------------------------------------------------------------
// بيانات الشركة (CompanyDto من GET /company/me) — الملف الشخصي وتعديل البيانات ومعلومات التواصل
// [licenseNumber] = رقم السجل التجاري (رقم الترخيص) — [contactName] = اسم مسؤول الشركة
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
  });

  CompanyProfile copyWith({String? name, String? licenseNumber, String? country, String? city, String? email, String? phone, String? contactName}) => CompanyProfile(
        id: id,
        name: name ?? this.name,
        logoUrl: logoUrl,
        licenseNumber: licenseNumber ?? this.licenseNumber,
        country: country ?? this.country,
        city: city ?? this.city,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        contactName: contactName ?? this.contactName,
      );

  @override
  List<Object?> get props => [id, name, logoUrl, licenseNumber, country, city, email, phone, contactName];
}
