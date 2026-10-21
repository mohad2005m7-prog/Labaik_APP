import '../../../../core/l10n/tx.dart';

/// نصوص المحادثة (Figma 111:7045 و 372:7286)
abstract final class ConversationText {
  /// الـ placeholder بخانة الكتابة — نفس Figma (مكوّن iOS)
  static const hint = Tx('iMessage', 'iMessage');

  /// فقاعة الموقع
  static const myLocation = Tx('موقعي الحالي', 'My current location');

  // فواصل الوقت بين الرسائل — زي Figma ("Yesterday 9:41")
  static const today = Tx('Today', 'Today');
  static const yesterday = Tx('Yesterday', 'Yesterday');

  static const notSent = Tx('لم تُرسل — اضغط لإعادة المحاولة', 'Not sent — tap to retry');

  // صلاحيات الكتابة والتحكم (مش بـ Figma)
  static const readOnly = Tx('قراءة فقط: دردشة المجموعة بين المشرف والمعتمرين', 'Read only: the group chat between the supervisor and pilgrims');
  static const supervisorOnly = Tx('الكتابة في هذه المجموعة للمشرف فقط', 'Only the supervisor can write in this group');
  static String mutedUntil(String time) => tr('كتمك المشرف حتى $time', 'The supervisor muted you until $time');
  static const deleteMessage = Tx('حذف الرسالة', 'Delete message');
  static const deleted = Tx('تم حذف الرسالة', 'Message deleted');
  static const mute1h = Tx('كتم المرسل ساعة', 'Mute the sender for 1 hour');
  static const mute1d = Tx('كتم المرسل يوماً', 'Mute the sender for 1 day');
  static const unmute = Tx('إلغاء كتم المرسل', 'Unmute the sender');
  static const muted = Tx('تم كتم المرسل', 'Sender muted');
  static const unmuted = Tx('تم إلغاء الكتم', 'Sender unmuted');
  static const lockOn = Tx('الكتابة صارت للمشرف فقط', 'Only the supervisor can write now');
  static const lockOff = Tx('الكتابة صارت متاحة للجميع', 'Everyone can write now');
  static const lockTooltip = Tx('الكتابة للمشرف فقط', 'Supervisor only');
  static const actionFailed = Tx('تعذّر تنفيذ العملية، حاول مرة أخرى', 'Something went wrong, please try again');
}
