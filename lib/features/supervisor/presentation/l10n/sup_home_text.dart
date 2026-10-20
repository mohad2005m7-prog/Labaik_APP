import '../../../../core/l10n/tx.dart';

/// نصوص رئيسية المشرف
abstract final class SupHomeText {
  static const greeting = Tx('السلام عليكم', 'Assalamu Alaikum');
  static String greetingName(Object name) => tr('السلام عليكم، $name', 'Assalamu Alaikum, $name');
  static const role = Tx('مشرف المجموعة', 'Group supervisor');
  static const absent = Tx('غير حاضر', 'Absent');
  static const present = Tx('حاضر', 'Present');
  static const totalPilgrims = Tx('اجمالي المعتمرين', 'Total pilgrims');
  static const nextTrip = Tx('الرحلة القادمة', 'Next trip');
  static const viewFullProgram = Tx('عرض البرنامج الكامل', 'View full program');
}
