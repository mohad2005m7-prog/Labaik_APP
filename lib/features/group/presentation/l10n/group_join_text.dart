import '../../../../core/l10n/tx.dart';

/// نصوص "انضم إلى مجموعتك" / "تأكد من مجموعتك" / "تم الانضمام بنجاح !" — بنفس كتابة Figma
abstract final class GroupJoinText {
  static const joinTitle = Tx('انضم إلى مجموعتك', 'Join your group');
  static const joinDescription = Tx('أدخل رمز مجموعتك أو امسح رمز QR للانضمام بسهولة.', 'Enter your group code or scan the QR code to join easily.');
  static const codeTab = Tx('أكتب الرمز', 'Enter code');
  static const qrTab = Tx('إمسح QR', 'Scan QR');
  static const enterCode = Tx('أدخل رمز المجموعة', 'Enter the group code');
  static const codeHint = Tx('مثال: UMRAH25', 'e.g. UMRAH25');
  static const scanLabel = Tx('امسح رمز QR الخاص بمجموعتك', "Scan your group's QR code");
  static const join = Tx('الانضمام إلى المجموعة', 'Join the group');

  static const confirmTitle = Tx('تأكد من مجموعتك', 'Confirm your group');
  static const confirmDescription = Tx('تحقق من بيانات المجموعة قبل الانضمام.', 'Check the group details before joining.');
  static String supervisor(String name) => tr('المشرف :$name', 'Supervisor: $name');
  static String members(int n) => tr('عدد أفراد المجموعة: $n معتمرًا', 'Group members: $n pilgrims');
  static const noSupervisor = Tx('المشرف :لم يُحدَّد بعد', 'Supervisor: not assigned yet');
  static String tripDate(DateTime d) => tr('تاريخ الرحلة: ${d.day} ${_ar[d.month - 1]} ${d.year}', 'Trip date: ${d.day} ${_en[d.month - 1]} ${d.year}');
  static const _ar = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  static const _en = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  static const wrongCode = Tx('رمز المجموعة غير صحيح', 'Wrong group code');
  // سيرفر أقدم (قبل 20 أكتوبر كان الانضمام بالرمز للأدمن بس)
  static const joinClosed = Tx('الانضمام بالرمز غير متاح حالياً، شركتك هي اللي بتضيفك للمجموعة', 'Joining by code is not available yet; your company adds you to the group');
  static const connectionError = Tx('تعذّر الاتصال، حاول مرة أخرى', 'Connection failed, please try again');

  static const joinedTitle = Tx('تم الانضمام بنجاح !', 'Joined successfully!');
  static String joinedBody(String group, int others) =>
      tr('أنت الآن عضو في مجموعة " $group "\nبرفقة  $others معتمر اخرين', 'You are now a member of "$group" with $others other pilgrims');
  static const viewGroup = Tx('رؤية المجموعة', 'View the group');
}
