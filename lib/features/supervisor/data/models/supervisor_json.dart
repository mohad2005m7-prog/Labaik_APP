import '../../domain/entities/announcement.dart';
import '../../domain/entities/supervisor_profile.dart';

// -------------------------------------------------------------
// تحويل بيانات المشرف لـ JSON وبالعكس (للحفظ على الجهاز، وجاهزة لـ APIs الباك إند لاحقاً)
// -------------------------------------------------------------
extension SupervisorProfileJson on SupervisorProfile {
  Map<String, dynamic> toJson() => {'fullName': fullName, 'email': email, 'phone': phone, 'photo': photo};

  static SupervisorProfile fromJson(Map<String, dynamic> json) => SupervisorProfile(
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        photo: json['photo'] as String?,
      );
}

extension AnnouncementJson on Announcement {
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'target': target,
        'whenLabel': whenLabel,
        'summary': summary,
        'body': body,
        'type': type.name,
        'icon': icon.name,
        'dateLabel': dateLabel,
        'timeLabel': timeLabel,
        'closing': closing,
        'attachment': attachment,
      };

  static Announcement fromJson(Map<String, dynamic> json) => Announcement(
        id: json['id'] as String,
        title: json['title'] as String,
        target: json['target'] as String,
        whenLabel: json['whenLabel'] as String,
        summary: json['summary'] as String,
        body: json['body'] as String,
        type: AnnouncementType.values.byName(json['type'] as String),
        icon: AnnouncementIcon.values.byName(json['icon'] as String),
        dateLabel: json['dateLabel'] as String,
        timeLabel: json['timeLabel'] as String,
        closing: json['closing'] as String?,
        attachment: json['attachment'] as String?,
      );
}

extension AnnouncementDraftJson on AnnouncementDraft {
  Map<String, dynamic> toJson() => {'title': title, 'body': body, 'type': type?.name, 'target': target, 'attachment': attachment};

  static AnnouncementDraft fromJson(Map<String, dynamic> json) => AnnouncementDraft(
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        type: json['type'] == null ? null : AnnouncementType.values.byName(json['type'] as String),
        target: json['target'] as String?,
        attachment: json['attachment'] as String?,
      );
}
