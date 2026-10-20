import 'package:equatable/equatable.dart';

// -------------------------------------------------------------
// إعلان من المشرف لمجموعة (أو لجميع المعتمرين)
// كرت "إعلانات سابقة": العنوان، [target] · [whenLabel]، الملخص، وشارة (تم الإرسال / مهم)
// "تفاصيل الإعلان": التاريخ والوقت والنص الكامل والمرفق
// -------------------------------------------------------------
enum AnnouncementType { normal, important }

/// أيقونة الكرت بالتصميم: أعضاء / تقويم / كتاب
enum AnnouncementIcon { group, calendar, book }

class Announcement extends Equatable {
  final String id;
  final String title;
  final String target;
  final String whenLabel;
  final String summary;
  final String body;
  final AnnouncementType type;
  final AnnouncementIcon icon;
  final String dateLabel;
  final String timeLabel;

  /// سطر الختام بالخط العريض تحت النص (مثل "رحلة عمرة مباركة للجميع")
  final String? closing;

  /// صورة مرفقة (مسار على الجهاز أو رابط)
  final String? attachment;

  const Announcement({
    required this.id,
    required this.title,
    required this.target,
    required this.whenLabel,
    required this.summary,
    required this.body,
    required this.type,
    required this.icon,
    required this.dateLabel,
    required this.timeLabel,
    this.closing,
    this.attachment,
  });

  bool get isImportant => type == AnnouncementType.important;

  @override
  List<Object?> get props => [id, title, target, whenLabel, summary, body, type, icon, dateLabel, timeLabel, closing, attachment];
}

/// مسودة "إنشاء إعلان جديد" — بتنحفظ على الجهاز أول بأول (حفظ التقدم)
class AnnouncementDraft extends Equatable {
  final String title;
  final String body;
  final AnnouncementType? type;

  /// null = المجموعة الأساسية
  final String? target;
  final String? attachment;

  const AnnouncementDraft({this.title = '', this.body = '', this.type, this.target, this.attachment});

  static const empty = AnnouncementDraft();

  bool get isEmpty => title.isEmpty && body.isEmpty && type == null && target == null && attachment == null;

  AnnouncementDraft copyWith({String? title, String? body, AnnouncementType? type, String? target, String? attachment, bool clearAttachment = false}) {
    return AnnouncementDraft(
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      target: target ?? this.target,
      attachment: clearAttachment ? null : (attachment ?? this.attachment),
    );
  }

  @override
  List<Object?> get props => [title, body, type, target, attachment];
}
