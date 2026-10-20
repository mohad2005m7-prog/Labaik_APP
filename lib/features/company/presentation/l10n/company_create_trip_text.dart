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
  static const pilgrimsCount = Tx('عدد المعتمرين :', 'Pilgrims count:');
  static const departurePoint = Tx('مكان الانطلاق :', 'Departure point:');
  static const notesLabel = Tx('ملاحظات إضافية (اختياري) :', 'Additional notes (optional):');
  static const createButton = Tx('إنشاء الرحلة', 'Create Trip');
  // نصوص تلميح الحقول
  static const departureDateHint = Tx('اختار تاريخ الذهاب', 'Select departure date');
  static const returnDateHint = Tx('اختار تاريخ العودة', 'Select return date');
  static const tripNameHint = Tx('رحلة العمرة الأولى', 'First Umrah Trip');
  static const destinationsHint = Tx('مكة المكرمة والمدينة المنورة', 'Makkah & Madinah');
  static const pilgrimsCountHint = Tx('أدخل العدد', 'Enter count');
  static const departurePointHint = Tx('نقطة التجمع الرئيسية', 'Main assembly point');
  static const notesHint = Tx('أكتبي أي تفاصيل إضافية عن الرحلة...', 'Write any additional details about the trip...');
  // أنواع الرحلات
  static const typeUmrah = Tx('عمرة', 'Umrah');
  static const typeHajj = Tx('حج', 'Hajj');
  // بوب-أب النجاح (647:4722)
  static const successTitle = Tx('تم إنشاء الرحلة', 'Trip Created');
  static const successButton = Tx('العودة للرحلات', 'Back to Trips');
}
