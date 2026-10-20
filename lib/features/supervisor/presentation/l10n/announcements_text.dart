import '../../../../core/l10n/tx.dart';

/// نصوص شاشة الإعلانات (إنشاء إعلان + الإعلانات السابقة)
abstract final class AnnouncementsText {
  static const title = Tx('الإعلانات', 'Announcements');
  static const createTab = Tx('إنشاء إعلان جديد', 'New announcement');
  static const previousTab = Tx('إعلانات سابقة', 'Previous');
  static const badgeImportant = Tx('مهم', 'Important');
  static const badgeSent = Tx('تم الإرسال', 'Sent');
  static const viewDetails = Tx('عرض التفاصيل', 'View details');
  static const fieldTitle = Tx('عنوان الإعلان :', 'Announcement title:');
  static const fieldTitleHint = Tx('مثال: تذكير بموعد التجمع', 'e.g. Meeting time reminder');
  static const fieldSendTo = Tx('إرسال إلى :', 'Send to:');
  static const fieldType = Tx('نوع الإعلان :', 'Announcement type:');
  static const typeNormal = Tx('عادي', 'Normal');
  static const typeImportant = Tx('مهم', 'Important');
  static const fieldBody = Tx('نص الإعلان :', 'Announcement text:');
  static const fieldBodyHint = Tx(
    'السلام عليكم، نذكّركم بأن موعد التجمع غدًا الساعة 7:30 صباحًا\nأمام الفندق. يرجى الحضور قبل الموعد بعشر دقائق.',
    'Peace be upon you, we meet tomorrow at 7:30 AM in front of the hotel. Please arrive ten minutes early.',
  );
  static const fieldAttachment = Tx('إرفاق ملف (اختياري)', 'Attach a file (optional)');
  static const addAttachment = Tx('إضافة صورة أو ملف', 'Add a photo or file');
  static const send = Tx('إرسال الإعلان', 'Send announcement');
  static const allPilgrims = Tx('جميع المعتمرين', 'All pilgrims');
  static const errorTitle = Tx('يرجى كتابة عنوان الإعلان', 'Please write the announcement title');
  static const errorType = Tx('يرجى اختيار نوع الإعلان', 'Please choose the announcement type');
  static const errorBody = Tx('يرجى كتابة نص الإعلان', 'Please write the announcement text');
  static const sent = Tx('تم إرسال الإعلان', 'Announcement sent');
}
