import '../../../../core/utils/json_fields.dart';

// -------------------------------------------------------------
// EmergencyAlertDto — تنبيه "أنا ضائع" مع موقع المستخدم (للسيرفر)
// JSON (ASP.NET Core):
//   { "userId": "42", "currentLat": 21.4227, "currentLng": 39.8212, "timestamp": "2026-10-09T15:30:00.000Z" }
//   timestamp بتوقيت UTC بصيغة ISO 8601 (DateTime بـ C#)
// -------------------------------------------------------------
class EmergencyAlertDto {
  final String userId;
  final double currentLat;
  final double currentLng;
  final DateTime timestamp;

  const EmergencyAlertDto({required this.userId, required this.currentLat, required this.currentLng, required this.timestamp});

  factory EmergencyAlertDto.fromJson(Map<String, dynamic> json) => EmergencyAlertDto(
    userId: json.requireString('userId'),
    currentLat: json.requireDouble('currentLat'),
    currentLng: json.requireDouble('currentLng'),
    timestamp: DateTime.parse(json.requireString('timestamp')),
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'currentLat': currentLat,
    'currentLng': currentLng,
    'timestamp': timestamp.toUtc().toIso8601String(),
  };
}
