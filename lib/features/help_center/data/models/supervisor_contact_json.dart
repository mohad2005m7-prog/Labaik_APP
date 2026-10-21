import '../../../../core/utils/json_fields.dart';
import '../../domain/entities/supervisor_contact.dart';

// -------------------------------------------------------------
// SupervisorContactDto من السيرفر (GET /pilgrim/supervisor):
// { "groupId", "groupName", "supervisorId", "fullName", "email", "phoneNumber", "photoUrl" }
// (والكاش القديم على الجهاز: "id" بدل supervisorId)
// -------------------------------------------------------------
extension SupervisorContactJson on SupervisorContact {
  static SupervisorContact fromJson(Map<String, dynamic> json) {
    String? text(String name) {
      final value = json.field(name)?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    return SupervisorContact(
      id: text('supervisorId') ?? json.requireString('id'),
      name: text('fullName') ?? text('name') ?? '',
      phone: text('phoneNumber') ?? text('phone'),
      photoUrl: text('photoUrl'),
      conversationId: text('conversationId'),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'fullName': name, 'phoneNumber': phone, 'photoUrl': photoUrl, 'conversationId': conversationId};
}
