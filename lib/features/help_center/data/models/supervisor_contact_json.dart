import '../../../../core/utils/json_fields.dart';
import '../../domain/entities/supervisor_contact.dart';

// -------------------------------------------------------------
// SupervisorDto من السيرفر (camelCase أو PascalCase):
// { "id", "fullName", "phoneNumber", "photoUrl", "conversationId" }
// -------------------------------------------------------------
extension SupervisorContactJson on SupervisorContact {
  static SupervisorContact fromJson(Map<String, dynamic> json) {
    String? text(String name) {
      final value = json.field(name)?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    return SupervisorContact(
      id: json.requireString('id'),
      name: text('fullName') ?? text('name') ?? '',
      phone: text('phoneNumber') ?? text('phone'),
      photoUrl: text('photoUrl'),
      conversationId: text('conversationId'),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'fullName': name, 'phoneNumber': phone, 'photoUrl': photoUrl, 'conversationId': conversationId};
}
