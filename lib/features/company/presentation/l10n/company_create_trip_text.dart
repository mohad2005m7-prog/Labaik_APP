import '../../../../core/l10n/tx.dart';

/// نصوص شاشة "إنشاء رحلة جديدة" (Figma 572:3961) وبوب-أب "تم إنشاء الرحلة" (647:4722)
abstract final class CompanyCreateTripText {
  static const title = Tx('إنشاء رحلة جديدة', 'Create New Trip');
  // تسميات الحقول
  static const tripType = Tx('نوع الرحلة :', 'Trip type:');
  static const tripName = Tx('اسم الرحلة :', 'Trip name:');
  static const destinations = Tx('الوجهات :', 'Destinations:');
  static const departureDate = Tx('تاريخ الذهاب :', 'Departure date:');
  static const returnDate = Tx('تاريخ العودة :', 'Return date:');
  /// "عدد المعتمرين" للعمرة و"عدد الحجاج" للحج
  static String pilgrimsCount({required bool hajj}) => hajj ? tr('عدد الحجاج :', 'Number of Hajj pilgrims:') : tr('عدد المعتمرين :', 'Number of Umrah pilgrims:');
  static const departurePoint = Tx('مكان الانطلاق :', 'Departure point:');
  static const notesLabel = Tx('ملاحظات إضافية (اختياري) :', 'Additional notes (optional):');
  static const createButton = Tx('إنشاء الرحلة', 'Create Trip');
  // نصوص تلميح الحقول
  static const departureDateHint = Tx('اختر تاريخ الذهاب', 'Select departure date');
  static const returnDateHint = Tx('اختر تاريخ العودة', 'Select return date');
  // التلميحات بتتغير مع نوع الرحلة (عمرة / حج)
  static String tripNameHint({required bool hajj}) => hajj ? tr('رحلة الحج الأولى', 'First Hajj Trip') : tr('رحلة العمرة الأولى', 'First Umrah Trip');
  static String destinationsHint({required bool hajj}) =>
      hajj ? tr('مكة المكرمة، منى، عرفات، مزدلفة', 'Makkah, Mina, Arafat, Muzdalifah') : tr('مكة المكرمة، المدينة المنورة', 'Makkah, Madinah');
  static const pilgrimsCountHint = Tx('أدخل العدد', 'Enter count');
  static const departurePointHint = Tx('نقطة التجمع الرئيسية', 'Main assembly point');
  static const notesHint = Tx('اكتب أي تفاصيل إضافية عن الرحلة...', 'Write any additional details about the trip...');
  // أنواع الرحلات
  static const typeUmrah = Tx('عمرة', 'Umrah');
  static const typeHajj = Tx('حج', 'Hajj');
  // بوب-أب النجاح (647:4722)
  static const successTitle = Tx('تم إنشاء الرحلة', 'Trip Created');
  static const successButton = Tx('العودة للرحلات', 'Back to Trips');
}
