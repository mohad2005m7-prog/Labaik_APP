import '../../domain/entities/personal_dua.dart';

// -------------------------------------------------------------
// تحويل الدعاء الخاص لـ JSON وبالعكس (للحفظ على الجهاز، وجاهز لـ API الأدعية لما ينضاف بالباك إند)
// -------------------------------------------------------------
extension PersonalDuaJson on PersonalDua {
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'text': text, 'updatedAt': updatedAt.toIso8601String()};

  static PersonalDua fromJson(Map<String, dynamic> json) => PersonalDua(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        text: json['text'] as String? ?? '',
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      );
}
